---
name: my-craft
description: Apply the user's software craftsmanship rules whenever writing, modifying, fixing, refactoring, reviewing, or generating code in any language — including small edits, tests, configs, and generated code. Encodes the ladder of automated guarantees (compiler > analyzer > architecture test > assertion > convention), deep modules, no hasty abstractions (rule of three), make illegal states unrepresentable, tests as knowledge, naming coherence, and a paradigm gate with per-situation Object Calisthenics profiles. Read references/object-oriented.md for object-oriented code (SOLID, calisthenics profiles), references/csharp.md for any C#/.NET code.
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

## Tests as knowledge

A test encodes knowledge about expected behavior. The assertion is the
knowledge; arrange and act are context. Coverage measures execution, not
knowledge — treat it as a signal of where tests are missing, never as proof
they are good.

- Ship the knowledge with the behavior: every behavior you add or change comes
  with assertions encoding it. Code without tests is, by definition, code
  being degraded — write the test in the same change, not "after".
- One authoritative representation: the same knowledge appears in exactly one
  test. Duplication without detection power is noise; two tests that share
  lines but encode different knowledge are fine.
- Snapshots for complex structures, explicit assertions for critical values.
  When output has many fields (API responses, documents), a snapshot test
  replaces dozens of assertions; where an undetected field change would have
  business impact, add an explicit assertion beside the snapshot. Approve a
  snapshot diff only after reading it.

## Paradigm gate

Design disciplines do not transfer blindly across paradigms. Before applying
rules, classify the code you are writing:

- **Paradigm**: object-oriented → read `references/object-oriented.md`.
  Functional → judge by its own idioms: immutability, total functions and
  pattern matching, narrow signatures, domain types. Never grade FP code with
  OO checklists, or the reverse.
- **If OO, the role of the class**: domain model, persistence model, contract
  (DTO), or infrastructure. The OO reference defines a strictness profile per
  role — Object Calisthenics is strict on a pure domain model and relaxed
  where persistence or serialization dictate the shape.

## Language references

- **C# / .NET** → read `references/csharp.md`: build hygiene, type
  comparison, resource ownership, validation layering, log policy, naming,
  testing conventions.
- Other languages: apply the core; propose adding a reference file when a
  language recurs.

## Definition of done

All checkable — verify each before reporting completion:

- [ ] Build passes with warnings as errors (or the project's equivalent).
- [ ] Tests pass; every behavior changed or added has assertions encoding the knowledge.
- [ ] No knowledge you wrote is duplicated across tests; every snapshot diff was read.
- [ ] Each rule you enforced sits as high on the ladder as the project allows.
- [ ] The diff contains only what the task needs; violations outside it are named, not fixed.
- [ ] Every known shortcut is flagged `shortcut: <limit>, <when to upgrade>`.
