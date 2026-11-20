---
type: llm
focus: trace
weight: 1
---

Stock.Reserve signale le stock insuffisant par une exception métier typée (classe dédiée, ex. InsufficientStockException) ou un type résultat dédié — pas un booléen de succès, pas une ArgumentException ou InvalidOperationException générique utilisée comme rejet métier.
