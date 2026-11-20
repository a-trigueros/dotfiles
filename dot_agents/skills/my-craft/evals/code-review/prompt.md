---
tags: [skill-creator]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Review le code du dossier src avant merge : liste les problèmes de design par gravité décroissante dans REVIEW.md, à la racine du dossier.

Contexte : Reservation est notre modèle du domaine, ReservationRow est l'entité EF Core mappée en base, ReservationApiModel est le payload renvoyé par l'API.

Input files: src/Reservation.cs, src/ReservationRow.cs, src/ReservationApiModel.cs
