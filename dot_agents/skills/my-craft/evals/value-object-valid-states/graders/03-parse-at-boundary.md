---
type: llm
focus: trace
weight: 1
---

ImportMapper obtient la quantité via une fabrique du value object (Parse appliqué à la chaîne brute, ou From recevant l'entier produit par int.Parse) : la validation unique de la quantité vit dans le value object — jamais en aval, jamais transmise au constructeur d'OrderLine.
