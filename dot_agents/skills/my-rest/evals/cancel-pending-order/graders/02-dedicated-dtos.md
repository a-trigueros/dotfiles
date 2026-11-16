---
type: llm
focus: trace
weight: 1
---

No EF/domain Order entity is accepted or returned on the wire; wherever a body exists (request or response), it uses dedicated request/response DTOs. Operations with no body (e.g. 204 No Content) satisfy this by carrying nothing.
