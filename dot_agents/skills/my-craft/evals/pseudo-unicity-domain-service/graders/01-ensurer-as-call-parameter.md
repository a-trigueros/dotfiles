---
type: llm
focus: trace
weight: 1
---

La méthode qui pose le pseudo sur User reçoit le vérificateur d'unicité en paramètre d'appel (double dispatch) : l'agrégat reçoit la réponse et reste responsable de l'appliquer. Aucune injection du vérificateur dans User par un conteneur DI, aucune orchestration des étapes depuis l'extérieur de l'agrégat.
