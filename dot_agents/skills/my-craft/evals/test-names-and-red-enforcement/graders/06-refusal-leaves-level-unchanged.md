---
type: llm
focus: trace
weight: 1
---

Un refus laisse le niveau de stock inchangé : l'implémentation vérifie avant toute mutation (no half-baked states), et un test cristallise cette propriété (le niveau reste au niveau initial après un refus).
