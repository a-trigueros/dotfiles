---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (modèle Controllers) un endpoint pour permettre à un client d'annuler une commande en attente. Une commande ne peut être annulée que lorsqu'elle est au statut Pending. La logique métier existe déjà : IOrderService.CancelOrder(int orderId) lève une OrderCannotBeCancelledException si le statut ne le permet pas. Écris le code nécessaire (contrôleur, DTOs). Le projet est déjà initialisé.
