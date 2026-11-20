---
type: llm
focus: trace
weight: 1
---

The request DTO carries only the client-supplied data (the list of product lines with name and price); no allowPartial/isPartial field is added to the body contract because of the option, and the query flag maps to the service's allowPartial parameter.
