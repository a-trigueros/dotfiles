---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (modèle Controllers) un endpoint pour retirer l'accès d'un utilisateur : par défaut son compte est désactivé, mais avec l'option wipe, toutes ses données personnelles sont anonymisées de façon irréversible (conformité RGPD). IUserService.Deactivate(int userId) et IUserService.WipePersonalData(int userId) existent déjà. Écris le code nécessaire (contrôleur, DTOs si besoin). Le projet est déjà initialisé.
