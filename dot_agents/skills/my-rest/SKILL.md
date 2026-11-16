---
name: my-rest
description: Design, build, review, and test REST APIs according to the user's paradigms — business-oriented HTTP contracts over CRUD-by-default, strict HTTP semantics (verbs, status codes, RFC 9457 Problem Details), REST representations decoupled from the domain model, and pragmatic Richardson level 2 with hypermedia affordances when workflows matter. Use this skill whenever designing, creating, modifying, reviewing, refactoring, or testing a REST API or HTTP endpoint — including resource and route design, DTO/request/response modeling, controllers or Minimal APIs, status code selection, error payloads, API versioning, pagination at the boundary, OpenAPI/Swagger documentation, and API integration tests. Trigger even when the user doesn't say "REST" — e.g. "add an endpoint", "expose this as an API", "wire a controller", "fix the 500", "model this resource". Read references/dotnet.md for any C#/.NET API work; read references/http-semantics.md when choosing verbs, status codes, versioning strategies, or error/caching contracts. General code quality is governed by the my-craft skill; this skill governs the HTTP contract itself.
---

# REST contracts

An API is not a transport layer bolted onto a database. It is a published
contract that expresses what the domain can do. Consumers build on it, and
every careless modeling choice becomes their permanent burden. The craft
rules (my-craft) govern the code; these rules govern the contract.

## The default: the contract speaks the domain

Model the contract from the domain's intentions, actions, and valid
transitions — not from database tables dressed up as resources.

- Forcing a domain intention (search, select, rebook, confirm, cancel) into
  create/update CRUD strips meaning out of the contract. Consumers must learn
  arbitrary technical conventions, and the workflow leaks into the client
  adapter. This is the REST–domain impedance mismatch; do not create it.
- Treat **pseudo-functional vocabulary** as a warning sign: a term that
  exists only to accommodate transport or mapping — an invented noun whose
  only job is to make a route look resource-shaped — has no semantic autonomy
  for domain experts. Suspect it before promoting it to a resource; it will
  contaminate docs, discussions, and future change requests.
- Plain CRUD is acceptable for simple reference data with no meaningful
  workflow (catalogs, settings, lookups). The moment the domain has real
  actions and valid state transitions, the contract must expose them.
- **PATCH only in pure CRUD.** A partial-update verb carries no business
  intention — `PATCH /orders/5 {"status": "Cancelled"}` is a state-write in
  disguise. Workflow actions get intention-revealing routes; PATCH stays
  for plain reference-data resources.
- **HTTP semantics are never negotiable.** The freedom to shape the contract
  is about what the domain expresses — resource names, payloads, affordances
  — never about bending verb or status code semantics.

## HTTP is the contract's law

The verb and the status code are as much part of the contract as the body.
Use their standard meanings; consumers and intermediaries (proxies, caches,
gateways, monitoring) depend on them.

| Verb | Meaning | Idempotent | Safe |
| ---- | ------- | ---------- | ---- |
| GET | Read a representation; parameters in path/query; request body has no defined semantics | yes | yes |
| POST | Create a resource or submit data | no | no |
| PUT | Full replace at the target URI (client sends complete state; upsert allowed) | yes | no |
| PATCH | Partial change — body holds modification instructions, not the resource | depends on patch format | no |
| DELETE | Remove; later DELETEs return 404 without further state change | yes | no |
| HEAD | GET without the body — existence checks, metadata | yes | yes |
| OPTIONS | Supported methods (`Allow` header), CORS preflight | yes | yes |

Status code reflexes:

- `201` + `Location` for creation; `202` + status URL for accepted async work;
  `204` for delete or update that returns no body.
- `400` malformed input / validation; `401` unauthenticated; `403`
  authenticated but forbidden; `404` unknown resource; `405` + `Allow`;
  `409` state conflict (e.g. optimistic concurrency); `422` semantically
  invalid business rule; `429` + `Retry-After` rate limiting.
- `500` generic — never leak internal details in production; `502`/`504`
  gateway; `503` + `Retry-After` unavailability.
- Error bodies follow RFC 9457 Problem Details (`application/problem+json`)
  on validation errors — elsewhere the status code suffices.

Routing conventions:

- Routes carry an `/api` prefix by default (`/api/products`).
- **Version by default**: new APIs carry a version segment
  (`/api/v1/products`) unless the user explicitly opts out, or the codebase
  already exposes a large unversioned route surface — matching the existing
  style then wins over importing a scheme. A literal route name inside a
  task prompt is a naming hint, not an opt-out.
- **Paginate collections by default**: a route returning a list is paginated
  unless the user explicitly says otherwise — an unbounded list read is an
  outage waiting for its first big table. Minimalism, "temporary" scope, or
  avoiding a new dependency does not override the stack's default tool —
  the default exists precisely for code that outlives its "temporary"
  label.
- Resources are **plural nouns** (`/products`); an individual resource is
  uniquely identified by a route parameter (`/products/{id}`).
- Query parameters serve GET reads: they carry options, context, and filters
  (pagination, sorting, search criteria). They shape or narrow a read — they
  never identify the resource; identity lives in the path.
- One route, one handler. A sub-resource is its own route with its own
  handler (`/orders/{id}/cancellations`), not extra actions piled onto the
  parent handler. Fat handlers hide route semantics and grow without limit.

When hesitating between codes, or designing caching, versioning, or error
contracts, read `references/http-semantics.md`.

## The representation is not the domain

HTTP resources are **inbound adapters**. Never serialize domain objects
directly over the wire:

