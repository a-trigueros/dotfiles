# HTTP semantics reference

Load this file when choosing verbs, status codes, versioning strategies,
caching behavior, or error payload shapes. Everything here is standard HTTP
semantics as applied to REST contracts; the paradigm rules live in SKILL.md.

## Verbs in detail

**GET** — Read a representation. No side effects (safe), idempotent. The
request body has no defined semantics: clients must not send one, servers
must not read one. Parameters go in the path or query string.

**POST** — Create a resource or submit data for processing. Not idempotent:
two identical POSTs create two distinct resources. The body holds the
representation to create or the data to process.

**PUT** — Replace the entire resource at the target URI. Idempotent: two
identical PUTs leave the same final state. The body holds the complete
representation. If the resource does not exist, the server may create it
(upsert). Use PUT when the client sends the resource's complete state.

**PATCH** — Partial modification. The body holds modification instructions,
not the complete resource. Idempotence depends on the patch format: JSON
Patch is idempotent, JSON Merge Patch is not. Use PATCH when the client
sends only differences.

**DELETE** — Remove the resource at the target URI. Idempotent: after the
first DELETE, later ones return 404 but the server state no longer changes.

**HEAD** — Same as GET without the response body. Existence checks and
metadata reads without transferring content.

**OPTIONS** — Returns the methods supported by the resource via the `Allow`
header. Used for discoverability and CORS preflight.

Summary rule: PUT when the client sends the complete state, PATCH when it
sends only the diff.

Design note: PATCH expresses a mechanical diff, not a business intention —
`PATCH {"status": "Cancelled"}` is a state-write in disguise. Reserve it
for pure CRUD resources (reference data, settings); domain actions deserve
intention-revealing routes instead of field writes.

Query parameters never carry identity (that is the path's job). On reads
they filter what is returned; on writes they alter the behavior of the
operation — options like `?draft=true` or `?hideOnly=true` that modulate
how the verb applies without becoming body fields (paradigm rules in
SKILL.md).

## Status codes

Five classes, identified by the first digit. The status code communicates
the operation result in a normalized way — treat it as contract, not
decoration.

### 1xx — Informational
Rare in REST APIs. `101 Switching Protocols` (WebSocket upgrade) is the
notable case.

### 2xx — Success
- `200 OK` — success with body: GET results, PUT/PATCH returning the updated
  resource.
- `201 Created` — a new resource exists (POST). Include a `Location` header
  pointing at the created resource's URI.
- `202 Accepted` — accepted for processing but not finished (async /
  background job). The body may contain a status URL.
- `204 No Content` — success, nothing to return: DELETE, or PUT/PATCH when
  the server does not echo the updated resource.

### 3xx — Redirection
- `301 Moved Permanently` — resource permanently moved; new URI in
  `Location`.
- `304 Not Modified` — conditional caching with `If-None-Match` /
  `If-Modified-Since`: content unchanged, client uses its cached copy.

### 4xx — Client error
- `400 Bad Request` — malformed request: validation failure, invalid body,
  missing parameters.
- `401 Unauthorized` — authentication missing or failed; the client must
  present valid credentials. The challenge travels in the
  `WWW-Authenticate` header, not the body.
- `403 Forbidden` — authenticated but not allowed; identity known, access
  denied.
- `404 Not Found` — no resource at this URI.
- `405 Method Not Allowed` — verb not supported for this resource; `Allow`
  lists the supported ones.
- `409 Conflict` — request conflicts with current server state, e.g.
  optimistic concurrency failure (an EF/NHibernate version-attribute
  mismatch) or an explicit business refusal.
- `410 Gone` — deliberately removed (e.g. a sunset API version). Distinct
  from 404: it tells the client the resource existed and was retired —
  the natural complement to API versioning.
- `422 Unprocessable Content` — syntactically valid but semantically wrong:
  business rule violations.
- `429 Too Many Requests` — rate limit exceeded; `Retry-After` says when.

### 5xx — Server error
- `500 Internal Server Error` — unexpected failure. Never expose internal
  details in the body in production.
- `502 Bad Gateway` / `504 Gateway Timeout` — the gateway got an invalid or
  late response from upstream.
- `503 Service Unavailable` — temporarily unavailable (maintenance,
  overload); `Retry-After` may apply.

### Error payloads — bodies only where the client can act
Bad-client validation errors (400/422) carry RFC 7807 Problem Details
(`application/problem+json`; RFC 9457 is the current revision that
obsoletes 7807 — same format, new number) naming every offending field, so
the client can fix the payload in one round trip.

Every other status relies on the status code alone — no body:

- `401` — who are you? The challenge travels in the `WWW-Authenticate`
  header.
- `403` — authenticated, still not allowed.
- `404` — nothing here. Body or no body, it says the same thing.
- `409` — state conflict (e.g. an EF/NHibernate version-attribute mismatch,
  or an explicit business refusal); the client re-reads the resource to
  reconcile.
- `500` — failed, deliberately silent: details go to logs, never to the
  wire.

Metadata that helps the client act travels in headers, not bodies:
`Location` (201), `Allow` (405), `Retry-After` (429, 503),
`WWW-Authenticate` (401).

## Versioning

Purpose: evolve the contract without breaking deployed consumers. Four
strategies:

- **URL path** (`/api/v1/products`) — most visible and simplest; pollutes
  the namespace and freezes links.
- **Custom header** (`X-API-Version: 2`) — clean URLs but implicit and less
  discoverable.
- **Accept header / media type** (`Accept: application/vnd.myapi.v2+json`) —
  closest to REST's spirit (versioning as content negotiation); more complex
  to implement and document.
- **Query parameter** (`?api-version=2`) — easy but rarely recommended: a
  query parameter should not change the semantics of the resource.

The choice follows the API's maturity, client constraints, and the
organization's evolution policy. Whatever the strategy: version the
**schemas**, not just the URLs — contract changes concentrate in payloads
(see SKILL.md).

## Caching and statelessness

- Responses are explicitly cacheable or not (headers, status semantics).
  A correctly cacheable response can be reused by the client or an
  intermediary proxy — less server load, less latency.
- Conditional requests (`ETag` / `If-None-Match`, `If-Modified-Since`) let
  clients reuse their copy (`304`).
- No server-side session state: every request carries everything the server
  needs. Any server can handle any request — that is what makes horizontal
  scaling trivial and layered deployments (proxies, gateways, caches)
  possible.

## Hypermedia formats

When exposing affordances (level 3 selectively, or workflow-driven APIs),
use a standardized format rather than ad-hoc link shapes: HAL, JSON-LD,
Siren, or Collection+JSON. An affordance carries more than a link: method,
required fields, and input constraints, so the client can build the next
action correctly without guessing the contract.

Tooling caveat: OpenAPI client generators do not consume hypermedia
responses natively — weigh this against the decoupling benefit before
committing a whole API to level 3.
