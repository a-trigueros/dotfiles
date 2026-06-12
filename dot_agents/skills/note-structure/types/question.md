# type/question

## Definition

A Question is a known unknown being actively tracked.
It represents a gap in knowledge that has been identified and formalized,
but not yet resolved.

A Question answers the meta-question: "what do I not yet know?"
If the answer already exists and needs to be defined → use `concept`.
If the answer already exists and is verifiable → use `fact`.
If a choice needs to be made but hasn't been → use `decision` without `decided_on`.

---

## Lifecycle

A Question is open until it resolves into another note type via `becomes`.

| resolves to  | when                                             |
| ------------ | ------------------------------------------------ |
| `hypothesis` | the unknown is now testable but not yet verified |
| `fact`       | the answer was found and is directly verifiable  |
| `concept`    | the answer is a definition or framework          |

A Question without `becomes` is an active unknown.
The agent may surface open Questions as knowledge gaps when reasoning in their domain.

A Question is never updated with the answer — it resolves by pointing to the note
that contains the answer. The Question remains in the vault as a record of the gap.

---

## Scope

`global/` — a question about a concept, fact, or domain independent of any project.
`projects/<name>/` — a question that arose in a specific project context.

---

## Frontmatter

```yaml
---
type: question
created: YYYY-MM-DD
tags: []
edges: []
area: <free text> # domain or subject area this question belongs to
becomes: <full vault path> # full path of the note this question resolved into
---
```

### Field rules

`area` — a short free-text label for the domain this question belongs to
(e.g. `vector search`, `client relations`, `nutrition`).
Used by the agent to group and surface related open questions without full graph traversal.

`becomes` — full vault path of the note this question resolved into, without `.md`.
Absent means the question is still open.
Once set, the question is considered closed — the agent does not surface it as an active gap.

---

## Edges

### Outgoing edges from a Question

| edge           | target type              | use when                                                       |
| -------------- | ------------------------ | -------------------------------------------------------------- |
| `derived_from` | `concept` `fact` `event` | the question arose from engaging with this note                |
| `related_to`   | `question`               | two open questions are topically connected — requires `reason` |
| `part_of`      | `question`               | this question is a sub-question of a broader one               |

### Incoming edges toward a Question

| edge           | from type                     | use when                                  |
| -------------- | ----------------------------- | ----------------------------------------- |
| `derived_from` | `hypothesis` `concept` `fact` | the resolving note traces its origin here |

---

## Body structure

```markdown
[The question, stated plainly as a question.]

[Optional: context — what triggered this question, or why it matters.]
```

The question must be specific enough that the agent can recognize when it has been answered.
Vague questions ("how does ML work?") should be broken into atomic sub-questions.

---

## Examples

**global/questions/question--pgvector-latency-at-scale.md**

```yaml
---
type: question
created: 2026-02-10
area: vector search
becomes: global/facts/fact--pgvector-latency-1m-vectors
tags: []
edges:
  - target: global/concepts/concept--vector-embeddings
    type: derived_from
    weight: 0.9
---
```

```markdown
What is the p99 query latency of pgvector on a 1 million vector index
with cosine similarity and no approximate search (exact KNN)?
```

---

**projects/client-x/questions/question--why-search-recall-drops-above-threshold.md**

```yaml
---
type: question
created: 2026-04-03
area: semantic search
tags: []
edges:
  - target: projects/client-x/patterns/pattern--search-recall-drop-above-0-85
    type: derived_from
    weight: 0.9
---
```

```markdown
Why does search recall drop significantly when the cosine similarity threshold
is raised above 0.85 on this corpus?

Observed consistently in staging but not yet explained. May be related
to embedding model behavior on short queries.
```
