---
name: note-structure
description: Use this skill whenever creating, editing, or reorganizing any note in the vault. Defines the mandatory structure for every note — common frontmatter fields (type, created, tags, edges), the 10 edge types and their weights, the global/ vs projects/<name>/ namespace rules, the atomic note principle (one note = one concept/fact/decision/event), and file naming conventions. After reading this file, load the matching type/<type>.md file for type-specific fields and body structure before writing any frontmatter or content. Trigger for any task involving creating a note, adding edges between notes, classifying content into one of the 16 types, or deciding where a note belongs in the vault.
---

## Purpose

This skill defines how every note in this vault must be structured.
Read this skill before creating or editing any note.
For type-specific fields and body structure, load the corresponding file in `types/`.

---

## Atomic principle

One note = one concept, one fact, one decision, one event — never more.
If a note covers a concept, when to use it, and how to use it in a context: that is three notes.
50 to 300 words per note body. Exception: `type: playbook` is word-limit exempt.

---

## Vault structure and namespace

The vault is organized into two top-level namespaces. The file path is the namespace — it is never repeated in the frontmatter.

```
vault/
  global/          ← knowledge independent of any project
    learning/
    concepts/
    sources/
    contacts/
    ...
  projects/        ← knowledge anchored to a specific project
    project-name/
    ...
```

### Namespace rules

**`global/`** — a note belongs here when the knowledge is reusable across all contexts.
Facts, concepts, sources, and contacts are almost always global.

**`projects/<name>/`** — a note belongs here when the knowledge is specific to one project.
Decisions, tasks, and project-specific patterns live here.

**Context priority** — when operating in a project context, the agent must:

1. Load `projects/<name>/` first.
2. Enrich with `global/` nodes reached via edges.
3. Never load another project's namespace unless an explicit edge points there.

**Conflict resolution** — a global `pillar` may be overridden by a project `decision` via a `contradicts` edge (weight 1.0). The local decision always wins. No exclusion mechanism is needed — the edge is the signal.

---

## Frontmatter

Every note starts with a YAML frontmatter block. No exceptions.

### Common fields

```yaml
---
type: <note-type> # required — see Types section below
created: YYYY-MM-DD # required — date the knowledge was acquired or formalized
tags: [] # full paths of tag-nodes linked via tagged_with edges
edges: [] # outgoing relations — see Edges section below
---
```

### Field rules

`type` — must be one of the 16 defined types. Determines which type skill to load.
Controls valid edge types, body structure, and type-specific fields.

`created` — the date this knowledge entered the vault, not the date of the event or fact described.
Never update it when the note content changes. The note IS the current state of knowledge.

`tags` — list of full vault paths pointing to tag-nodes. Each tag is itself a note linked via `tagged_with`.
Format: `global/concepts/concept--machine-learning`
Do not use free-text strings. Every tag must correspond to an existing note.

`edges` — list of outgoing relations from this note. Canonical source of truth for graph traversal.
See the Edges section for structure and rules.

---

## Edges

Edges are stored in two places with a strict priority rule.

### Priority rule

**Frontmatter edges are the source of truth.** The agent reads and writes edges from the frontmatter.
Wikilinks in the body are for human navigation in Obsidian and may be present as a convenience.
If a conflict exists between frontmatter and body wikilinks, frontmatter wins.

### Frontmatter edge structure

Targets are identified by their full vault path, without the `.md` extension.

