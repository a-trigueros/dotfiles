# type/pattern

## Definition

A Pattern is an empirically observed regularity in data or behavior.
It describes what consistently happens in practice — a heuristic grounded in observation,
not derived logically from a definition.

A Pattern answers the question: "what do I consistently observe happening?"
If the regularity follows logically from a definition → include it in the `concept` body.
If the regularity has been formalized into a testable prediction → use `hypothesis`.
If the regularity has been verified and is stated as truth → use `fact`.

---

## Relationship to Hypothesis and Fact

A Pattern may generate a Hypothesis, but it does not disappear once one exists.
The Pattern retains its value as an empirical observation independently of whether
it has been explained or tested.

```
pattern → (generates) → hypothesis → (tested) → fact
fact → (validates) → pattern (retroactively)
```

A Pattern without a linked Hypothesis is valid and useful.
The agent can reason from a Pattern as a heuristic even without a confirmed explanation.

---

## Scope

`global/` — a regularity observed across multiple contexts.
`projects/<name>/` — a regularity observed specifically within one project.

---

## Frontmatter

```yaml
---
type: pattern
created: YYYY-MM-DD
tags: []
edges: []
observed_in: [] # full vault paths of notes where the pattern was observed
strength: weak | moderate | strong # how consistently the pattern holds
---
```

### Field rules

`observed_in` — list of full vault paths of `event`, `fact`, or `note` instances
where the pattern was observed. Grounds the pattern in concrete occurrences.
At least one entry is expected — a pattern with no observations is a speculation, not a pattern.

`strength` — how consistently the pattern holds across observations.
`weak` — observed a few times, may be coincidental.
`moderate` — observed repeatedly across different conditions.
`strong` — holds consistently without known exceptions.

---

## Edges

### Outgoing edges from a Pattern

| edge           | target type            | use when                                               |
| -------------- | ---------------------- | ------------------------------------------------------ |
| `supports`     | `hypothesis`           | this pattern motivated or reinforces a hypothesis      |
| `supports`     | `concept`              | this pattern provides empirical evidence for a concept |
| `supports`     | `decision`             | this pattern informed a decision                       |
| `contradicts`  | `pattern` `hypothesis` | this pattern conflicts with another observation        |
| `derived_from` | `event` `fact`         | this pattern was identified from a specific source     |
| `related_to`   | any                    | topical connection — requires `reason`                 |

### Incoming edges toward a Pattern

| edge           | from type        | use when                                             |
| -------------- | ---------------- | ---------------------------------------------------- |
| `supports`     | `fact`           | a verified fact retroactively validates this pattern |
| `contradicts`  | `fact` `pattern` | a fact or pattern that challenges this observation   |
| `derived_from` | `hypothesis`     | a hypothesis that traces its origin to this pattern  |

---

## Body structure

```markdown
[One sentence stating the regularity plainly — what consistently happens.]

[Context: where and under what conditions it has been observed.
How strong and consistent the pattern is. Any known exceptions or boundary conditions.]
```

The statement must be specific enough that the agent can recognize when the pattern applies
and when it does not. Vague patterns ("things get complicated") are not actionable.

---

## Examples

**projects/client-x/patterns/pattern--recall-drops-above-threshold.md**

```yaml
---
type: pattern
created: 2026-03-28
observed_in:
  - projects/client-x/events/event--search-benchmark-march
  - projects/client-x/events/event--search-benchmark-april
strength: strong
tags: []
edges:
  - target: projects/client-x/hypotheses/hypothesis--short-queries-cause-recall-drop
    type: supports
    weight: 0.7
  - target: projects/client-x/events/event--search-benchmark-march
    type: derived_from
    weight: 0.9
---
```

```markdown
Search recall drops consistently when the cosine similarity threshold exceeds 0.85
on the client-x corpus.

Observed across two benchmark runs in March and April under different query sets.
The drop is more pronounced on short queries but present across all query lengths.
No exceptions observed above 0.87. Below 0.83 the pattern does not hold.
```

---

**global/patterns/pattern--estimation-underestimate-above-3-days.md**

```yaml
---
type: pattern
created: 2026-02-05
observed_in:
  - projects/client-x/events/event--sprint-1-retrospective
  - projects/client-y/events/event--phase-2-review
strength: moderate
tags: []
edges:
  - target: global/concepts/concept--planning-fallacy
    type: supports
    weight: 0.7
---
```

```markdown
Development tasks estimated at more than 3 days are systematically underestimated,
typically by a factor of 1.5 to 2.

Observed across two projects in retrospectives. Does not apply to tasks under 3 days
or to well-defined tasks with clear acceptance criteria. Likely related to the
planning fallacy — optimism bias increases with task complexity and duration.
```
