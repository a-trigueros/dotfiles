---
type: llm
focus: trace
weight: 1
---

Le fallback du stock pour un SKU inconnu (niveau 0 ⇒ refus) est validé par un test explicite : les valeurs par défaut et fallbacks fournis par le code sont du knowledge — chaque comportement fallback est cristallisé par un test dédié énonçant le comportement (ex. Fail.When_the_sku_is_unknown), jamais laissé implicite derrière le calcul du niveau disponible.
