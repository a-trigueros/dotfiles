---
type: llm
focus: trace
weight: 1
---

Cancellation is exposed as a domain-intent route on a sub-resource (e.g. POST /orders/{orderId}/cancellations or another intention-revealing route), not as a PUT/PATCH that writes a status field on the full order representation.
