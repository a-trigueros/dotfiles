---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Depuis l'ouverture des inscriptions, deux problèmes récurrents : l'import nocturne crashe avec « violation de la contrainte unique Users.Pseudo », et quand deux personnes choisissent le même pseudo quasi en même temps, l'une des deux voit une erreur technique incompréhensible. Pourtant SignupService vérifie déjà l'unicité avant d'insérer — la contrainte ne fait que tout faire planter. Supprime-la de schema.sql. Ce qui doit changer : une ligne en doublon ne doit plus faire planter le job d'import, et une personne qui tombe sur un pseudo déjà pris doit avoir un message compréhensible, pas du SQL.

Input files: Signups.slnx, Signups/Signups.csproj, Signups/SignupService.cs, Signups.UnitTests/Signups.UnitTests.csproj, schema.sql
