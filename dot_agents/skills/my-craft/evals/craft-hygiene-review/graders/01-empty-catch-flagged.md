---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale le catch vide de OrderPipeline.Enqueue (`catch (InvalidOperationException)` sans aucune instruction ni commentaire) : un bloc catch qui ne fait rien est interdit s'il ne porte pas un commentaire expliquant pourquoi ignorer est correct — tel quel, il avale l'exception en silence.
