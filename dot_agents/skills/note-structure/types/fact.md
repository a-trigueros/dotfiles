# type/fact

## Definition

A Fact is a verified atomic statement about a specific subject, with a traceable origin.
It is the primary premise from which the agent reasons.

A Fact answers the question: "what is verifiably true about this specific subject?"
If the statement is a definition or framework → use `concept`.
If the statement is a testable prediction → use `hypothesis`.
If the statement has no traceable origin → it is not a fact, use `note` until verified.

---

## Atomicity

One fact = one statement about one subject.
The subject must be precise enough that two related but distinct truths are two separate facts.

correct: `fact--gpt4-turbo-context-window-128k`
correct: `fact--gpt4o-context-window-256k`
incorrect: `fact--openai-context-windows` (covers multiple subjects)

If a fact evolves — same subject, updated knowledge — the note is updated in place.
The note IS the current state of knowledge. `created` reflects when the fact first entered
the vault, not when it was last updated. The body carries the full current truth,
including version or context distinctions when relevant.

What does not belong here
Some information looks like a fact but is not: current tool versions, star/follower/download counts, rankings, pricing tiers — any value that changes at a frequency the vault cannot track. Do not create a fact note for these. If the information has operational value (knowing which tool to install), it belongs as a sentence in the relevant reference body. If it has no operational value beyond the moment it was captured, it does not belong in the vault at all.

---

## Origin

Every fact must have a traceable origin via `derived_from`. No fact without a source.

| origin type         | `derived_from` target | when                                                      |
| ------------------- | --------------------- | --------------------------------------------------------- |
| external reference  | `source`              | the fact was extracted from a read and synthesized source |
| internal experiment | `hypothesis`          | the fact was produced by testing a hypothesis             |
| direct observation  | `event`               | the fact was observed during a specific event             |

---

## Stability

`stable: false` signals that the fact may become outdated — the origin is a study,
a versioned specification, or a statistic that changes over time.
The agent must verify a non-stable fact before using it as a hard premise.

`stable: true` (default) means the agent can treat the fact as a fixed premise.

---

## Scope

`global/` — a fact independent of any project.
`projects/<name>/` — a fact measured or observed within a specific project context.

---

## Frontmatter

```yaml
---
type: fact
created: YYYY-MM-DD
tags: []
edges: []
date: YYYY-MM-DD # required — date the fact was verified or measured
stable: true # false if the origin is versioned, statistical, or revisable
---
```

### Field rules

`date` — the date the fact was verified or measured. Distinct from `created`.
For facts extracted from a source, this is the publication or measurement date of the source.
For facts produced by experiment, this is the date the experiment was run.

`stable` — default `true`. Set to `false` when:

- the fact comes from a versioned specification that may change (software, APIs, tools)
- the fact is a statistic or measurement that is periodically updated
- the source is a study that may be revised or retracted

---

## Edges

### Outgoing edges from a Fact

| edge           | target type                       | use when                                                |
| -------------- | --------------------------------- | ------------------------------------------------------- |
| `derived_from` | `source`                          | the fact was extracted from a source                    |
| `derived_from` | `hypothesis`                      | the fact was produced by testing a hypothesis           |
| `derived_from` | `event`                           | the fact was observed during an event                   |
| `supports`     | `hypothesis` `concept` `decision` | this fact provides evidence for another note            |
| `contradicts`  | `fact` `hypothesis`               | this fact challenges another note                       |
| `part_of`      | `fact`                            | this fact is a component of a broader factual statement |

### Incoming edges toward a Fact

| edge           | from type          | use when                                              |
| -------------- | ------------------ | ----------------------------------------------------- |
| `supports`     | `source` `pattern` | evidence reinforcing this fact                        |
| `contradicts`  | `fact` `source`    | a note challenging this fact — rare, signals an error |
| `derived_from` | `hypothesis`       | a hypothesis whose test produced this fact            |

---

## Body structure

```markdown
[One sentence stating the fact plainly and completely.]

[Optional: context, measurement conditions, version or scope qualifiers.]
```

The statement must be self-contained — the agent must be able to use it as a premise
without loading any other note. Include version, scope, or conditions directly in the body
when they are necessary to make the statement unambiguous.

---

## Examples

**global/facts/fact--pgvector-dimensions-limit.md**

```yaml
---
type: fact
created: 2026-01-10
date: 2026-01-10
stable: false
tags:
  - global/concepts/concept--vector-embeddings
edges:
  - target: global/sources/source--pgvector-documentation
    type: derived_from
    weight: 0.9
---
```

```markdown
pgvector supports a maximum of 2000 dimensions per vector in versions up to 0.5.
From version 0.6 onward, the limit is raised to 16000 dimensions.

This is a versioned specification — verify against the installed version before use.
```

---

**projects/client-x/facts/fact--short-queries-recall-40pct-drop.md**

```yaml
---
type: fact
created: 2026-04-12
date: 2026-04-12
stable: true
tags: []
edges:
  - target: projects/client-x/hypotheses/hypothesis--short-queries-cause-recall-drop
    type: derived_from
    weight: 0.9
  - target: projects/client-x/decisions/decision--use-cosine-for-search
    type: supports
    weight: 0.7
---
```

```markdown
On the client-x corpus, queries under 5 tokens produce a recall 40% lower than
longer queries when the cosine similarity threshold exceeds 0.85.

Measured on 2026-04-12 against the staging index (1.2M vectors, text-embedding-3-small).
```

---

**global/facts/fact--gpt4-turbo-context-window-128k.md**

```yaml
---
type: fact
created: 2026-01-15
date: 2024-01-10
stable: false
tags:
  - global/concepts/concept--large-language-models
edges:
  - target: global/sources/source--openai-gpt4-documentation
    type: derived_from
    weight: 0.9
---
```

```markdown
GPT-4 Turbo supports a context window of 128k tokens.

This applies to the gpt-4-turbo model specifically — not GPT-4o or other variants.
Verify against current OpenAI documentation as model specifications may change.
```
