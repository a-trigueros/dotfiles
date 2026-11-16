---
type: llm
focus: trace
weight: 1
---

AsNoTracking is not used redundantly on Select projections (projection queries to non-entity types are never tracked); it appears only where entities are materialized for read-only use.
