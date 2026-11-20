---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale que la story PlaceOrder est éclatée en trois fichiers (PlaceOrderCommand.cs, PlaceOrderValidator.cs, PlaceOrderHandler.cs) : en story-driven / CQRS, la commande ou query, ses dépendances, ce qu'elle renvoie, les validateurs et le handler vivent dans le même fichier, dans cet ordre (commande → dépendances → résultat → validateurs → handler).
