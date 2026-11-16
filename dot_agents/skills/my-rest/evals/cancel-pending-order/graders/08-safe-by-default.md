---
type: llm
focus: trace
weight: 1
---

Safe by default holds on both axes: (1) error transformation is centralized — business failures map to their status codes in one place (global exception handler / IExceptionHandler / shared helper, bare statuses per the body policy — e.g. a 409 with no body), with no inline try/catch business-exception mapping in the actions; (2) authorization is closed by default via HTTP-level configuration (fallback policy or RequireAuthorization on the app/group), with AllowAnonymous as the only opening mechanism, and no per-endpoint [Authorize] sprinkled as the default protection.
