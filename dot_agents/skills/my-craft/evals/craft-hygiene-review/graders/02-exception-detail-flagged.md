---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale le `throw ex;` dans OrderPipeline.Enqueue : rethrower en nommant l'exception reconstruit la stack trace au point du catch et perd le détail et le site d'origine de la failure — le rethrow bare `throw;` préserve l'exception originale (CA2200).
