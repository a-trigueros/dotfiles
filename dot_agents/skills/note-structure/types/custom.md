# type/custom

## Definition

A Custom note is a workspace-specific type that does not fit any of the 15 other types.
It is an escape hatch for legitimate domain needs, not a shortcut around classification.

A Custom note answers the question: "this is genuinely something none of the 15 types cover."
If any of the 15 types fits, even partially → use that type.
If uncertain → use `note` and atomize later.
Only use `custom` when you can clearly name what the type is and why it is distinct.

---

## When to use

Before creating a `custom` note, verify that none of these apply:

| if the content is...                       | use instead  |
| ------------------------------------------ | ------------ |
| a definition or framework                  | `concept`    |
| a conviction or principle                  | `pillar`     |
| a choice between alternatives              | `decision`   |
| a known unknown                            | `question`   |
| a repeatable procedure                     | `playbook`   |
| an actionable item                         | `task`       |
| a dated occurrence                         | `event`      |
| an observed regularity                     | `pattern`    |
| a testable prediction                      | `hypothesis` |
| a verified statement                       | `fact`       |
| an external reference read and synthesized | `source`     |
| an unread external reference               | `bookmark`   |
| a canonical implementation example         | `reference`  |
| a person or organization                   | `contact`    |
| unstructured or pre-atomized               | `note`       |

If none of the above fits and you can name the type clearly → proceed with `custom`.

---

## Scope

`global/` or `projects/<name>/` — same rules as all other types.

---

## Frontmatter

```yaml
---
type: custom
created: YYYY-MM-DD
tags: []
edges: []
custom_type: <free text> # required — name of this custom type
---
```

### Field rules

`custom_type` — a short, specific name for this type.
Examples: `interview`, `experiment-log`, `meeting-notes`, `retrospective`.
Vague names (`misc`, `other`, `stuff`) are not acceptable.

If the same `custom_type` appears more than three times in the vault,
consider whether it deserves a dedicated skill file under `_agent/skills/types/`.

---

## Edges

All standard edge types apply. No restrictions specific to `custom`.

---

## Body structure

No constraints. The body structure is defined by the `custom_type`.

If the same `custom_type` is used repeatedly, document its expected body structure
in a dedicated skill file to ensure consistency across notes of that type.

---

## Examples

**projects/client-x/custom/custom--kickoff-retrospective.md**

```yaml
---
type: custom
created: 2026-03-20
custom_type: retrospective
tags: []
edges:
  - target: projects/client-x/events/event--kickoff-call
    type: derived_from
    weight: 0.9
  - target: projects/client-x/patterns/pattern--recall-drops-above-threshold
    type: followed_by
    weight: 0.7
---
```

```markdown
What went well: alignment on technical stack was fast, client was well-prepared.

What to improve: scope of phase 1 was too broad — reduce to a single deliverable
per phase in future projects.

Action: update the onboarding playbook to include a scope constraint step.
```
