---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale l'usage de DateTime.Now dans OrderPipeline.Enqueue : la date/heure est une dépendance injectée (I/O), jamais une propriété statique ambiante — en .NET, TimeProvider injecté, comme le fait déjà PlaceOrderHandler (substituable en test par FakeTimeProvider).
