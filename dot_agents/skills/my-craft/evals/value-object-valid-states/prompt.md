---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Réclamation client : une commande est arrivée avec une ligne à quantité zéro, et le panier l'a acceptée. Corrige le problème à la racine dans la solution Shop, pour que ça ne puisse tout simplement plus arriver. Ajoute aussi `TotalQuantity` sur `Cart` (la somme des quantités des lignes) et `TotalAmount` (la somme de Qty × UnitPrice).

Input files: Shop.slnx, Shop/Shop.csproj, Shop/OrderLine.cs, Shop/Cart.cs, Shop/ImportMapper.cs, Shop.UnitTests/Shop.UnitTests.csproj
