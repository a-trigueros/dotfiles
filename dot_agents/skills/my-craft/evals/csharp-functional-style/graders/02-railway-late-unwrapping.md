---
type: llm
focus: trace
weight: 1
---

La composition est railway et le dépliage est tardif : le code ajouté passe par Map/Bind (ou des switch expressions) et ne déplie pas le Result en milieu de module — aucun Match/TryGet/GetOrDefault dans le code de production ajouté (les assertions de test peuvent déplier, c'est leur rôle).
