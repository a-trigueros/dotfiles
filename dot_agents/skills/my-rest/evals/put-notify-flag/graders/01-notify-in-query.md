---
type: llm
focus: trace
weight: 1
---

The notify option travels in the query string of the PUT route (e.g. PUT /users/{id}?notify=true) — not in the request body and not as a payload/DTO field.
