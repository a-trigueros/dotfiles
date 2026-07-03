# type/contact

## Definition

A Contact is a person or organization with whom you have or may have a relationship.
It captures both relational metadata (how you interact) and reasoning context
(what this entity represents in your knowledge graph).

A Contact answers the question: "who is this, and what is my relationship with them?"
If the entity is purely a concept to reason about with no relational dimension → use `concept`.

---

## Person vs Organization

A Contact can be a person or an organization. The `org` field distinguishes them.

Organizations contain people — individual contacts are linked to their organization
via `part_of`. This allows the agent to navigate from a person to their organization
and from an organization to all its known contacts.

```
contact--anthropic (org: true)
  ← part_of ← contact--dario-amodei
  ← part_of ← contact--amanda-askell
```

---

## Scope

`global/contacts/` — a contact independent of any specific project.
`projects/<name>/contacts/` — a contact relevant primarily within one project context.

A client organization and its team members typically live under the project namespace.
Recurring collaborators or personal contacts live under `global/contacts/`.

---

## Frontmatter

```yaml
---
type: contact
created: YYYY-MM-DD
tags: []
edges: []
org: false # true if this contact is an organization
role: <free text> # optional — role or title
company: <full vault path> # optional — org contact this person belongs to
channel: email | linkedin | phone | slack | other # optional — preferred contact channel
last_contact: YYYY-MM-DD # optional — date of last meaningful interaction, persons only
---
```

### Field rules

`org` — default `false`. Set to `true` for organizations, companies, or institutions.
Organization contacts do not use `last_contact` or `channel` at the org level —
these are tracked on individual person contacts.

`role` — free text describing the person's role or title, or the organization's domain.
Examples: "ML researcher", "lead engineer", "AI safety lab"

`company` — full vault path of the organization contact this person belongs to.
Only for person contacts. Mirrors the `part_of` edge for quick lookup.

`channel` — preferred or primary communication channel for this person.

`last_contact` — date of the last meaningful interaction. Persons only.
Helps the agent surface contacts that have gone quiet or need follow-up.

---

## Edges

### Outgoing edges from a Contact

| edge          | target type          | use when                                          |
| ------------- | -------------------- | ------------------------------------------------- |
| `part_of`     | `contact` (org)      | this person belongs to this organization          |
| `related_to`  | `contact`            | two contacts are connected — requires `reason`    |
| `related_to`  | `concept` `decision` | this contact is relevant to a topic or decision   |
| `authored_by` | any                  | a note whose content originates from this contact |

### Incoming edges toward a Contact

| edge          | from type          | use when                                   |
| ------------- | ------------------ | ------------------------------------------ |
| `part_of`     | `contact` (person) | a person who belongs to this organization  |
| `authored_by` | any                | a note that originated from this contact   |
| `related_to`  | any                | a note topically connected to this contact |

---

## Body structure

```markdown
[One or two sentences describing who this person or organization is,
and what their relevance is to your knowledge graph.]

[Optional: context about the relationship — how you met, what you collaborate on,
what makes this contact significant.]
```

No headers. The body should give the agent enough context to understand
why this contact exists in the vault and how they connect to your work.

---

## Examples

**global/contacts/contact--anthropic.md**

```yaml
---
type: contact
created: 2026-01-10
org: true
role: "AI safety and research company"
tags: []
edges:
  - target: global/concepts/concept--large-language-models
    type: related_to
    weight: 0.3
    reason: "Anthropic is a primary source of LLM research and tooling used in this vault"
---
```

```markdown
Anthropic is an AI safety company and the creator of the Claude model family.
Primary relationship as an API provider and research reference for LLM work.
```

---

**global/contacts/contact--dario-amodei.md**

```yaml
---
type: contact
created: 2026-01-10
org: false
role: "CEO, Anthropic"
company: global/contacts/contact--anthropic
channel: linkedin
last_contact: 2026-03-15
tags: []
edges:
  - target: global/contacts/contact--anthropic
    type: part_of
    weight: 0.8
---
```

```markdown
Dario Amodei is the CEO and co-founder of Anthropic.
Followed for research direction and AI safety thinking.
```

---

**projects/client-x/contacts/contact--client-x.md**

```yaml
---
type: contact
created: 2026-03-01
org: true
role: "Client — semantic search project"
tags: []
edges:
  - target: projects/client-x/pillars/pillar--performance-is-non-negotiable
    type: related_to
    weight: 0.5
    reason: "organization whose values define the project pillar"
---
```

```markdown
Client-x is the primary client for the semantic search project.
A mid-size e-commerce company focused on improving product discovery.
```

---

**projects/client-x/contacts/contact--jane-doe.md**

```yaml
---
type: contact
created: 2026-03-01
org: false
role: "CTO, client-x"
company: projects/client-x/contacts/contact--client-x
channel: email
last_contact: 2026-04-10
tags: []
edges:
  - target: projects/client-x/contacts/contact--client-x
    type: part_of
    weight: 0.8
---
```

```markdown
Jane Doe is the CTO of client-x and the primary technical point of contact.
Makes final decisions on infrastructure and architecture choices.
```
