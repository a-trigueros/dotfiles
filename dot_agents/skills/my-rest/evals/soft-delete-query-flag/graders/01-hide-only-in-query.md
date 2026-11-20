---
type: llm
focus: trace
weight: 1
---

The hide-only option travels in the query string of the DELETE route (e.g. DELETE /users/{id}?hideOnly=true) — not in a request body, not as a payload/DTO field, and not behind a separate intention-revealing sub-resource route (e.g. POST /users/{id}/hiding).
