---
name: my-craft
description: Apply the user's software craftsmanship rules whenever writing, modifying, fixing, refactoring, reviewing, or generating code in any language — including small edits, tests, configs, and generated code. Encodes the ladder of automated guarantees (compiler > analyzer > architecture test > assertion > convention), deep modules, no hasty abstractions (rule of three), make illegal states unrepresentable, tests as knowledge (per-operation `<Operation>Should` classes, nested `Fail` with `When_<business reason>` failures), naming coherence, and a paradigm gate with per-situation Object Calisthenics profiles. Read references/object-oriented.md for object-oriented code (SOLID, calisthenics profiles, domain strengthening: closure of operations, double dispatch, no half-baked states, avoiding setters), references/validation-layers.md whenever a change submits, validates, or rejects data in a SPA/API (the four validation layers: frontend, exposure, domain, system), references/csharp.md for any C#/.NET code.
---

# Craft

Your job when touching code is not only to make it work. Every line you write
must leave the codebase more predictable, more verifiable, and cheaper to
change — without rewriting what you did not touch.

## Scope: the diff

These rules bind to every line you add or modify. Code outside the diff is
someone else's current understanding of the system: rewriting it unasked
destroys trust and makes review unreviewable. When you notice a violation near
your work, name it in one sentence (file, rule, why it matters) and let the
user decide. Structural improvements you believe in go in that one sentence,
not in the diff.

## The ladder

Every rule you could state in a review sits on a ladder of guarantees, weakest
to strongest:

**convention** (a doc someone can forget) → **assertion** (one test) →
**automated test** (suite, including architecture tests) → **static analyzer**
→ **compiler**.

A higher tier cannot be forgotten, skipped, or misread under deadline
pressure. When you add or enforce a rule, place it as high as the language
allows, and push it one tier up when cheap: a naming rule becomes an analyzer
setting, a layering rule becomes an architecture test, a domain rule becomes a
type or an assertion. Defer nothing a machine could check today — if the build
can verify a property, the build must fail without it.

## Design reflexes

- **Make illegal states unrepresentable.** When a value can be invalid, prefer
  a type that cannot hold the invalid state over validation that runs later.
  Each impossible state is a bug that will never exist, a test that is not
  needed, a support ticket that never opens.
- **Error control is layered, not singular.** A SPA/API submission is
  validated at four layers — frontend, exposure, domain, system — each with
  a different trade-off between report completeness, speed, and
  user-exploitability. Place each check at every layer that can carry it;
  keep each layer's report matched to what its consumer can exploit
  (`references/validation-layers.md`).
- **Model errors, don't smuggle them.** A business failure surfaces as a typed
  business exception or a result monad — whichever the codebase and its
  libraries already support. Never a bool success flag a caller can ignore.
  `Try`-style returns are reserved for failures the process must survive
  (lookup misses, parse attempts).
- **Exceptions keep their detail.** A catch handles, wraps with context, or
  rethrows — it never swallows. A catch that deliberately does nothing says
  why in a comment; a rethrow carries the original exception and stack, not
  a copy that loses them (.NET: `throw;`, CA2200).
- **Time is injected I/O.** The clock crosses the same boundary as any other
  input — injected as a dependency, never read from static ambient
  properties (.NET: `TimeProvider`, not `DateTime.Now`). Ambient time hides
  a dependency and makes deadlines, expiry, and timestamps untestable.
- **Complexity signals stay visible.** No mechanism that folds or scatters
  hand-written code out of sight — regions, split class declarations. A
  300-line class must look like 300 lines when someone judges it.
- **Deep modules.** Narrow interface, deep implementation. Complexity lives
  inside the module; the caller sees little of it. Pass-through layers and
  boilerplate do the opposite — they transfer complexity upward without
  reducing it. A new layer needs an answer to "what complexity does this hide?".
- **Complexity is bounded by the problem space.** The system must never be
  more complex than the problem it solves. Use it as a litmus test before
  adding a layer, a config option, or a generalization: if the added
  complexity exceeds the problem it addresses, the simplest version wins.
- **Avoid hasty abstractions (AHA / rule of three).** Prefer duplication over
  the wrong abstraction. Duplicate while the cases are only coincidentally
  similar; extract at the third occurrence, or earlier only when you can name
  the shared concept without conditions. The wrong abstraction costs more than
  duplication ever does.
- **Nothing speculative.** Write code for the behavior needed now. "For later"
  flexibility is a bet against the ladder: untested abstraction paths rot
  silently. Skip options, config, and flexibility nobody asked for — name them
  in one line instead.
