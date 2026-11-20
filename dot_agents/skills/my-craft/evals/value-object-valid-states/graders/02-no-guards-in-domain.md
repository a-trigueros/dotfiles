---
type: llm
focus: trace
weight: 1
---

OrderLine et Cart ne contiennent plus aucune guard clause sur la quantité (pas de quantity <= 0 ni ArgumentException associée) : ils acceptent Quantity et portent zéro validation de la quantité.
