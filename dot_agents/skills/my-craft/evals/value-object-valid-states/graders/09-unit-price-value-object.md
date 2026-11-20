---
type: llm
focus: trace
weight: 1
---

La garde unitPrice < 0 plantée est traitée au même niveau : un value object UnitPrice (même forme que Quantity — record class, constructeur privé, fabrique) porte la règle, et la garde disparaît d'OrderLine.
