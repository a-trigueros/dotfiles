---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale l'absence de jeton de concurrence sur CustomerRow (aucune colonne rowversion / [Timestamp]) : utiliser les fonctionnalités de versioning de l'ORM et transmettre cette version au frontend — présente dans le read model CustomerApiModel et renvoyée avec l'écriture — pour qu'une écriture concurrente lève une exception au lieu d'écraser accidentellement des informations.
