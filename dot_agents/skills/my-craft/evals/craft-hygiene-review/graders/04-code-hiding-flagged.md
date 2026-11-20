---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale les mécanismes qui cachent le code dans OrderPipeline : les `#region` (Intake/State) et/ou la classe `partial` coupée en deux fichiers (OrderPipeline.cs + OrderPipeline.Import.cs) — ils masquent la visibilité réelle du code et les signaux faibles de sa complexité.
