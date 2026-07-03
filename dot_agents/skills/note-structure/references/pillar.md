# type/pillar

## Definition

A Pillar is an intrinsic motivation or foundational principle that orients decisions in a direction.
It is not a cause in a mechanical sense — it is a conviction, a belief, or a value.
It does not produce decisions. It defines the space within which decisions are made.

A Pillar answers the question: "what do I (or this client) fundamentally believe or value?"
If the answer is "what this thing is" → use `concept`.
If the answer is "what was chosen between alternatives" → use `decision`.

---

## Scope

A Pillar's scope is inferred from its vault path. No `scope` field needed.

`global/pillars/` — personal convictions, stable across all contexts.
`projects/<name>/pillars/` — client or project convictions, active only in that context.

### Priority rules

When operating in a project context, the agent must load:

1. All Pillars from `global/pillars/`.
2. All Pillars from `projects/<name>/pillars/`.

Project Pillars may complement or contradict global Pillars.
A project Pillar with a `contradicts` edge toward a global Pillar overrides it in this context.
A project Pillar with a `supports` edge toward a global Pillar reinforces it.
A project Pillar with no edge toward any global Pillar adds a new conviction for this context.

---

## Auto-injection

Pillars are loaded automatically at the start of every session, before any reasoning begins.
They are never retrieved on demand — they are always active context.

The agent must treat all loaded Pillars as silent constraints:
every decision, recommendation, or plan must be consistent with active Pillars
unless an explicit `contradicts` edge justifies a local override.

---

## Frontmatter

Inherits all common fields. No additional fields required.

```yaml
---
type: pillar
created: YYYY-MM-DD
tags: []
edges: []
---
```

---

## Edges

### Outgoing edges from a Pillar

| edge              | use when                                                                         |
| ----------------- | -------------------------------------------------------------------------------- |
| `supported_by`    | this Pillar is reinforced by another Pillar                                      |
| `contradicted_by` | this Pillar conflicts with another Pillar (typically project → global direction) |
| `related_to`      | topical connection to another Pillar or Concept — requires `reason`              |

A Pillar does not point to Decisions. The direction is always Decision → Pillar.

### Incoming edges toward a Pillar

| edge              | from type                                                                                                   | use when                                                             |
| ----------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `depends_on`      | `decision`                                                                                                  | the decision is grounded in this Pillar                              |
| `contradicted_by` | `decision`                                                                                                  | the decision deliberately overrides this Pillar in a project context |
| `supported_by`    | `pillar` `concept` `bookmark` `source` `reference` `custom` `decision` `fact` `hypothesis` `note` `pattern` | a project Pillar reinforces this global Pillar                       |

---

## Body structure

```markdown
[One or two sentences stating the conviction plainly.]

[Optional: what this means in practice — concrete behaviors or orientations it implies.]
```

No headers. No lists unless the practical implications genuinely require enumeration.
The Pillar must be understandable in isolation — it cannot assume the reader knows the context.

---

## Examples

**global/pillars/pillar--simplicity-over-cleverness.md**

```yaml
---
type: pillar
created: 2026-01-15
tags: []
edges:
  - target: global/pillars/pillar--long-term-maintainability
    type: supports
    weight: 0.7
---
```

```markdown
A simple solution that someone else can understand and maintain tomorrow
is worth more than a clever one that solves the problem optimally today.

This means favoring readability over performance when the tradeoff is real,
choosing well-known patterns over novel ones, and treating complexity as a cost
that must be justified, not a feature.
```

---

**projects/client-x/pillars/pillar--performance-is-non-negotiable.md**

```yaml
---
type: pillar
created: 2026-03-10
tags: []
edges:
  - target: global/pillars/pillar--simplicity-over-cleverness
    type: contradicts
    weight: 1.0
---
```

```markdown
For this client, response time under 100ms is a hard product requirement.
Performance constraints take precedence over code simplicity when the two conflict.
```
