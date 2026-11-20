---
type: llm
focus: trace
weight: 1
---

One DELETE route exposes both behaviors: without the flag the call reaches the physical delete (IUserService.DeleteUser), with the flag it reaches the logical delete (IUserService.HideUser); neither behavior is unreachable or moved to a different route.
