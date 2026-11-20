---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Dans la solution Warehouse, ajoute la réservation de stock : `Reserve(sku, quantity)` doit décrémenter le niveau disponible du SKU et refuser la réservation quand le stock disponible est insuffisant. Couvre ce comportement de tests.

Input files: Warehouse.slnx, Warehouse/Warehouse.csproj, Warehouse/Stock.cs, Warehouse.UnitTests/Warehouse.UnitTests.csproj
