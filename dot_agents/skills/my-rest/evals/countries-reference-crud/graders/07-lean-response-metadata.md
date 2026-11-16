---
type: llm
focus: trace
weight: 1
---

No [Produces], [ProducesResponseType], ProducesProblem() or ProducesValidationProblem() annotations, and no FastEndpoints Description/Produces restatements. Error bodies exist only on validation responses (400/422 — RFC 7807 Problem Details naming the fields); other statuses (401/403/404/409/500) return the bare status code with no fabricated body.
