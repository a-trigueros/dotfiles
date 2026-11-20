---
type: llm
focus: trace
weight: 1
---

The create DTO carries only the client-supplied item data (name, description); no draft/isDraft/asDraft field is added to the DTO or expected in the body because of the option, and the query flag maps to the service's asDraft parameter.
