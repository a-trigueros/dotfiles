---
tags: [skill-creator]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Review le code du dossier src avant merge : liste les problèmes de design par gravité décroissante dans REVIEW.md, à la racine du dossier.

Contexte : OrderPipeline orchestre l'intake des drafts de commande ; PlaceOrder est notre story CQRS ; CustomerRow est l'entité EF Core mappée en base et CustomerApiModel le payload renvoyé au frontend.

Input files: src/OrderPipeline.cs, src/OrderPipeline.Import.cs, src/PlaceOrderCommand.cs, src/PlaceOrderValidator.cs, src/PlaceOrderHandler.cs, src/CustomerRow.cs, src/CustomerApiModel.cs
