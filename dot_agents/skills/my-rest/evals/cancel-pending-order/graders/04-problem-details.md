---
type: llm
focus: trace
weight: 1
---

Validation-type errors (400/422) carry RFC 7807 ProblemDetails bodies naming the offending fields; other statuses (401/403/404/409/500) rely on the bare status code — no fabricated error body.
