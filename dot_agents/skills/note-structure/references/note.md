# type/note

## Definition

A Note is a low-constraint observation, scratch, or piece of context that does not
fit any of the 15 other types — or that has not yet been atomized into one.

A Note answers the question: "this has value, but I don't need to reason from it."
If any of the 15 other types fits → use that type.
If uncertain → use `note` and revisit later.

---

## Two modes

A Note is either transitional or permanent. Both are valid.

**Transitional** — a pre-atomized observation waiting to be formalized into the right type.
The content has potential but the type is not yet clear, or the atomization hasn't happened.
The agent may suggest a more precise type when encountering a transitional note.

**Permanent** — content with contextual value that does not warrant formalization.
The agent does not need to reason _from_ it — it just needs to know it exists.
Examples: trivia, personal interests, cultural references, informal observations.

A Note does not need a `status` field to distinguish these two modes.
If the content eventually warrants atomization, the note is replaced by the appropriate type.
If it never does, it stays a note indefinitely.

---

## What belongs here

- Trivia and historical context (history of .NET, origin of a programming language)
- Personal interests with no direct reasoning value (One Piece, hobbies)
- Informal observations not yet strong enough to be a `pattern`
- Scratch thoughts captured before being structured
- Anything that has value but resists classification

---

## Scope

`global/` or `projects/<name>/` — same rules as all other types.
Most permanent notes live in `global/` — they are context, not project-specific knowledge.

---

## Frontmatter

Inherits all common fields. No additional fields required.

```yaml
---
type: note
created: YYYY-MM-DD
tags: []
edges: []
---
```

A Note has no type-specific frontmatter fields and no word limit.
It is the only type with no structural constraints on the body.

---

## Edges

All standard edge types apply. No restrictions.
A Note may have no edges at all — that is acceptable for permanent contextual notes.

A transitional note that has been atomized should be deleted, not archived.
The new typed note replaces it entirely.

---

## Body structure

No constraints. Write whatever captures the value of the content.

---

## Examples

**global/notes/note--dotnet-creation-history.md**

```yaml
---
type: note
created: 2026-02-10
tags: []
edges: []
---
```

```markdown
.NET was created at Microsoft in the late 1990s, initially as a response to Java.
Anders Hejlsberg, who had previously designed Turbo Pascal and Delphi, led the design
of C#. The first public version shipped in 2002.

Trivia with no direct reasoning value — kept for context.
```

---

**global/notes/note--one-piece.md**

```yaml
---
type: note
created: 2026-01-05
tags: []
edges: []
---
```

```markdown
One Piece is a manga and anime series by Eiichiro Oda, ongoing since 1997.
Currently following — no reasoning value, personal interest tracked here.
```

---

**projects/client-x/notes/note--kickoff-impressions.md**

```yaml
---
type: note
created: 2026-03-15
tags: []
edges:
  - target: projects/client-x/events/event--kickoff-call
    type: derived_from
    weight: 0.7
---
```

```markdown
The client team seems technically strong but has limited experience with vector search.
Onboarding on the concepts will take more time than anticipated.

Not yet strong enough to be a pattern — keeping as scratch observation.
```
