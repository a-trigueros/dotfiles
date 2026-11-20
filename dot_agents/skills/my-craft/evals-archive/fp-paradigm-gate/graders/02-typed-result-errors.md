---
type: llm
focus: trace
weight: 1
---

cancel est une fonction totale : les refus (déjà annulée, introuvable) sont des cas dédiés du canal d'erreur typé du Result (enum ou type dédié) — pas un booléen, pas une exception pour un refus métier.
