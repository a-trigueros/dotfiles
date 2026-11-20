---
type: llm
focus: trace
weight: 1
---

Style fonctionnel interne : FindAllConfirmed s'écrit par composition LINQ (Where/Select/Values) sans foreach ni accumulateur ; le branchement sur le statut s'écrit en switch expression ou en pattern matching, pas en cascade if/else ; aucun paramètre de fonction n'est muté.
