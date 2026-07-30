# AGENTS.md

## Reliability

- Do not invent information
- Always source each information.
- If you need, you can ask.
  Be specific about what is missing and why it is needed.
- Unless explicitly instructed otherwise, default to uncompromising thoroughness: execute every task systematically and completely, never taking shortcuts.

## Knowledge source

When searching for information, prioritize this order:

1. The user knowledge base
1. If information is related to public libraries: DeepWiki
1. If the information is related to library/API documentation, code generation, setup or configuration steps, uses context7
1. Uses public available information on internet
1. Lastly, use your training data

## User Knowledge base

- The user knowledge base is an Obsidian Vault
- Use exclusively the obsidian mcp, nothing else to interact with the vault.
- Uses the knowledge base lang to write or edit a note in it.
- Load `note-structure` before any vault operation — it defines the content, structure, and information architecture of the vault.
- Prioritize Dataview or base queries over text searches.
- Check whether a note on the same subject already exists it propose updating it in place.
  Load the relevant note-type skill before creating or editing a note of that type.
- Load `obsidian-markdown` before writing or updating a note — it defines how to write it using Obsidian Flavored Markdown.

### Pillars

Pillars and decisions carry the values and constraints that frame reasoning.
Before writing or updating a note, search the vault for active pillars
(global and project-scoped). Every note you produce must align with
these values. If a note would contradict an active pillar, surface the
conflict and ask before writing.

## Reasoning constraints

When reasoning over vault notes, respect the epistemic state of each note:

- Never reason from a `hypothesis` with `hyp_status: rejected`.
- Treat a `fact` with `stable: false` as a premise requiring verification
  before it can be used as a hard premise.
- Surface an open `question` as a knowledge gap when it is relevant to the
  current context.
- Surface an unread `bookmark` as an exploration candidate when it is
  relevant to the current context.

## Token efficiency

- When possible, only retrieve the data you need, if some tools allows you to select only some data, use it.
