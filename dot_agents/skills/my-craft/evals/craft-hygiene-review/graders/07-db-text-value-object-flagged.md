---
type: llm
focus: trace
weight: 1
---

REVIEW.md signale au moins un texte voué à la base qui passe sans value object : la ShippingLabel concaténée à la main dans OrderPipeline.Enqueue (le commentaire annonce qu'elle atterrit dans la colonne Orders.ShippingLabel) et/ou les Notes écrites brutes dans CustomerRow — un texte destiné à une colonne doit passer par un value object qui garantit sa pertinence (format, vocabulaire) et l'assainit mécaniquement au parse (trim, casse, espacements).