```yaml
edges:
  - target: global/learning/fact--cosine-similarity-is-normalized
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

`reason` is required when `type: related_to`. Without a reason, the edge must not be created.

### Body wikilinks (secondary)

Wikilinks in the note body may mirror edges for human navigation in Obsidian.
They must use the **full vault path** of the target, with an alias for readability:

```markdown
This fact is supported by [[global/facts/fact--cosine-similarity-is-normalized|Cosine Similarity]].
```

Wrong:  `[[fact--cosine-similarity-is-normalized]]`
Right:  `[[global/facts/fact--cosine-similarity-is-normalized|Cosine Similarity]]`

They are not parsed by the agent. Do not rely on them for reasoning.

### Edge types and weights

| type           | weight | use when                                                           |
| -------------- | ------ | ------------------------------------------------------------------ |
| `supports`     | 0.7    | source provides evidence for target                                |
| `contradicts`  | 1.0    | source disagrees with or invalidates target                        |
| `depends_on`   | 0.8    | target must be true before source makes sense                      |
| `derived_from` | 0.9    | source was created based on target                                 |
| `related_to`   | 0.3    | topical connection, no stronger relation known — requires `reason` |
| `part_of`      | 0.8    | source is a component of target                                    |
| `preceded_by`  | 0.7    | source comes after target in time                                  |
| `followed_by`  | 0.7    | source comes before target in time                                 |
| `authored_by`  | 1.0    | target is the author or originator of source                       |
| `tagged_with`  | 0.5    | source carries a topic tag that is itself a note                   |

### Edge rules

**`related_to`** — use only if no other edge type applies. Weight is 0.3 (intentionally low).
The `reason` field is mandatory. Reject the edge if reason is absent or vague.

**`preceded_by` / `followed_by`** — never create both directions on the same pair of notes.
Convention: prefer `preceded_by` (source comes after target). The inverse is implicit.

**Duplication** — never create two edges of the same type between the same pair of notes.

**Missing target** — never create an edge pointing to a non-existent path.
Create the target note first, then link.

### Wikilink integrity

Before creating a wikilink in any note body, verify that the target note exists
in the vault. If the target does not exist:

1. Check whether the target subject has content available (vault search, then
   web search, then training data — in that order).
2. If content is found, create the target note in full and link it.
3. If no content is found and the target name is essential for navigation, create
   a minimal stub note (frontmatter only, one-sentence body) — but only after
   confirming with the user.
4. If the user does not confirm the stub, remove the wikilink and use plain text
   instead.

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

Wrong:  `[[concept--vector-space]]`
Wrong:  `[[vector-space]]`
Right:  `[[global/concepts/concept--vector-space|Vector Space]]`

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

---

## Types

16 note types are defined across 4 families.

### Default paths by type

This table is the source of truth for where each note type is stored.
Use the path that matches the note's scope (global or project).

| type         | global path          | project path                  |
| ------------ | -------------------- | ----------------------------- |
| `pillar`     | `global/pillars/`    | `projects/<name>/pillars/`    |
| `decision`   | `global/decisions/`  | `projects/<name>/decisions/`  |
| `concept`    | `global/concepts/`   | `projects/<name>/concepts/`   |
| `question`   | `global/questions/`  | `projects/<name>/questions/`  |
| `playbook`   | `global/playbooks/`  | `projects/<name>/playbooks/`  |
| `task`       | —                    | `projects/<name>/tasks/`      |
| `event`      | `global/events/`     | `projects/<name>/events/`     |
| `pattern`    | `global/patterns/`   | `projects/<name>/patterns/`   |
| `hypothesis` | `global/hypotheses/` | `projects/<name>/hypotheses/` |
| `fact`       | `global/facts/`      | `projects/<name>/facts/`      |
| `source`     | `global/sources/`    | `projects/<name>/sources/`    |
| `bookmark`   | `global/bookmarks/`  | `projects/<name>/bookmarks/`  |
| `contact`    | `global/contacts/`   | `projects/<name>/contacts/`   |
| `reference`  | `global/references/` | `projects/<name>/references/` |
| `note`       | `global/notes/`      | `projects/<name>/notes/`      |
| `custom`     | `global/custom/`     | `projects/<name>/custom/`     |

`task` is almost always project-specific. A global task is exceptional and must be justified.

### Type skills

Type-specific fields and body structure are defined in:

```
~/.agents/skills/types/<type>.md
```

Load the relevant file after this one before creating or editing a note of that type.

---

## Fallback rules

**Unknown type** — if the content does not clearly fit any of the 16 types, use `type: note`.
A `note` has no constraints. It is a staging area for knowledge not yet atomized.

**Unknown edge** — if no edge type fits, do not create an edge. Flag the gap instead.

**Unknown path** — if unsure whether a note belongs in `global/` or `projects/`, ask.
Default to `global/` only if the knowledge is clearly reusable across all contexts.
