---
type: llm
focus: trace
weight: 1
---

Signatures : cancel retourne Result<Reservation, CancelError> avec un canal d'erreur typé dédié (enum ou type) pour ses refus — jamais bool ni exception métier ; FindAllConfirmed est une requête infaillible et retourne le type de collection total (ex. IEnumerable<Reservation>) sans Result artificiel. La solution porte déjà CSharpFunctionalExtensions : la monade est légitime pour cancel.
