---
name: note-structure
description: Obsidian note structure for Search, Query, Create, Update or Refactor user notes. Use this skill when searchinig, querying, creating, editing, or reorganizing any user note.
---

## Vault structure and namespace

The vault is organized into two top-level namespaces.
The file path is the namespace — it is never repeated in the frontmatter.

```
vault/
  global/          ← knowledge independent of any project
    learning/
    concepts/
    sources/
    contacts/
    ... # All other note types
  projects/        ← knowledge anchored to a specific project
    project-name/
      learning/
      concepts/
      sources/
      ... # All other note types except contacts
    ...
```

### Namespace rules

**`global/`** — a note belongs here when the knowledge is reusable across all contexts.
Facts, concepts, sources, and contacts are almost always global.

**`projects/<name>/`** — a note belongs here when the knowledge is specific to one project.
Decisions, tasks, and project-specific patterns live here.

**Context priority** — when operating in a project context, the agent must:

1. Search in `projects/<name>/` first.
2. Enrich with `global/` nodes reached via edges.
3. **Never** load another project's namespace unless an explicit edge points there.

**Conflict resolution** — a global `pillar` may be overridden by a project `pillar` or `decision` via a `overrides` edge.
The local decision always wins.
No exclusion mechanism is needed — the edge is the signal.

---

## Atomic principle

One note = one concept, one fact, one decision, one event — never more.
If a note covers a concept, when to use it, and how to use it in a context: that is three notes.
50 to 300 words per note body. Exception: `type: playbook` and `type:note` is word-limit exempt.

---

## Frontmatter

Every note starts with a YAML frontmatter block. No exceptions.

### Common fields

```yaml
---
type: <note-type> # required — see Types section below
created: YYYY-MM-DD # required — date the knowledge was acquired or formalized. If not specified, confirm with user for using the date for the day.
tags: [] # Context-relevant tags — Semantic proximity meaning. For instance concept--tunit may have tags: [testing-practices, dotnet, test-framework]
edges: [] # outgoing relations — see Edges section below
---
```

### Field rules

`type` — must be one of the 15 defined types. Determines which type skill to load.
Controls valid edge types, body structure, and type-specific fields.

`created` — the date this knowledge entered the vault, not the date of the event or fact described.
Never update it when the note content changes. The note IS the current state of knowledge.

`tags` — list of tags related to the notes.
See the Tags section for structure and rules.

`edges` — list of outgoing relations from this note. Canonical source of truth for graph traversal.
See the Edges section for structure and rules.

If any field value is uncertain ask. Do not fill with placeholders.

### Enrichment

Some note types contains additional fields and rules.
Load the relevant note type and use this information.

---

## Tags

Tags are structural indexes connecting notes by concept, type, or project regardless of their physical folder. When analyzing a note, extract a maximum of 5 to 7 future-proof, atomic keywords by identifying the core intent and categorizing entities into a standardized taxonomy (e.g., type/, subject/, project/). Prioritize consistency by reusing existing tags, avoiding synonyms, and ensuring every tag represents a concept you would actually search for in the future.

Use lowercase letters, hyphens for multi-word terms (machine-learning).
Keep the body text clean by removing redundant inline tags and relying on the frontmatter for primary classification.

## Edges

Edges are stored in two places with a strict priority rule.

### Priority rule

**Frontmatter edges are the source of truth.** The agent reads and writes edges from the frontmatter. Any DataView query have to use these links.
Wikilinks in the body are for human navigation in Obsidian and must be present either as a convenience or to be used when facing issue to create a proper dataview query.
If a conflict exists between frontmatter and body wikilinks, present it to the user to solve it.

### Frontmatter edge structure

Targets are identified by their full vault path, without the `.md` extension.

```yaml
edges:
  - target: global/fact/fact--cosine-similarity-is-normalized
    type: supports
    weight: 0.7

  - target: global/sources/source--attention-is-all-you-need
    type: derived_from
    weight: 0.9

  - target: global/concepts/concept--vector-space
    type: related_to
    weight: 0.3
    reason: "both concern geometric representation of meaning"
```

