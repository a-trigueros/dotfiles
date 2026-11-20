# Error control: the four validation layers

A SPA/API submission crosses four validation layers on its way to committed
data. The layers repeat and refine one another — defense in depth — and each
has its own information profile: how complete its report is, how fast it
answers, and how much of it the user can exploit. When you add a check, place
it at every layer that can carry it, and never count on a downstream layer to
report what an upstream one could report better.

| # | Layer | What it checks | Failure information |
|---|-------|----------------|---------------------|
| 1 | Frontend | shape and basic content, computable without the server | very complete, immediate |
| 2 | Exposure — HTTP layer / CQRS behaviors | the same checks, from the payload alone | very complete, one round-trip slower |
| 3 | Domain — value objects, process rules | per-field relevance, sanitization, rules needing outside context | scattered — often one failure reason — but precise and user-facing |
| 4 | System — constraints, triggers | transaction-level integrity at commit | not user-exploitable: "your request has failed, please retry" |

## Layer 1 — Frontend

Checks computable without the server: non-empty, adequate length, end date
after start date, missing information — form and basic content only. The job
is the user's: an exhaustive panel of every field problem, delivered at once,
before any network call. Report all violations, not the first.

## Layer 2 — Exposure layer

The same checks — or very close — run again on the web server, as high as
possible: in REST, at the HTTP layer; in CQRS, behaviorally, on the command
pipeline. The difference from layer 1 is the audience: an API does not know
its consumer, so these checks derive from the payload alone. Same contract
as layer 1: the fullest explicit error set, not the first failure.

## Layer 3 — Business validation

Two kinds:

- **Per field: value objects.** They guarantee relevance and sanitize raw
  input at one mechanical choke point (shape, range, allowed vocabulary,
  trim/casing) — which also closes the injection door for that value
  (`references/csharp.md`, "Value objects").
- **Per process: business rules.** Rules that need context the payload does
  not carry — usually the state of the world outside the request. That
  context arrives as a Domain Service passed to the operation:

      User.SetPseudo(string pseudo, IEnsurePseudoUnicity pseudoUnicityEnsurer)

  The `IEnsurePseudoUnicity` implementation checks pseudonym uniqueness
  across the whole database; the aggregate stays responsible for applying
  the answer (double dispatch — `references/object-oriented.md`). By
  convenience, an ensure interface that concerns only one aggregate nests
  under that aggregate and is declared in the domain.

Information here is scattered: the process stops at the first failure it
cannot go past, so the caller usually gets one reason. That reason stays
precise and user-facing.

## Layer 4 — System guarantees

Between transaction begin and commit, a state that checked OK at instant T
can be invalid at commit — a concurrent writer raced the check. The last
barrier is the system itself, through its own mechanisms: unique
constraints, triggers. They guarantee integrity at transaction level,
whatever the application code did.

Their failure report is not user-exploitable: the user gets "your request
has failed, please retry". That is acceptable — this layer's merit is not
its message but the integrity it preserves. Dropping a constraint because
"the upper layers already check it" is how duplicates enter the database.

## Rules across layers

- A payload-shape rule lives at layers 1 AND 2; a rule needing outside
  context lives at layer 3; every rule protecting committed data keeps its
  layer-4 enforcement.
- When layers 2 and 3 both know a rule, the model stays authoritative; the
  exposure layer informs, it does not re-decide (`references/csharp.md`,
  "Validation layering").
- Error information degrades as you descend the stack: exhaustive at 1–2,
  one precise reason at 3, a generic retry message at 4. Map each layer's
  report to what its consumer can exploit — never push layer-4 failure
  details to the user.
