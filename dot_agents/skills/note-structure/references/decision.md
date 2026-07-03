# type/decision

## Definition

A Decision is a concrete choice made between alternatives at a point in time.
It records what was chosen, why it was chosen over the alternatives, and what it depends on.

A Decision answers the question: "what was chosen, and why?"
If the answer is "what I believe or value" → use `pillar`.
If the answer is "what this thing is" → use `concept`.
If the answer is "what needs to be done" → use `task`.

---

## Scope

A Decision's scope is inferred from its vault path.

`global/` — rare. A decision that applies across all contexts with no project anchor.
`projects/<name>/` — the standard case. A decision made within a specific project context.

---

## Frontmatter

```yaml
---
type: decision
created: YYYY-MM-DD # date the decision was made
tags: []
edges: []
decided_on: YYYY-MM-DD # date the decision was made — may differ from created
alternatives: [] # slugs of notes representing rejected alternatives
reversible: true # true | false — can this decision be revisited?
---
```

### Field rules

`decided_on` — the date the decision was actually made. `created` is when the note entered
the vault — these may differ if the decision was documented after the fact.
Absent means the decision is still being evaluated. The agent treats a Decision
without `decided_on` as an open evaluation, not a fixed premise.

`alternatives` — full vault paths of notes representing the options that were not chosen.
These notes may be `concept`, `decision` (a rejected path), or `note` stubs.
The agent uses this list to understand the decision space without traversing the full graph.

`reversible` — signals to the agent whether this decision is a hard constraint or an open question.
A non-reversible decision (false) is treated as a fixed premise during reasoning.
A reversible decision (true) may be surfaced as a candidate for reconsideration.

---

## Edges

### Outgoing edges from a Decision

| edge              | target type    | use when                                             |
| ----------------- | -------------- | ---------------------------------------------------- |
| `depends_on`      | `pillar`       | this decision is grounded in a Pillar conviction     |
| `depends_on`      | `fact`         | this decision relies on a verified fact being true   |
| `depends_on`      | `concept`      | this decision requires understanding a concept first |
| `contradicted_by` | `pillar`       | this decision deliberately overrides a global Pillar |
| `contradicted_by` | `decision`     | this decision supersedes a previous decision         |
| `derived_from`    | `decision`     | this decision was made based on a prior decision     |
| `followed_by`     | `event` `task` | consequence or action triggered by this decision     |

### Incoming edges toward a Decision

| edge              | from type                                                                                                   | use when                                            |
| ----------------- | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `derived_from`    | `decision`                                                                                                  | a former decision traces its lineage here           |
| `contradicted_by` | `pillar` `concept` `bookmark` `source` `reference` `custom` `decision` `fact` `hypothesis` `note` `pattern` | a former decision overrides this one                |
| `supported_by`    | `pillar` `concept` `bookmark` `source` `reference` `custom` `decision` `fact` `hypothesis` `note` `pattern` | evidence that validates this decision in retrospect |

---

## Body structure

```markdown
[One sentence stating the decision plainly — what was chosen.]

[One or two sentences stating the driver — why this option over the alternatives.]
```

No headers. No enumeration of alternatives or consequences — those live in the graph.
The body must be understandable in isolation: someone reading only this note must know
what was decided and the core reason, without needing to traverse edges.

---

## Examples

**projects/client-x/decision--use-cosine-for-search.md**

```yaml
---
type: decision
created: 2026-03-12
decided_on: 2026-03-10
alternatives:
  - projects/client-x/concept--dot-product-similarity
  - projects/client-x/concept--euclidean-distance
reversible: false
tags: []
edges:
  - target: global/pillars/pillar--simplicity-over-cleverness
    type: depends_on
    weight: 0.8
  - target: global/facts/fact--cosine-similarity-is-normalized
    type: depends_on
    weight: 0.8
  - target: projects/client-x/pillars/pillar--performance-is-non-negotiable
    type: contradicted_by
    weight: 1.0
---
```

```markdown
Cosine similarity will be used as the distance metric for all semantic search queries.

It produces normalized scores across different vector magnitudes, making results
directly comparable without additional calibration — the simplest option that meets
the accuracy requirement.
```

---

**global/decision--adopt-obsidian-for-knowledge-graph.md**

```yaml
---
type: decision
created: 2026-01-20
decided_on: 2026-01-18
alternatives:
  - global/concepts/concept--roam-research
  - global/concepts/concept--notion-database
reversible: true
tags: []
edges:
  - target: global/pillars/pillar--simplicity-over-cleverness
    type: depends_on
    weight: 0.8
  - target: global/pillars/pillar--ownership-of-data
    type: depends_on
    weight: 0.9
---
```

```markdown
Obsidian is the primary tool for the personal knowledge graph.

Plain markdown files with local storage satisfy the data ownership principle
and require no proprietary format, making the vault portable and agent-readable
without vendor dependency.
```