Each edge requires:

- `target` — full vault path of the target note, without `.md`
- `type` — one of the 10 defined edge types
- `weight` — as defined in the edge type system

`reason` is required when `type: related_to`.
Without a reason, the edge must not be created.

### Body wikilinks (secondary)

Wikilinks in the note body may mirror edges for human navigation in Obsidian.
They must use the **full vault path** of the target, with an alias for readability:

```markdown
This decision is supported by [[global/facts/fact--cosine-similarity-is-normalized|Cosine Similarity]].
```

Wrong: `[[fact--cosine-similarity-is-normalized]]`
Right: `[[global/facts/fact--cosine-similarity-is-normalized|Cosine Similarity]]`

They must be present as natural content of the note.
Only if the content goes against a note type definition they may be part of a list.

### Edge types and weights

| type              | weight | use when                                                           |
| ----------------- | ------ | ------------------------------------------------------------------ |
| `supported_by`    | 0.7    | target provides evidence for source                                |
| `contradicted_by` | 1.0    | target disagrees with or invalidates source                        |
| `overrides`       | 1.0    | target overrides source                                            |
| `depends_on`      | 0.8    | target must be true before source makes sense                      |
| `derived_from`    | 0.9    | source was created based on target                                 |
| `related_to`      | 0.3    | topical connection, no stronger relation known — requires `reason` |
| `part_of`         | 0.8    | source is a component of target                                    |
| `preceded_by`     | 0.7    | source comes after target in time                                  |
| `followed_by`     | 0.7    | source comes before target in time                                 |
| `authored_by`     | 1.0    | target is the author or originator of source                       |
| `tagged_with`     | 0.5    | source carries a topic tag that is itself a note                   |
| `supports`        | 0.7    | **obsolete** source provides evidence for target                   |
| `contradicts`     | 1.0    | **obsolete** source disagrees with or invalidates target           |

### Edge rules

The target of an edge is what birthed the note.
Exemples:

- a playbook is issued and illustrates a concept.
- a source is redacted by an author (contact)
- a concept supports or invalidate a pillar
- a decision supports a pillar
- a decision emerges from an hypothesis, an observation (pattern) or a fact.

**`related_to`** — use only if no other edge type applies.
Weight is 0.3 (intentionally low).
The `reason` field is mandatory.
Reject the edge if reason is absent or vague.

**`preceded_by` / `followed_by`** — never create both directions on the same pair of notes.
Convention: prefer `preceded_by` (source comes after target).
The inverse is implicit.

**Duplication** — never create two edges of the same type between the same pair of notes.

**Missing target** — never create an edge pointing to a non-existent path.
Create the target note first, then link.

### Wikilink integrity

Before creating a wikilink in any note body, verify that the target note exists
in the vault. If the target does not exist:

1. Check whether the target subject has content available
2. If content is found, create the target note in full and link it.
3. If no content is found and the target name is essential for navigation, create
   a minimal stub note (frontmatter only, one-sentence body) — but only after confirming with the user.
4. If the user does not confirm the stub, remove the wikilink and use plain text instead.

### Depth limit

When creating a note with edges and wikilinks, the agent must ensure the existence
of target notes up to a depth of **3 levels** from the source note:

- Depth 1 = the note being created.
- Depth 2 = notes directly linked from depth 1.
- Depth 3 = notes linked from depth 2 notes.

For notes at depth 1, 2, and 3: create them in full if content is available.
For notes beyond depth 3: do not create them. Instead, write the wikilink using
the **full expected slug** (including type prefix and directory) and flag the
missing note to the user. This ensures future graph resolution will find the
correct target without creating an unbounded chain of stubs.

---

## Naming convention

File names are slugs. Format: `type--descriptive-kebab-case.md`

### Wikilink slug rule

