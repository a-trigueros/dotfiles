# Object-oriented craft: SOLID and Object Calisthenics

## SOLID — the baseline

All object-oriented code satisfies SOLID: Single Responsibility,
Open-Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
They are the conceptual safety net that keeps code maintainable and testable
without depending on individual vigilance — review a change through them when
the diff restructures responsibilities or dependencies.

## Object Calisthenics — training, not law

The 9 rules (Jeff Bay) are exercises that build design judgment: they force
encapsulation (3, 4, 5, 7, 8, 9), cognitive simplicity (1, 7), explicit
polymorphism over conditionals (2), and naming that reveals bad responsibility
splits (6). They are a target to move toward, not production absolutes —
rules 3 and 8 in particular over-fragment code when applied mechanically.
Apply them through the situation profiles below.

1. **One level of indentation per method** — extract a method per nesting
   level; each method then reads as one idea.
2. **No `else` keyword** — polymorphism or early return expresses the branch;
   `else` hides which condition led where.
3. **Wrap primitives and strings** *(judgment)* — a primitive that carries
   domain meaning becomes a value object (`EmailAddress`, `Money`); a bare
   counter inside an algorithm stays bare.
4. **First-class collections** — a collection gets its own type; filtering and
   traversal logic lives with the collection, not its consumers.
5. **One dot per line (Law of Demeter)** — talk to immediate collaborators
   only; chains of calls couple you to a stranger's internals.
6. **No abbreviations** — a name you cannot say aloud hides a concept that
   wants extracting.
7. **Small entities** — a class over ~50 lines usually holds two concepts;
   splitting it raises cohesion.
8. **Max two instance variables** *(judgment)* — more than two usually means a
   missing concept; extract only when you can name it.
9. **No getters/setters (Tell, Don't Ask)** — send the object the behavior,
   not a request for its state to decide elsewhere.

## Situation profiles

Grade code with the profile of its role, never by file. When one class spans
two roles (a domain entity that is also an ORM entity), apply the looser
profile to the persistence surface, the stricter one to the domain surface,
and say so to the user — the separation itself is worth naming.

**D — Domain model (pure)** — target all 9 rules. Rule 3 wraps primitives that
carry domain meaning; rule 8 is a smell detector, not a law. This profile is
where the judgment that rules 3 and 8 train becomes visible.

**P — Persistence model (ORM entities, EF)** — rules 1, 6, 7 apply. Rule 3
relaxed: scalar columns stay scalar. Rule 8 relaxed: many columns → many
properties is persistence's cost, not a design flaw. Rule 9 relaxed for
properties the ORM materializes; encapsulation is enforced at the aggregate
boundary instead. Never restructure persistence classes to pass calisthenics;
propose extracting a separate domain model only if the user asks.

**C — Contract (DTO, API payload, serialization shape)** — exempt from rules
3, 8, 9: data shapes by nature. Rule 6 and the name ↔ type ↔ docs agreement
still bind.

**I — Infrastructure and framework glue** — rules are judgment. The binding
checks are the universal ones: deep module, complexity bounded by the problem
space, naming coherence.

## Functional code

These rules are OO exercises; do not grade FP code with them. The recognized
FP equivalents: immutability (≈ no setters), total functions and pattern
matching (≈ no `else`), narrow signatures (≈ few arguments), domain types
(≈ wrap primitives). Design review on FP code judges the same intents through
those idioms.
