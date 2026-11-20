---
type: llm
focus: trace
weight: 1
---

Les règles de forme du pseudo (trim des espaces parasites, longueur 3–25, lettres/chiffres/tirets, pas de tiret en tête ni en queue) vivent dans un value object Pseudo construit à la frontière — pas en guard clauses sur string éparpillées dans User ou ailleurs.
