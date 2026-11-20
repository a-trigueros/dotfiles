---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Dans la solution Booking, ajoute l'annulation : `cancel` prend un ReservationId et le dictionnaire des réservations, passe la réservation à Cancelled, et refuse l'opération si la réservation est déjà annulée ou si l'id est introuvable. Ajoute les tests qui vont avec.

Input files: Booking.slnx, Booking/Booking.csproj, Booking/Domain.cs, Booking.UnitTests/Booking.UnitTests.csproj, Booking.UnitTests/Tests.cs
