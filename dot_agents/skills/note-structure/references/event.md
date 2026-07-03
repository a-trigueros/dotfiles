# type/event

## Definition

An Event is a dated occurrence that the agent reasons about temporally.
It marks a point or period in time that is relevant to the knowledge graph.

An Event answers the question: "what happened, or what will happen, and when?"
If the answer is "what was chosen between alternatives" → use `decision`.
If the answer is "a recurring procedure" → use `playbook`.
If the answer is "an action to perform" → use `task`.

---

## Temporal scope

An Event is either punctual or extended.

**Punctual** — a single point in time. Only `date` is set.
Examples: a release deployed, a decision made public, an incident occurred.

**Extended** — a period with a start and an end. Both `date` and `end_date` are set.
Examples: a project phase, a client engagement, a conference attended.

A future event is valid — `date` may be in the future.
The agent uses `date` to reason about sequence, recency, and anticipation.

---

## Scope

`global/` — an event independent of any specific project.
`projects/<name>/` — an event anchored to a project context.

---

## Frontmatter

```yaml
---
type: event
created: YYYY-MM-DD
tags: []
edges: []
date: YYYY-MM-DD # required — date the event occurs or occurred
end_date: YYYY-MM-DD # optional — only for extended events
---
```

### Field rules

`date` — the date the event occurs. Required. May be past or future.
For extended events, this is the start date.

`end_date` — the end date for extended events. Absent means the event is punctual.
If an extended event has no known end date yet, leave absent until confirmed.

---

## Edges

### Outgoing edges from an Event

| edge           | target type | use when                                      |
| -------------- | ----------- | --------------------------------------------- |
| `preceded_by`  | `event`     | this event comes after another event in time  |
| `followed_by`  | `event`     | this event comes before another event in time |
| `derived_from` | `decision`  | this event was triggered by a decision        |
| `part_of`      | `event`     | this event is part of a larger extended event |
| `related_to`   | any         | topical connection — requires `reason`        |

### Incoming edges toward an Event

| edge           | from type             | use when                                             |
| -------------- | --------------------- | ---------------------------------------------------- |
| `followed_by`  | `decision` `playbook` | the decision or playbook triggered this event        |
| `preceded_by`  | `event`               | a later event references this one as its predecessor |
| `part_of`      | `event`               | a sub-event that belongs to this extended event      |
| `derived_from` | `fact` `pattern`      | a note that emerged from observing this event        |

---

## Body structure

```markdown
[One sentence describing what occurred or will occur.]

[Optional: context, significance, or what this event changes or triggers.]
```

No headers. The body should be readable as a temporal anchor —
what happened, not an exhaustive account.

---

## Examples

**projects/client-x/events/event--kickoff-call.md**

```yaml
---
type: event
created: 2026-03-01
date: 2026-03-15
tags: []
edges:
  - target: projects/client-x/decisions/decision--use-cosine-for-search
    type: derived_from
    weight: 0.9
  - target: projects/client-x/events/event--first-delivery
    type: followed_by
    weight: 0.7
---
```

```markdown
Kick-off call with client-x to align on project scope, technical stack, and first milestone.

Confirmed the semantic search direction and agreed on a 6-week delivery timeline.
```

---

**global/events/event--anthropic-claude-4-release.md**

```yaml
---
type: event
created: 2026-01-10
date: 2026-01-08
tags:
  - global/concepts/concept--large-language-models
edges:
  - target: global/facts/fact--claude-4-context-window
    type: followed_by
    weight: 0.7
---
```

```markdown
Anthropic released Claude 4, marking a significant capability jump in context length
and instruction following.
```

---

**projects/client-x/events/event--project-phase-1.md**

```yaml
---
type: event
created: 2026-03-15
date: 2026-03-15
end_date: 2026-04-30
tags: []
edges:
  - target: projects/client-x/events/event--kickoff-call
    type: preceded_by
    weight: 0.7
---
```

```markdown
Phase 1 of the client-x project — semantic search implementation.

Covers embedding pipeline, pgvector setup, and initial query interface.
```
