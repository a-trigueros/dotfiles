# type/playbook

## Definition

A Playbook is a repeatable procedure with steps, a trigger, and an expected outcome.
It describes how to do something in a specific context — generically and reproducibly.

A Playbook answers the question: "how is this done?"
If the answer is "what this thing is" → use `concept`.
If the answer is "when this applies, based on observation" → use `pattern`.
If the answer is "a specific action to perform now" → use `task`.

---

## Playbook vs Task

A Playbook step is a generic, repeatable instruction — valid every time the playbook runs.
Steps live in the body as free text. They are never `task` notes.

A Task is a concrete instance of work, anchored to a specific context, date, and priority.
Tasks are created when a playbook is executed. They live as separate notes in the graph.

```
playbook--onboarding-client (generic procedure)
  → followed_by → projects/client-x/task--send-confirmation-email (concrete instance)
```

---

## Precision

A playbook describe a list of step. As such it must be used as-is by a user and it's natural for it to contains code to copy-paste, configuration files, or commands to execute.

---

## Word limit

Playbooks are exempt from the 50–300 word limit.
Steps must be complete enough to be executed without additional context.

---

## Scope

`global/` — a procedure reusable across all projects.
`projects/<name>/` — a procedure specific to one project's context or tooling.

---

## Frontmatter

```yaml
---
type: playbook
created: YYYY-MM-DD
tags: []
edges: []
trigger: <free text> # condition or event that initiates this playbook
outcome: <free text> # expected result when the playbook completes successfully
---
```

### Field rules

`trigger` — the condition or event that should initiate this playbook.
Must be specific enough that the agent can recognize when the playbook applies.
Example: "a new client project is confirmed and a kick-off date is set"

`outcome` — the expected state after successful execution.
Must be observable and unambiguous.
Example: "client has received welcome materials and first milestone is scheduled"

---

## Edges

### Outgoing edges from a Playbook

| edge           | target type | use when                                                   |
| -------------- | ----------- | ---------------------------------------------------------- |
| `depends_on`   | `concept`   | a step requires understanding this concept first           |
| `depends_on`   | `pattern`   | this playbook applies only when a pattern condition is met |
| `depends_on`   | `decision`  | this playbook was shaped by a prior decision               |
| `depends_on`   | `playbook`  | a step delegates to another playbook                       |
| `followed_by`  | `task`      | a concrete task generated when this playbook is executed   |
| `derived_from` | `playbook`  | this playbook was created based on a prior version         |

### Incoming edges toward a Playbook

| edge           | from type        | use when                                                  |
| -------------- | ---------------- | --------------------------------------------------------- |
| `depends_on`   | `playbook`       | another playbook delegates a step here                    |
| `derived_from` | `playbook`       | a later version traces its lineage here                   |
| `supports`     | `pattern` `fact` | evidence that this playbook produces the expected outcome |

---

## Body structure

```markdown
### Trigger

[Condition or event that initiates this playbook — mirrors the frontmatter field.]

### Steps

1. [Step one — specific and executable.]
2. [Step two.]
   ...

### Expected outcome

[Observable state after successful completion — mirrors the frontmatter field.]

### Notes

[Optional: edge cases, known failure modes, or context-specific variations.]
```

Steps must be written so the agent can execute or delegate them without ambiguity.
If a step requires a full procedure of its own, extract it into a separate playbook
and reference it via a `depends_on` edge.
If a playbook target a technical aspect, it has the value of basic knowledge.
As such, it is intended that the user only have to copy-paste and adapt some examples.
If the target of the playbook is about code, some code samples must be there.

---

## Examples

**global/playbooks/playbook--weekly-review.md**

```yaml
---
type: playbook
created: 2026-01-25
trigger: "every monday morning before starting work"
outcome: "week is planned, open tasks are prioritized, open questions are reviewed"
tags: []
edges:
  - target: global/concepts/concept--time-blocking
    type: depends_on
    weight: 0.8
---
```

```markdown
### Trigger

Every monday morning before starting work.

### Steps

1. Review all open `task` notes and update priorities.
2. Review all open `question` notes — surface any that have become testable as hypotheses.
3. Review all `decision` notes without `decided_on` — identify any that can be closed this week.
4. Block time slots for the three highest priority tasks.
5. Identify one question to actively research during the week.

### Expected outcome

Week is planned, open tasks are prioritized, open questions are reviewed.

### Notes

If a task has been open for more than two weeks without progress, add a `blocked` note
in the task body and create a linked `question` to investigate the blocker.
```

---

**projects/client-x/playbooks/playbook--onboarding-client.md**

```yaml
---
type: playbook
created: 2026-03-01
trigger: "a new client project is confirmed and a kick-off date is set"
outcome: "client has received welcome materials and first milestone is scheduled"
tags: []
edges:
  - target: global/playbooks/playbook--weekly-review
    type: depends_on
    weight: 0.7
  - target: projects/client-x/decisions/decision--use-linear-for-tasks
    type: depends_on
    weight: 0.8
---
```

```markdown
### Trigger

A new client project is confirmed and a kick-off date is set.

### Steps

1. Create project namespace in vault under `projects/<client-name>/`.
2. Load client Pillars if provided — create `pillar` notes under `projects/<client-name>/pillars/`.
3. Send welcome email with project scope, timeline, and first deliverable.
4. Schedule kick-off call and add as an `event` note.
5. Create initial `task` notes for first milestone in Linear.
6. Run weekly-review playbook to integrate new project into planning.

### Expected outcome

Client has received welcome materials, kick-off is scheduled,
and first milestone tasks exist in Linear.

### Notes

If client Pillars contradict global Pillars, create explicit `contradicts` edges
between them before starting any work.
```
