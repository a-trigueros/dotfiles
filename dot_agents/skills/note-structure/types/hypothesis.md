# type/hypothesis

## Definition

A Hypothesis is a falsifiable prediction with a measurable test.
It formalizes a question or pattern into a statement that can be confirmed or refuted.

A Hypothesis answers the question: "what do I predict, and how would I know if I'm wrong?"
If the prediction has already been tested and confirmed → use `fact`.
If the regularity has been observed but not yet formalized → use `pattern`.
If the unknown is not yet testable → use `question`.

---

## Origin

A Hypothesis can be born from two sources:

**From a Pattern** — an observed regularity is formalized into a testable prediction.
The Hypothesis explains _why_ the pattern holds.

**From a Source** — a reference suggests a causal relationship worth testing.
No pattern observation required — the hypothesis is motivated by external knowledge.

In both cases, `derived_from` traces the origin.

---

## Lifecycle

A Hypothesis is open until it resolves into a `fact` via testing.
Unlike a `question`, a Hypothesis does not disappear once resolved —
it remains in the vault as a record of the reasoning process.

```
hypothesis → (tested) → fact
fact → contradicts or supports → hypothesis (closes the loop)
```

`hyp_status` tracks where the hypothesis is in its lifecycle.
The agent must not use a rejected hypothesis as a premise.

---

## Scope

`global/` — a prediction about a concept, tool, or domain independent of any project.
`projects/<name>/` — a prediction formulated within a specific project context.

---

## Frontmatter

```yaml
---
type: hypothesis
created: YYYY-MM-DD
tags: []
edges: []
hyp_status: open | testing | validated | rejected # required
test: <free text> # required — what would confirm or refute this hypothesis
outcome: <free text> # result of the test, once completed
---
```

### Field rules

`hyp_status` — lifecycle state of the hypothesis.
`open` — formulated but not yet being tested.
`testing` — a test is actively underway.
`validated` — the test confirmed the prediction. A linked `fact` should exist.
`rejected` — the test refuted the prediction. A linked `fact` should exist.

The agent must not reason from a hypothesis with `hyp_status: rejected` as a premise.
A rejected hypothesis remains in the vault as a record — it informs future reasoning
about what was tried and disproven.

`test` — a concrete, observable description of what would confirm or refute the hypothesis.
Must be specific enough that the agent can recognize when the test has been completed.
Vague tests ("see if it works better") are not acceptable.

`outcome` — free text describing what the test produced. Absent until the test is complete.
Once set, `hyp_status` should be `validated` or `rejected`.

---

## Edges

### Outgoing edges from a Hypothesis

| edge           | target type      | use when                                                |
| -------------- | ---------------- | ------------------------------------------------------- |
| `derived_from` | `pattern`        | this hypothesis was formalized from an observed pattern |
| `derived_from` | `source`         | this hypothesis was motivated by an external reference  |
| `derived_from` | `question`       | this hypothesis resolves an open question               |
| `depends_on`   | `concept` `fact` | this hypothesis requires another note to be understood  |
| `followed_by`  | `fact`           | the fact produced by testing this hypothesis            |

### Incoming edges toward a Hypothesis

| edge           | from type                 | use when                                                 |
| -------------- | ------------------------- | -------------------------------------------------------- |
| `supports`     | `pattern` `fact` `source` | evidence reinforcing this hypothesis                     |
| `contradicts`  | `fact` `pattern`          | evidence refuting this hypothesis                        |
| `derived_from` | `fact`                    | a fact that traces its origin to testing this hypothesis |

---

## Body structure

```markdown
[One sentence stating the prediction plainly and specifically.]

[Optional: reasoning — why this prediction is plausible, what it would explain if true.]
```

The prediction must be falsifiable — it must be possible to imagine evidence that would
refute it. If no such evidence can be imagined, it is not a hypothesis, it is a belief.

---

## Examples

**projects/client-x/hypotheses/hypothesis--short-queries-cause-recall-drop.md**

```yaml
---
type: hypothesis
created: 2026-04-01
hyp_status: validated
test:
  "Segment queries by length (under 5 tokens vs 5+). Measure recall separately
  for each segment at threshold 0.85. If short queries have significantly lower
  recall, the hypothesis is confirmed."
outcome:
  "Short queries (under 5 tokens) showed 40% lower recall than longer queries
  above threshold 0.85. Hypothesis confirmed on 2026-04-12."
tags: []
edges:
  - target: projects/client-x/patterns/pattern--recall-drops-above-threshold
    type: derived_from
    weight: 0.9
  - target: projects/client-x/facts/fact--short-queries-recall-40pct-drop
    type: followed_by
    weight: 0.9
---
```

```markdown
Queries under 5 tokens produce less stable embeddings, which explains the recall drop
observed above the 0.85 cosine similarity threshold on the client-x corpus.

Short queries provide insufficient semantic context for the embedding model to produce
a stable representation — small variations in phrasing produce disproportionately
large angular differences in the vector space.
```

---

**global/hypotheses/hypothesis--dry-principle-reduces-vault-drift.md**

```yaml
---
type: hypothesis
created: 2026-03-05
hyp_status: open
test: "After 6 months of vault use, count notes with overlapping content.
  If atomic notes linked by edges show less duplication than free-form notes,
  the hypothesis is supported."
tags: []
edges:
  - target: global/sources/source--pragmatic-programmer
    type: derived_from
    weight: 0.7
  - target: global/concepts/concept--atomic-notes
    type: depends_on
    weight: 0.8
---
```

```markdown
Applying the DRY principle to knowledge management — one authoritative note per concept,
linked by edges rather than duplicated — reduces drift and contradiction in the vault
over time compared to free-form note-taking.

If true, this validates the atomic note architecture as a long-term knowledge management
strategy, not just a structural preference.
```
