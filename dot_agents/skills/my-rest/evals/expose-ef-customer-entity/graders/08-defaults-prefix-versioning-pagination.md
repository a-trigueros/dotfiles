---
type: llm
focus: trace
weight: 1
---

Defaults applied without being asked: routes carry the /api prefix and a version segment (/api/v1/...), unless the user opted out or the codebase has a large unversioned route surface; and any collection-returning endpoint is paginated (in .NET via Gridify — [FromQuery] GridifyQuery applied through a whitelisted IGridifyMapper returning Paging<T> — unless the user specified another method).