- Exposing a domain object as a resource couples consumers to internal field
  names and modeling decisions. A dedicated representation lets the edge own
  mapping, field deprecation, backward compatibility, and versioning while
  the domain changes its internals freely.
- One DTO per operation when fields differ (Create ≠ Update ≠ Response).
- At every adapter boundary, convert pagination, formats, field names, and
  dirty external data into valid domain objects — an anti-corruption layer,
  in both directions.
- Never store endpoint or base URLs as application data. Configuration
  belongs to the environment (12-factor III); a URL is runtime configuration,
  not a database row.

## Maturity: pragmatic level 2, affordances when workflow matters

- Target **Richardson level 2**: resource URIs, correct verbs, honest status
  codes. Most production APIs stop here, and that is a sound choice when
  clients are known and controlled (SPAs, mobile apps).
- Full HATEOAS (level 3) is rarely justified: client complexity, payload
  overhead, and weak tooling (OpenAPI generators do not follow links).
  Adopt hypermedia selectively, not as dogma.
- When the domain has an explicit workflow, expose **affordances**: from the
  current state, not only *which* actions are possible but *how* to trigger
  them — method, required fields, constraints. Clients follow affordances
  instead of reconstructing the scenario or guessing URIs.
- OpenAPI/Swagger documentation is the standing substitute for hypermedia
  discoverability. Keep it accurate and complete — it *is* part of the
  contract.

## Contracts evolve in payloads

Observed consistently across API lifetimes: the URL — base and path — is the
most stable part of the contract; changes concentrate in input parameters and
response fields. Draw the consequences:

- Versioning and contract testing must cover request/response **schemas**,
  not just URL registries or redirects. A mechanism that only secures URLs
  does not protect the real contract.
- Prefer additive, backward-compatible payload changes; deprecate fields
  explicitly at the edge.
- True URL changes (rebuilds, host or prefix migrations) are environment
  configuration concerns, not application data.
- When a contract is shared with external consumers, use consumer-driven
  contract testing: only the parts consumers actually use are frozen, and
  only those need provider-side verification.

## Safe by default

Make the right integration easy and the wrong one hard. The API itself — not
developer discipline — should prevent common mistakes:

- **Closed by default, opened explicitly.** Authorization is enforced by the
  HTTP configuration itself (a fallback policy or `RequireAuthorization` on
  the app/group), so a new endpoint is protected without anyone remembering
  to protect it; `AllowAnonymous` is the only way to open one, and it reads
  as a deliberate decision at the exact endpoint it opens. Do not sprinkle
  `[Authorize]` per endpoint and hope none was forgotten — one forgotten
  attribute is an open endpoint.
- **Error transformation is centralized.** Business failures — exceptions or
  a Result monad — become Problem Details in exactly one place: a global
  exception handler or a shared helper. Actions stay declarative; scattered
  try/catch mapping multiplies the places where error semantics can drift
  apart.
- **Uniform errors, bodies only where the client can act.** Problem Details
  bodies live on bad-client validation errors (400/422 — they name the
  fields to fix). Every other status speaks for itself and needs no body:
  401 (who are you), 403 (authenticated, still no), 404 (nothing here),
  409 (state conflict — e.g. an EF/NHibernate version-attribute mismatch),
  500 (failed; deliberately says nothing more). Metadata that helps travels
  in headers, never in bodies: `Location` (201), `Allow` (405),
  `Retry-After` (429/503), `WWW-Authenticate` (401).
- **Validate at the boundary**: reject invalid input before it reaches the
  domain, with errors that name the problem.
- **Stateless request handling**: no server-side session; every request
  carries what it needs. This is what makes horizontal scaling and caching
  work — mark responses cacheable or not, explicitly.

## Test through the contract

Integration tests exercise the HTTP boundary, not internal methods: the
endpoint accepts the right inputs, rejects the wrong ones, triggers the right
use case, and returns the right statuses and output shapes — with real
requests and observable responses. A unit test that bypasses the boundary
proves nothing about the contract.

## Say it once

The signature is the documentation. A typed result (`ActionResult<T>`,
`Results<Ok<T>, NotFound>`) already states what an endpoint produces; content
negotiation states the media type; the HTTP RFCs state the error semantics.
Do not restate any of that in attributes or response-type metadata — a
twice-written contract is a contract that rots out of sync. The same
discipline applies to comments: names and types carry the *what*; a comment
earns its line only by carrying a *why* the signature cannot show (my-craft).
An error mapping visible in the code (`Conflict(ProblemDetails)`) needs no
narration next to it, and a shortcut flagged in the README does not need a
second flag on the class — debt documentation lives in one place. When a
mechanism needs explaining (validation wiring, non-automatic behavior),
prefer an explicit, well-named method or filter over a comment that
explains it. Generated API code carries **no comments at all** — design
rationale, limits, and shortcuts live in the README, the one place a
reviewer actually reads (this overrides my-craft's inline `shortcut:` flags
for API surface code). And when a contract decision is genuinely ambiguous
— what a `Location` should point at, which identifier a route should carry
— ask the user instead of picking silently: a guessed contract is a
contract someone has to unpick later. If an endpoint needs a paragraph of
XML docs to be understood, rename things until it doesn't.

## In .NET

For any C#/.NET API work, read `references/dotnet.md`: exposure model
selection (Controllers / Minimal API / FastEndpoints), validation wiring,
error middleware, OpenAPI, integration testing (WebApplicationFactory,
Alba), authentication, versioning with Asp.Versioning, and the default
pagination stack (Gridify).
