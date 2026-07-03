# type/concept

## Definition

A Concept defines what something is — its nature, boundaries, and prescriptive usage
that follows logically from its definition.

A Concept answers the question: "what is this thing?"
If the answer is "what I believe or value" → use `pillar`.
If the answer is "an empirically observed regularity about when to use it" → use `pattern`.
If the answer is "a reproducible procedure for using it in a context" → use `playbook`.

---

## The three facets of a concept

A single subject often has three distinct notes:

| facet               | type       | question answered                                |
| ------------------- | ---------- | ------------------------------------------------ |
| definition          | `concept`  | what is it?                                      |
| empirical relevance | `pattern`  | when is it the right tool, based on observation? |
| contextual usage    | `playbook` | how is it applied in a specific context?         |

Do not collapse these into one note. Each is atomic and independently reusable.

The prescriptive "when to use" that follows logically from the definition
(e.g. "use embeddings when you need semantic similarity") belongs in the concept body.
The empirical "when to use" observed in practice belongs in a `pattern`.

---

## Scope

`global/concepts/` — the standard case. A concept is almost always global and reusable.
`projects/<name>/` — only if the concept is entirely specific to one project's domain.

---

## Frontmatter

Inherits all common fields. No additional fields required.

```yaml
---
type: concept
created: YYYY-MM-DD
tags: []
edges: []
---
```

A Concept has no type-specific frontmatter fields. Its identity is entirely in its body and edges.

---

## Edges

### Outgoing edges from a Concept

| edge              | target type                                                                                                 | use when                                                           |
| ----------------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `depends_on`      | `concept`                                                                                                   | this concept requires another concept to be understood first       |
| `part_of`         | `concept`                                                                                                   | this concept is a component of a larger concept                    |
| `derived_from`    | `concept`                                                                                                   | this concept was defined based on another                          |
| `related_to`      | `concept` `note` `event` `contact`                                                                          | topical connection, no stronger relation known — requires `reason` |
| `supported_by`    | `pillar` `concept` `bookmark` `source` `reference` `custom` `decision` `fact` `hypothesis` `note` `pattern` | evidence about when or why this concept applies                    |
| `contradicted_by` | `pillar` `concept` `bookmark` `source` `reference` `custom` `decision` `fact` `hypothesis` `note` `pattern` | evidence about when or why this concept is irrelevant              |

### Incoming edges toward a Concept

| edge           | from type                       | use when                                                  |
| -------------- | ------------------------------- | --------------------------------------------------------- |
| `depends_on`   | `decision` `playbook` `concept` | the source requires this concept to make sense            |
| `supported_by` | `concept`                       | empirical evidence about when or why this concept applies |
| `derived_from` | `concept`                       | a concept that traces its definition here                 |
| `part_of`      | `concept`                       | a sub-concept that belongs to this one                    |

---

## Body structure

```markdown
[One sentence definition — what this thing is, plainly stated.]

[Explanation of its nature, boundaries, and key properties. 50 to 300 words.]

[Optional: prescriptive usage that follows logically from the definition —
when this concept applies, derived from what it is, not from empirical observation.]
```

No headers unless the concept has genuinely distinct sections that require separation.
The body must define the concept completely enough that an agent can reason from it
without loading any other note.

---

## Examples

**global/concepts/concept--cosine-similarity.md**

```yaml
---
type: concept
created: 2026-01-22
tags:
  - global/concepts/concept--vector-space
edges:
  - target: global/concepts/concept--vector-space
    type: depends_on
    weight: 0.8
  - target: global/concepts/concept--dot-product
    type: derived_from
    weight: 0.9
---
```

```markdown
Cosine similarity is a metric that measures the angle between two vectors
in a multi-dimensional space, returning a value between -1 and 1.
Unlike euclidean distance, it is invariant to vector magnitude — two vectors
pointing in the same direction score 1.0 regardless of their length.
It is derived from [[global/concepts/concept--dot-product|Dot Product]] and
requires understanding [[global/concepts/concept--vector-space|Vector Space]].

Use cosine similarity when comparing items whose magnitude should not influence
the result — for example, documents of different lengths representing similar topics.
```

---

**global/concepts/concept--vector-embeddings.md**

```yaml
---
type: concept
created: 2026-01-20
tags:
  - global/concepts/concept--machine-learning
edges:
  - target: global/concepts/concept--vector-space
    type: depends_on
    weight: 0.8
  - target: global/concepts/concept--semantic-similarity
    type: related_to
    weight: 0.3
    reason: "embeddings are the primary mechanism for computing semantic similarity"
---
```

```markdown
Vector embeddings are numerical representations of content in a high-dimensional space
where geometric proximity reflects semantic similarity.
They are built on [[global/concepts/concept--vector-space|Vector Space]] and are the
primary mechanism for computing [[global/concepts/concept--semantic-similarity|Semantic Similarity]].

A piece of text, image, or structured data is encoded as a dense vector of floating-point
numbers by a model trained to place semantically related content close together.
The resulting space can be queried with distance metrics to find similar items,
cluster related content, or detect anomalies.

Use embeddings when comparison by meaning is required rather than comparison by
exact token match — the vocabulary used to express an idea should not determine
whether two items are considered similar.
```
