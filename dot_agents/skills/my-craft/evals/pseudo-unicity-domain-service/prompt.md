---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Sur la solution Users : chaque membre peut choisir un pseudonyme et le changer. Règle métier : le pseudonyme doit être unique dans toute la base de données. Ajoute ce comportement dans le domaine. Un pseudo valide : 3 à 25 caractères, lettres/chiffres/tirets, pas de tiret en tête ni en queue, et on retire les espaces parasites autour avant tout. L'unicité se vérifie en base — pour les tests, un doublon en mémoire suffit. schema.sql représente la base : ce qui doit y être vrai doit aussi y être vrai.

Input files: Users.slnx, Users/Users.csproj, Users/User.cs, Users.UnitTests/Users.UnitTests.csproj, schema.sql
