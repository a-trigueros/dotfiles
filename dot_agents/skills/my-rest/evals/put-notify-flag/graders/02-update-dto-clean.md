---
type: llm
focus: trace
weight: 1
---

The request DTO carries only the profile data (name, email) — the complete representation PUT semantics require; no notify/isNotified field is added to the body contract because of the option, and the query flag maps to the service's notify parameter.
