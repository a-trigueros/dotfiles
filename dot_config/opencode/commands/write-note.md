---
description: Create or enrich one or more notes in the vault, surfacing relevant connections
agent: cortex
---

Topic: $ARGUMENTS

## Vault interaction

- Uses the `obsidian-brain` mcp to read from, query and write to the vault
- If the conversation context already indicates the vault path, propose it to the user for confirmation before doing anything else. if not, assume it's a global note.
- `global/` and `projects/` are top-level locations inside it.

## Preparation (mandatory before writing anything)

1. Read `~/.agent/skills/note-structure/SKILL.md` for the general rules (frontmatter,
   edges, namespace, naming).
2. Identify the concept(s)/fact(s)/decision(s)/etc. present in the topic above.
   - For each of the 16 note types, explicitly ask: "does the source content
     contain at least one instance of this type?" List every candidate found,
     even minor ones, before deciding which to keep.
   - Never group two distinct subjects into one note on the grounds that they
     share the same tool or topic. Each atomic fact, concept, playbook, and
     reference must be a separate note, even if they all concern the same
     library or system.
   - Apply the atomic principle: if the content covers several distinct subjects,
     plan one note per subject.
3. For each note to create, determine the `type` using the decision trees
   ("A X answers the question...") in each
   `~/.agent/skills/note-structure/types/<type>.md` file.
   - If no type clearly fits → `type: note`.
   - `custom` only after explicitly ruling out the other 15 types.
4. Load the corresponding `~/.agent/skills/note-structure/types/<type>.md` file.
5. Determine the namespace (`global/` or `projects/<name>/`):
   - Check whether the topic could relate to a specific project. If so, list the
     `projects/` directory and propose the matching candidate(s)
     to the user for confirmation.
   - If the topic doesn't clearly point to a project, default to `global/`
     per the type's scope rules, but confirm with the user if ambiguous.

## Before drafting

Ask the user for:

- any information required by the type that is missing (`date`, `decided_on`,
  `alternatives`, `test`, `derived_from` for a `fact`, etc.).
- the source/origin if required by the type.
- confirmation of the namespace/project if ambiguous.

Do not invent dates, sources, or attributions.
Each information that you put have to either be approved explicitly by the user or requires a source.

## Connection discovery

The goal is to connect the new note to the existing graph, not just to the elements
explicitly mentioned in the topic.

1. Extract key terms from the subject (concepts, tools, projects, people, dates).
2. Search the vault for existing notes touching these terms (title, frontmatter `tags`,
   content).
3. For each candidate note found:
   - Check whether it matches a typed edge allowed for the current type
     (the "Outgoing/Incoming edges" tables in the type file).
   - If a stronger edge than `related_to` applies (`depends_on`, `supports`,
     `derived_from`, `contradicts`, `part_of`, `preceded_by`/`followed_by`,
     `authored_by`) → create it directly.
   - If only a topical connection exists → propose `related_to` with a precise
     `reason`, and submit this proposal to the user for validation before adding it.
     Stay conservative: at most 2-3 candidates, the most relevant ones.
4. Never create two edges of the same type toward the same target. Respect the
   single direction for `preceded_by`/`followed_by`.
5. Relevant but non-existent target → create a minimal note before creating the edge.
6. Try to make relevant connection with the already existing notes.
   Eg: A playbook describing authentication in .NET should be linked to `concept--.net` and `concept--authentication`.

## Edge ↔ Obsidian wikilink synchronization

- Every edge present in the frontmatter must have a corresponding wikilink in the body.
- Do not create a wikilink in the body that has no corresponding edge in the frontmatter
  (no isolated "decorative" links).
- Wikilinks use the file slug (`type--descriptive-kebab-case`) to identify the target,
  without path or `.md` extension. Since the slug is technical and not always readable,
  use an alias for display: `[[type--target-slug|Expressive label]]`, where the label
  is a clear, human-readable name for the target note.
- Wikilinks may appear either inline, woven naturally into the body text where the
  relation is relevant, or grouped in a short "Connections" list at the end of the note
  (or both). Choose whichever placement keeps the body readable — dense notes with many
  edges may benefit from a trailing list rather than cluttering the prose.

## Drafting

- Frontmatter: common fields (`type`, `created`, `tags`, `edges`) + type-specific fields.
- Body: structure defined by the type (with/without headers, 50-300 words except
  `playbook`), enriched with wikilinks derived from the edges.
- Factual tone, no narrative framing — the note is a reference, not an explanatory text.
- No fields invented outside the type's schema. Information like a "license" with no
  standalone reasoning value stays as a sentence in the body; if it constrains a
  decision, it becomes a separate `fact` linked via an edge.
- Avoid using Python as a shortcut

## Tags

- Each entry in `tags` must be the full path of an existing tag-note.
- If the relevant tag doesn't exist yet, create the tag-note stub and flag the creation.

## Naming and path

- `type--descriptive-kebab-case.md`, in the type's default path (global or project).
- Check whether a note on the same subject already exists — propose updating it in place
  rather than creating a duplicate, especially for `fact`.

## End of task

Summarize: note(s) created/modified, stubs created, edges/wikilinks added (with
justification for each `related_to`), and any remaining missing information.
