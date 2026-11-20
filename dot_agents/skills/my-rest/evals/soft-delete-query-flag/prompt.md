---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (modèle Controllers) un endpoint pour supprimer un utilisateur. Deux comportements sont attendus : par défaut la suppression est physique (IUserService.DeleteUser(int userId) existe déjà) ; avec l'option hide-only, la suppression est logique — l'utilisateur est marqué caché sans être retiré de la base (IUserService.HideUser(int userId) existe déjà). Écris le code nécessaire (contrôleur, DTOs si besoin). Le projet est déjà initialisé.
