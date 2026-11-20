---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale le désordre des membres d'OrderPipeline : l'ordre attendu est constantes → champs privés injectés → champs d'instance privés → propriétés → méthodes publiques → méthodes privées — or Enqueue (méthode publique) ouvre la classe et QueueDepth (propriété) précède MaxDraftsPerDay (constante), pending (champ d'instance) et les champs injectés.
