---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (modèle Controllers) un endpoint pour importer des produits par lots : le client envoie une liste de lignes de produits (nom, prix). Par défaut, si une ligne est invalide, l'import entier est rejeté ; avec l'option allowPartial, les lignes valides sont importées et les lignes invalides sont ignorées. La logique métier existe déjà : IProductImportService.Import(IReadOnlyList<ProductLine> lines, bool allowPartial) retourne un ProductImportResult (ImportedCount, SkippedLines). Écris le code nécessaire (contrôleur, DTOs). Le projet est déjà initialisé.