- **Name ↔ type ↔ docs agree.** A plural name names a collection, a predicate
  name implies a boolean, a comment agrees with the signature. When they
  disagree, the reader must investigate usages to guess intent — that is the
  linguistic anti-pattern. Fix by aligning the three, not by adding comments.
- **Comments carry why, not what.** Code states what; comments state the
  reason the code cannot show. A known shortcut is flagged inline:
  `shortcut: <the limit>, <when to upgrade>`. Debt nobody flagged is debt
  nobody will prioritize — the death-by-a-thousand-cuts pattern kills
  codebases through unflagged small cuts, never through one big mistake.

## Organization

Position is a contract with the reader:

- **One order per module.** Every module places its symbols in the same
  order — its data first, then its public surface, then its internals — so
  a reader navigates by position and a review notices the missing piece at
  its known place (.NET member order: references/csharp.md).
- **Colocate by user story.** In story-driven codebases (CQRS, vertical
  slices) the whole story lives in one file, ordered as it executes: the
  command or query, its dependencies, what it returns, its validators, its
  handler. A layer-first split (`Command.cs`, `Handler.cs`...) scatters the
  story and hides the whole from the diff and the review.

## Tests as knowledge

A test encodes knowledge about expected behavior. The assertion is the
knowledge; arrange and act are context. Coverage measures execution, not
knowledge — treat it as a signal of where tests are missing, never as proof
they are good. Apply the desiderata (`references/testing.md`) when writing or
reviewing tests.

- Ship the knowledge with the behavior: every behavior you add or change comes
  with assertions encoding it — the test precedes the code it demands, never
  the reverse. Code without tests is, by definition, code being degraded.
- One authoritative representation: the same knowledge appears in exactly one
  test. Duplication without detection power is noise; two tests that share
  lines but encode different knowledge are fine.
- Organize by business operation: one `<Operation>Should` class per operation,
  named for the operation itself (`ReserveSkuShould`). Passing methods state
  the business outcome in plain words; failures live in a nested `Fail` class
  as `When_<business reason>` methods.
  Runner output then reads as sentences:
  `ReserveSkuShould.Fail.When_available_stock_is_insufficient`. A method name
  states a fact the business would recognize — never `Test1` or `Should_Throw`.
  State it as the action the behavior performs: active voice, conjugated on
  what happens when the operation runs (`Decrements_the_available_level_of_the_reserved_sku`,
  `Turns_a_valid_supplier_row_into_an_order_line`) — never a passive,
  past-state description of a result (`A_row_is_mapped_to_an_order_line`).
  A mechanism verb is fine when the mechanism is the contract, but the action
  stays the subject of the sentence.
- Crystallize rules where they live: a type with behavior (aggregate, value
  object) gets its own `<Type>Should` tests stating each business rule
  directly. Transitive coverage through a higher-level API neither expresses
  nor details the rule — it never substitutes for the rule's own test.
- Atomic: one action on the system and one expectation per test. A second
  action is a second test — combined actions hide which one caused a failure.
  Several assertions on the consequences of that single action are fine;
  several actions are not.
- Fakes are a loan against the real thing. Domain tests may mock external
  calls (databases, APIs) to stay fast and deterministic — but the mocked
  boundary must itself be tested where it meets the real world: integration
  tests through Testcontainers for shared infrastructure (databases, brokers),
  provider/consumer contract tests for HTTP perimeters. The real
  implementation must prove it honors the same contract the fake pretends to
  honor; green domain tests behind an unverified fake say nothing about
  production. The fast tier and the proof tier live in separate test projects:
  the fast tier runs everywhere, the proof tier runs where the infrastructure
  exists.
- Snapshots for complex structures, explicit assertions for critical values.
  When output has many fields (API responses, documents), a snapshot test
  replaces dozens of assertions; where an undetected field change would have
  business impact, add an explicit assertion beside the snapshot. Approve a
  snapshot diff only after reading it.

## Test first, one cycle at a time

No application code without a failing test that demands it — domain types,
value objects, handlers included. Work one cycle at a time, never two tests
ahead:

1. Write ONE test — the next knowledge, and nothing else.
2. Run it: red. A failing compile on the not-yet-existing type counts, but it
   is not sufficient on its own: get past the compile error with a stub that
   does nothing — silent return, default value, non-action; never a thrown
   exception or any staged failure — and watch the test fail once on its
   assertion. That data red is what makes the later green prove the rule
   instead of a vacuous pass.
3. Write the smallest application code that turns it green — nothing the test
   does not demand: no message, no property, no branch beyond the failing
   assertion.
4. Refactor only if the code asks for it; the suite stays green. Extracting a
   type is fine — but a type that carries behavior must then get its own tests
   crystallizing its rules.
