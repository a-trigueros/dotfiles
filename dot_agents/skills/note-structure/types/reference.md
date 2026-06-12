# type/reference

## Definition

A Reference is a resource consulted directly as a model, canonical example, or tool.
It is not read and synthesized like a `source` — it is used as-is, as a template,
implementation example, authoritative specification, or tool documentation.

A Reference answers the question: "what is the canonical resource to consult or use?"
If the resource has been read and synthesized → use `source`.
If the resource has not yet been explored → use `bookmark`.
If the resource is a person or organization → use `contact`.
If the resource defines what something _is_ → use `concept`.
If the content is context, history, or trivia about a tool with no operational value → use `note`.

---

## What belongs here

- The documentation site or repo of a tool consulted directly (FluentMigrator, SQLite, pgvector)
- A recommended usage pattern or canonical snippet for a tool
- A GitHub repository implementing a pattern you follow
- A configuration file on a network share used as a template
- A database schema used as a canonical reference
- A code snippet pinned as a canonical implementation example
- An API specification or OpenAPI schema consulted directly

What distinguishes a Reference from a Concept: a `concept` defines what something _is_
and why it exists. A `reference` is the tool or resource you _use_ — the implementation.
FluentMigrator is a `reference`. Schema migration is a `concept`.

What distinguishes a Reference from a Source: you do not synthesize it.
You point the agent to it so it can consult it directly when needed.

What distinguishes a Reference from a Note: a `reference` is **operational** — it is
consulted to do something (use a tool, apply a pattern, follow a canonical example).
If the content is knowledge *about* a tool without operational value (history, context,
comparison, trivia), it is a `note`, not a `reference`. A recommended usage pattern or
a canonical snippet qualifies as `reference` even without an external `ref` URL.

---

## Scope

`global/` — a reference reusable across projects.
`projects/<name>/` — a reference specific to one project's implementation context.

---

## Frontmatter

```yaml
---
type: reference
created: YYYY-MM-DD
tags: []
edges: []
ref: <url, path, or vault path> # required — where the resource lives
ref_type: url | file | repo | schema | snippet | tool | other # required
public: true # false if behind auth, on a private network, or restricted
---
```

### Field rules

`ref` — the location of the resource.
A URL for web resources and repos.
A network path (`\\server\docs\spec.pdf`) for enterprise shares.
A vault path for files stored inside the vault that are not notes
(e.g. `_assets/schemas/pgvector-schema.sql`).

`ref_type` — the nature of the resource.
`url` for web pages and hosted documentation.
`file` for local or network files.
`repo` for version-controlled repositories.
`schema` for data schemas, OpenAPI specs, or config schemas.
`snippet` for pinned code examples.
`tool` for libraries, frameworks, CLIs, or any software tool used directly.
`other` for anything else.

`public` — default `true`. Set to `false` for resources behind authentication,
on private networks, or otherwise inaccessible to the agent.
The agent will not attempt to fetch non-public resources but will surface the reference
as context when relevant.

---

## Edges

### Outgoing edges from a Reference

| edge         | target type           | use when                                                    |
| ------------ | --------------------- | ----------------------------------------------------------- |
| `supports`   | `decision` `playbook` | this reference validates or grounds a decision or procedure |
| `depends_on` | `concept`             | understanding this concept is required to use the reference |
| `depends_on` | `reference`           | this tool depends on another tool or resource               |
| `related_to` | any                   | topical connection — requires `reason`                      |

### Body volume vs concept/source

If the reference's body exceeds a strict conciseness limit, reclassify:

| Condition                                                | Correct type       |
| -------------------------------------------------------- | ------------------ |
| More than 3 sentences                                    | `concept` or `source` |
| Contains feature tables, history, or comparisons         | `concept`          |
| Contains synthesized knowledge extracted from the doc    | `source`           |
| Contains context, history, or trivia with no operational value | `note`             |

A reference is a pointer to a resource, not a summary of it.

### Incoming edges toward a Reference

| edge           | from type             | use when                                           |
| -------------- | --------------------- | -------------------------------------------------- |
| `depends_on`   | `playbook` `decision` | a playbook or decision relies on this reference    |
| `depends_on`   | `reference`           | another tool depends on this one                   |
| `derived_from` | `fact` `concept`      | a note whose content is grounded in this reference |

---

## Body structure

```markdown
[One sentence — what this resource is and what it is used for.]

[Optional: one additional sentence on relevant parts, caveats, or version notes.]
```

**Strict limit**: maximum 3 sentences total, no headers, no sections, no tables.
A reference is a pointer to the resource — not a summary of its content.

If the body needs more than 3 sentences to be useful, you are writing a
`concept` (what the tool does, its design model) or a `source` (synthesized
knowledge extracted from the resource). Reclassify accordingly.

---

## Examples

**global/references/reference--fluentmigrator.md**

```yaml
---
type: reference
created: 2026-01-15
ref: https://fluentmigrator.github.io
ref_type: tool
public: true
tags: []
edges:
  - target: global/concepts/concept--schema-migration
    type: depends_on
    weight: 0.8
---
```

```markdown
FluentMigrator is a .NET library for database schema migrations using a fluent API.
Consult for syntax, runner configuration, and rollback strategies.
See [[global/concepts/concept--schema-migration|Schema Migration]].
```

---

**global/references/reference--pgvector-readme.md**

```yaml
---
type: reference
created: 2026-01-10
ref: https://github.com/pgvector/pgvector
ref_type: repo
public: true
tags: []
edges:
  - target: global/concepts/concept--vector-embeddings
    type: depends_on
    weight: 0.8
---
```

```markdown
Official pgvector repository — canonical reference for installation, configuration,
and supported distance metrics. Consult README for HNSW vs IVFFlat tradeoffs.
See [[global/concepts/concept--vector-embeddings|Vector Embeddings]].
```

---

**projects/client-x/references/reference--client-x-db-schema.md**

```yaml
---
type: reference
created: 2026-03-15
ref: "\\\\server\\client-x\\schemas\\pgvector-schema.sql"
ref_type: file
public: false
tags: []
edges:
  - target: projects/client-x/decisions/decision--use-cosine-for-search
    type: supports
    weight: 0.8
---
```

```markdown
Client-x production database schema including the pgvector embeddings table.
Located on the client network share — requires VPN access.
Uses 1536 dimensions (text-embedding-3-small); consult before any migration.
```
