---
type: llm
focus: trace
weight: 1
---

La réponse explique pourquoi la vérification applicative ne suffit pas : un état contrôlé OK pendant la transaction peut être invalide au commit (écrivain concurrent, fenêtre de race) — la contrainte est le dernier filet de sécurité qui préserve l'intégrité des données.
