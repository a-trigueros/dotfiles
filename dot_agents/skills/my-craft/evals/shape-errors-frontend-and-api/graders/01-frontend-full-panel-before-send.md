---
type: llm
focus: trace
weight: 1
---

Le formulaire (web/booking-form.ts) vérifie le titre ET les dates avant tout envoi et remonte toutes les violations ensemble — plus de premier échec qui masque les autres, et aucune de ces vérifications ne nécessite d'appel réseau.
