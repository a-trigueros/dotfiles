---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Sur le formulaire web/booking-form.ts et l'API de la solution Booking : les utilisateurs soumettent des réservations avec un titre vide ou une date de fin antérieure à la date de début. Côté client rien ne l'empêche (seul le titre est vérifié, une erreur à la fois) ; côté serveur la demande finit en 500 sans aucune explication. Corrige pour que chaque erreur de saisie soit signalée complètement, là où c'est le plus utile pour l'utilisateur.

Input files: Booking.slnx, Booking.Api/Booking.Api.csproj, Booking.Api/Program.cs, Booking.Api/Booking.cs, Booking.UnitTests/Booking.UnitTests.csproj, web/booking-form.ts
