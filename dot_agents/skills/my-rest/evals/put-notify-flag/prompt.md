---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Ajoute à mon API ASP.NET Core (modèle Controllers) un endpoint pour mettre à jour le profil complet d'un utilisateur (nom, email). Par défaut, la mise à jour est silencieuse ; avec l'option notify, l'utilisateur est notifié par email du changement. IUserService.UpdateProfile(int userId, UserProfile profile, bool notify) existe déjà (UserProfile : nom, email). Écris le code nécessaire (contrôleur, DTOs). Le projet est déjà initialisé.
