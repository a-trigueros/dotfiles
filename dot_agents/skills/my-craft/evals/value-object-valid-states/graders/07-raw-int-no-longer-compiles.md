---
type: llm
focus: trace
weight: 1
---

Passer un int brut là où la quantité est attendue (ex. cart.Add("A-100", 0, 5m)) ne compile plus : l'état illégal est rendu non représentable jusqu'au compilateur, pas seulement rejeté à l'exécution.
