---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (Minimal API) un endpoint pour créer un item défini par un nom et une description. Lorsque la création est demandée avec l'option draft, l'item est créé en brouillon (statut Draft côté domaine) ; sinon il est créé directement publié. IItemService.Create(string name, string description, bool asDraft) existe déjà. Écris le code nécessaire (endpoint, DTOs). Le projet est déjà initialisé.
