---
type: llm
focus: trace
weight: 1
---

L'implémentation reste dans l'idiome fonctionnel existant : cancel est une fonction statique pure du module (ou une composition Result/Map/Bind dans ce style) sur des records immuables — le record Reservation n'acquiert ni méthode métier ni setter, et aucune classe de service instanciable, interface ou injection de dépendances n'est introduite pour ce besoin.
