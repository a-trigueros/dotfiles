---
type: llm
focus: trace
weight: 1
---

Generated code carries no comments at all — no XML-doc, no inline narration, no shortcut flags in .cs files; design rationale, limits, and shortcuts live in the README, and ambiguous contract decisions are asked of the user rather than guessed. Sole exception: a single why-comment in non-contract infrastructure/tooling classes (OpenAPI document transformers, doc-emitting handlers) carrying information no signature can express — contract and endpoint code stays comment-free.