5. Next cycle.

Order the cycles: blocking cases first (`Fail.When_*` — the contract of what
must be refused, its whole surface pinned: inputs, unknown references,
boundary values). Every default or fallback the code supplies — a lookup
that answers 0 for an unknown key, a default entity, an optional absent
value — is knowledge like any other: a test states the fallback behavior
explicitly; nothing fallback-driven stays implicit behind a computation.
Then passing cases from simplest to most complex. One test asserts one
business knowledge; a knowledge asserted anywhere is never re-asserted in
another test.

One at a time is a seriality rule, not a permission rule: the session keeps
flowing from cycle to cycle. What it forbids is open cycles — writing test
N+1 while N is still red, implementing code for a future test, batching
several tests before a run. Exactly one cycle is open at any moment, and the
suite decides when it is closed.

## Paradigm

The skill targets object-oriented languages — C# first. For **native FP
languages** (F#...): judge by their own idioms — immutability, total
functions and pattern matching, narrow signatures, domain types — never
grade them with OO checklists. Everything below is the **C# fusion
profile**: one paradigm, not two gates.

- **Objects encapsulate.** An object exists to present its content and its
  capabilities to those entitled to them — intention-revealing methods, no
  exposed state. The OO rules (`references/object-oriented.md`) stay fully
  in force; the functional style relaxes nothing about encapsulation.
- **Monadic signatures when the project carries them.** A method may return
  a monad (`Result<T, TError>`, `Either`, `Option` — CSharpFunctionalExtensions,
  LanguageExt) when the user asks for it or the solution already contains
  the library or equivalent code. Never introduce a functional library
  speculatively; the vanilla fallback keeps typed business exceptions.
- **Functional internal style.** Type-system guarantees first: illegal
  states unrepresentable; functions never mutate their parameters. Express
  intent, not mechanics: `Where`/`Select`/composition over `foreach` + `if`,
  switch expressions over `if`/`else` chains, names state business intent.
  These style rules hold whether or not a monad library is present.
  Internal mutability is a role decision, not a paradigm one: an aggregate
  may keep guarded, encapsulated transitions while value objects stay
  immutable (`references/object-oriented.md` profiles).
- **Railway composition.** Inside the module, compose (`Map`/`Bind`/`Tee`)
  and defer unwrapping to the last responsible moment: the monad is unfolded
  once, at the outermost boundary (HTTP response, final log) — never
  `Match`ed away mid-domain. Logging rides at decision points (on
  success/failure side steps; writer-style accumulation where the library
  offers it).
- **Tests are paradigm-blind**: `<Operation>Should` + nested `Fail.When_*`
  in every context.
- **Error channel when nothing is settled**: idiomatic to the existing
  codebase, else what the user asked; when in doubt, ask before choosing.

- **If OO, the role of the class**: domain model, persistence model, contract
  (DTO), or infrastructure. The OO reference defines a strictness profile per
  role — Object Calisthenics is strict on a pure domain model and relaxed
  where persistence or serialization dictate the shape.

## References

- **Validation layers (SPA/API)** → read `references/validation-layers.md`
  whenever a change submits, validates, or rejects data: where each check
  belongs — frontend, exposure, domain, system — and the information profile
  each layer owes its consumer.
- **C# / .NET** → read `references/csharp.md`: build hygiene, type
  comparison, resource ownership, validation layering, value objects,
  exceptions, time injection, persistence concurrency, log policy, naming,
  visibility, member and file ordering, testing conventions.
- Other languages: apply the core; propose adding a reference file when a
  language recurs.

## Definition of done

All checkable — verify each before reporting completion:

- [ ] Build passes with warnings as errors (or the project's equivalent).
- [ ] Tests pass; every behavior changed or added has assertions encoding the knowledge.
- [ ] Tests sit in `<Operation>Should` classes; every failure case is a `When_<business reason>` method in a nested `Fail`.
- [ ] Every application line was written to turn one red test green, after a data red.
- [ ] Behavior-bearing domain types carry their own rule-stating tests.
- [ ] Business failures are typed exceptions or result monads — no bool success flags.
- [ ] No knowledge you wrote is duplicated across tests; every snapshot diff was read.
- [ ] Each rule you enforced sits as high on the ladder as the project allows.
- [ ] Each check added sits at every validation layer that can carry it: shape rules at frontend AND exposure, context rules in the domain, committed-data rules enforced by schema constraints (`references/validation-layers.md`).
- [ ] The diff contains only what the task needs; violations outside it are named, not fixed.
- [ ] Every known shortcut is flagged `shortcut: <limit>, <when to upgrade>`.
