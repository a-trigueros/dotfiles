---
type: llm
focus: trace
weight: 1
---

L'import nocturne ne plante plus sur un pseudo déjà pris : la ligne en doublon est traitée explicitement (ignorée avec raison journalisée, ou échec collecté), jamais un catch vide ou silencieux, et les lignes suivantes sont traitées. Le comportement est couvert par un test.
