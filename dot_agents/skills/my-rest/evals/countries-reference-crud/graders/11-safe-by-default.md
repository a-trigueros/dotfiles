---
type: llm
focus: trace
weight: 1
---

Safe by default holds on both axes: (1) error transformation is centralized — failures map through global handlers / shared helpers with no inline try/catch mapping in the handlers, and no error body is fabricated on non-validation statuses; (2) authorization is closed by default via HTTP-level configuration (fallback policy or RequireAuthorization on the app/group) wired NOW — not deferred to a future step — with AllowAnonymous as the only opening mechanism.
