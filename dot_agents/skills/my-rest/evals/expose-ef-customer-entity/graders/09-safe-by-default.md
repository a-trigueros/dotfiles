---
type: llm
focus: trace
weight: 1
---

Safe by default holds on both axes: (1) error transformation is centralized — failures map through one global handler / shared helper with no inline try/catch mapping in the actions, and no error body is fabricated on non-validation statuses; (2) authorization is closed by default via HTTP-level configuration (fallback policy or RequireAuthorization on the app/group) — endpoints holding personal data are NOT left anonymous with only a README flag; AllowAnonymous is the only opening mechanism. When the host has no authentication scheme yet, a deliberate documented deferral naming the fallback policy to wire when a scheme lands is acceptable — endpoints left open by oversight always fail.
