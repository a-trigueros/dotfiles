# type/bookmark

## Definition

A Bookmark is a saved reference with light annotation, not yet digested.
It signals intent to explore — a resource identified as potentially relevant
but not yet read, watched, or synthesized.

A Bookmark answers the question: "what do I want to explore?"
If the resource has been read and synthesized → use `source`.
If a specific verifiable statement has been extracted → use `fact`.

---

## Reference types

A Bookmark can point to any type of external resource.

| ref type          | examples                                        |
| ----------------- | ----------------------------------------------- |
| public URL        | article, blog post, documentation, video        |
| authenticated URL | paywalled article, private tool, SaaS dashboard |
| local file        | PDF in vault, exported document                 |
| physical resource | book, printed article, physical document        |
| other             | podcast episode, conference talk, conversation  |

The agent must not attempt to fetch or read the resource automatically.
If `ref` is a URL, it may require authentication or be otherwise inaccessible.
The agent must signal inaccessibility rather than fail silently.

---

## Lifecycle

A Bookmark exists as long as the resource has not been read and synthesized.
Once digested, the bookmark is deleted and replaced by a `source` note.
The agent may surface Bookmarks as exploration candidates when relevant to a query.

---

## Scope

`global/` — a reference independent of any project.
`projects/<name>/` — a reference found in a specific project context.

---

## Frontmatter

```yaml
---
type: bookmark
created: YYYY-MM-DD
tags: []
edges: []
ref: <url or free-text identifier> # required — what is being bookmarked
ref_type: url | file | physical | other # required — nature of the reference
public: true # false if behind auth or otherwise unreachable
---
```

### Field rules

`ref` — the identifier of the resource. A URL, a vault path, or a free-text identifier
(e.g. "The Pragmatic Programmer — Hunt & Thomas", "Lex Fridman #367 — Sam Altman").

`ref_type` — the nature of the reference. Helps the agent know how to handle it.
`url` for web resources. `file` for local vault files. `physical` for books or printed material.
`other` for podcasts, talks, conversations, or anything else.

`public` — whether the resource is accessible without authentication or special access.
Default `true`. Set to `false` for authenticated URLs, physical resources, or local files
the agent cannot read. The agent will not attempt to fetch non-public resources.

---

## Edges

### Outgoing edges from a Bookmark

| edge          | target type          | use when                                                         |
| ------------- | -------------------- | ---------------------------------------------------------------- |
| `related_to`  | `concept` `question` | the resource is relevant to an existing note — requires `reason` |
| `tagged_with` | tag node             | topic tag                                                        |

### Incoming edges toward a Bookmark

Anything can reference a bookmark. Since anything can emerge from a bookmark.

---

## Body structure

```markdown
[One or two sentences — why this resource was saved and what it might contribute.]
```

No headers. No summary — the resource has not been read yet.
The annotation must be specific enough that the agent understands
why this bookmark exists and what question or gap it might address.

---

## Examples

**global/bookmarks/bookmark--attention-is-all-you-need.md**

```yaml
---
type: bookmark
created: 2026-01-10
ref: https://arxiv.org/abs/1706.03762
ref_type: url
public: true
tags: []
edges: []

---
```

```markdown
Original transformer paper by Vaswani et al. — foundational for understanding
how attention mechanisms replaced recurrence in sequence models.
Relevant to the embedding pipeline work.
```

---

**global/bookmarks/bookmark--pragmatic-programmer.md**

```yaml
---
type: bookmark
created: 2026-02-14
ref: "The Pragmatic Programmer — Hunt & Thomas (2nd edition)"
ref_type: physical
public: false
tags: []
edges: []
---
```

```markdown
Classic software craftsmanship book recommended by multiple trusted sources.
Likely relevant to coding standards and decision-making principles.
```

---

**projects/client-x/bookmarks/bookmark--pgvector-auth-dashboard.md**

```yaml
---
type: bookmark
created: 2026-03-20
ref: https://internal.client-x.com/pgvector/dashboard
ref_type: url
public: false
tags: []
edges: []
```

```markdown
Client-x internal dashboard for pgvector performance monitoring.
Requires client VPN and authentication — not directly accessible by the agent.
```