Every wikilink in a note body must use the **full vault path** of the target
as its identifier, including the type prefix and directory, with no `.md`
extension. Aliases are still used for display:

```markdown
[[global/concepts/concept--vector-space|Vector Space]]
```

Wrong: `[[concept--vector-space]]`
Wrong: `[[vector-space]]`
Right: `[[global/concepts/concept--vector-space|Vector Space]]`

The full vault path is the note's unique identity in the graph.

```
global/learning/fact--transformer-attention-is-quadratic.md
global/concepts/concept--cosine-similarity.md
global/sources/source--attention-is-all-you-need.md
global/contacts/contact--jane-doe.md
projects/project-x/decision--use-cosine-for-search.md
projects/project-x/playbook--weekly-review.md
```

Once set, a path must not change — it would break all incoming edges.
If a note must be moved, update all edges pointing to it before moving.

If the note is related to a date, the final part of the slug will look like:

`{note_type}--{yyyy-MM-dd}-{content}`

Examples:

```
decision--2021-03-12-dont-use-properties-for-injection.md
event--2021-04-22-convention-du-cercle.md
event--2021-04-22-convention-du-cercle.md
```

The slugs are redacted in english.

Every note type can have a date.
If there is a start date and a end date, like for extended events, use the start date in the slug.

---

## Types

15 note types are defined across 4 families.

### Default paths by type

This table is the source of truth for where each note type is stored.
Use the path that matches the note's scope (global or project).

| type         | global path          | project path                  | family       |
| ------------ | -------------------- | ----------------------------- | ------------ |
| `pillar`     | `global/pillars/`    | `projects/<name>/pillars/`    | epistemic    |
| `decision`   | `global/decisions/`  | `projects/<name>/decisions/`  | epistemic    |
| `concept`    | `global/concepts/`   | `projects/<name>/concepts/`   | epistemic    |
| `question`   | `global/questions/`  | `projects/<name>/questions/`  | epistemic    |
| `playbook`   | `global/playbooks/`  | `projects/<name>/playbooks/`  | operational  |
| `event`      | `global/events/`     | `projects/<name>/events/`     | operational  |
| `pattern`    | `global/patterns/`   | `projects/<name>/patterns/`   | empirical    |
| `hypothesis` | `global/hypotheses/` | `projects/<name>/hypotheses/` | empirical    |
| `fact`       | `global/facts/`      | `projects/<name>/facts/`      | empirical    |
| `source`     | `global/sources/`    | `projects/<name>/sources/`    | empirical    |
| `bookmark`   | `global/bookmarks/`  | `projects/<name>/bookmarks/`  | empirical    |
| `contact`    | `global/contacts/`   | `projects/<name>/contacts/`   | unstructured |
| `reference`  | `global/references/` | `projects/<name>/references/` | unstructured |
| `note`       | `global/notes/`      | `projects/<name>/notes/`      | unstructured |
| `custom`     | `global/custom/`     | `projects/<name>/custom/`     | unstructured |

### Type skills

Type-specific fields and body structure are defined in related files:

- [pillar](references/pillar.md)
- [decision](references/decision.md)
- [concept](references/concept.md)
- [question](references/question.md)
- [playbook](references/playbook.md)
- [event](references/event.md)
- [pattern](references/pattern.md)
- [hypothesis](references/hypothesis.md)
- [fact](references/fact.md)
- [source](references/source.md)
- [bookmark](references/bookmark.md)
- [contact](references/contact.md)
- [reference](references/reference.md)
- [note](references/note.md)
- [custom](references/custom.md)

Load the relevant file after this one before creating or editing a note of that type.

---

## Fallback rules

**Unknown type** — if the content does not clearly fit any of the 15 types, asks.

**Unknown edge** — if no edge type fits, do not create an edge. Flag the gap instead.

**Unknown path** — if unsure whether a note belongs in `global/` or `projects/`, ask.
Default to `global/` only if the knowledge is clearly reusable across all contexts.
