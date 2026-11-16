---
type: llm
focus: trace
weight: 1
---

Boundary parsing uses verification-forcing patterns — a throwing Parse whose failure becomes 400/422 through the normal error path, or a typed result carrying the failure — not bool TryXXX methods whose boolean can be ignored.
