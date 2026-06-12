# SKILL — type/source

## Definition

A Source is an external reference that has been read and synthesized.
It captures what the resource is, and what you retain from it —
a summary is always a subjective selection, and that subjectivity is the value.

A Source answers the question: "what did I take from this reference?"
If the resource has not been read yet → use `bookmark`.
If a specific verifiable statement has been extracted → use `fact` with `derived_from` pointing here.

---

## Relationship to Fact

Facts extracted from a source point back to it via `derived_from`.
The source does not list its child facts — the agent finds them via reverse traversal.

---

## Scope

`global/` — a reference independent of any project.
`projects/<name>/` — a reference relevant only to a specific project context.

---

## Frontmatter

```yaml
---
type: source
created: YYYY-MM-DD
tags: []
edges: []
author: <free text> # optional — author(s) of the resource
published: YYYY # optional — year of publication or release
ref: <url or free-text> # optional — URL or identifier of the resource
ref_type: url | file | physical | other # optional — nature of the reference
public: true # false if behind auth or otherwise unreachable
medium: book | paper | article | talk | podcast | other
---
```

### Field rules

`author` — free text. Single author, multiple authors, or organization name.

`published` — year only. Helps the agent reason about recency and potential staleness.

`ref` — same as in `bookmark`. A URL, vault path, or free-text identifier.
Absent if the resource has no stable identifier.

`public` — same semantics as in `bookmark`. Default `true`.
The agent will not attempt to fetch non-public resources.

`medium` — the nature of the resource. Helps the agent contextualize the synthesis.

---

## Edges

### Outgoing edges from a Source

| edge          | target type            | use when                                |
| ------------- | ---------------------- | --------------------------------------- |
| `supports`    | `hypothesis` `concept` | the source provides evidence for a note |
| `contradicts` | `fact` `hypothesis`    | the source challenges an existing note  |
| `related_to`  | any                    | topical connection — requires `reason`  |

### Incoming edges toward a Source

| edge           | from type | use when                                           |
| -------------- | --------- | -------------------------------------------------- |
| `derived_from` | `fact`    | a fact extracted from this source                  |
| `authored_by`  | any       | a note whose author is this source's author (rare) |

---

## Body structure

```markdown
[One sentence identifying the resource and its main argument or contribution.]

[Your synthesis — what you retain, what is relevant, how it connects to your existing knowledge.
This is subjective by nature. Capture what matters to you, not an exhaustive summary.]
```

No headers unless the synthesis covers genuinely distinct topics that require separation.
The body should be readable as a standalone note — someone reading only this note
must understand what the resource contributes and why it matters in your knowledge graph.

---

## Examples

**global/sources/source--attention-is-all-you-need.md**

```yaml
---
type: source
created: 2026-01-15
author: "Vaswani et al."
published: 2017
ref: https://arxiv.org/abs/1706.03762
ref_type: url
public: true
medium: paper
tags:
  - global/concepts/concept--large-language-models
edges:
  - target: global/concepts/concept--vector-embeddings
    type: supports
    weight: 0.7
---
```

```markdown
Foundational paper introducing the transformer architecture, replacing recurrence
with self-attention for sequence modeling tasks.

The key insight is that attention over the full input sequence — rather than
propagating state through time — allows parallelization and captures long-range
dependencies more effectively. This is the architectural basis for all modern
embedding models. What I retain most: the positional encoding choice is somewhat
arbitrary, and the attention mechanism is essentially a learned similarity function
over learned representations — which connects directly to how cosine similarity
operates on the resulting embeddings.
```

---

**global/sources/source--pragmatic-programmer.md**

```yaml
---
type: source
created: 2026-03-10
author: "Hunt & Thomas"
published: 2019
ref: "The Pragmatic Programmer — 2nd edition"
ref_type: physical
public: false
medium: book
tags: []
edges:
  - target: global/pillars/pillar--simplicity-over-cleverness
    type: supports
    weight: 0.7
---
```

```markdown
A practical guide to software craftsmanship covering everything from code quality
to career development, grounded in decades of professional experience.

What I retain most: the "broken windows" theory applied to codebases — entropy
accelerates once the first shortcut is tolerated. Also the DRY principle as a
knowledge management concept, not just a code deduplication rule. Every piece
of knowledge should have a single authoritative representation. This maps
directly onto the atomic note principle of this vault.
```
