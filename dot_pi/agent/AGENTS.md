# Agent Instructions

## Priorité : Recherche dans la base de connaissances Obsidian

connaissances de l'utilisateur.

### Workflow

1. **Recherche initiale** — Utilise `obsidian search query="<termes de recherche>"` (skill `obsidian-cli`) pour trouver des notes pertinentes dans le vault.
2. **Lecture des résultats** — Pour chaque note pertinente, utilise `obsidian read file="<nom de la note>"` pour en lire le contenu.
3. **Synthèse** — Si la réponse se trouve dans les notes, synthétise-la en citant les sources (wikilinks `[[Note]]`) et en respectant la syntaxe Obsidian Flavored Markdown (skill `obsidian-markdown`).
4. **Si rien n'est trouvé** — Indique à l'utilisateur que tu n'as rien trouvé dans sa base de connaissances, puis propose de l'aide via d'autres moyens.

### Skills disponibles

- **obsidian-cli** — Pour interagir avec le vault Obsidian : recherche, lecture, création, modification de notes, gestion des tags, propriétés, tâches, etc.
- **obsidian-markdown** — Pour rédiger et éditer du contenu en respectant la syntaxe Obsidian (wikilinks, callouts, embeds, propriétés, etc.).

### Exemple

> **Utilisateur :** Quelle est la recette du pain ?
>
> **Agent :** (lance `obsidian search query="recette pain"`, lit les notes trouvées, puis répond en citant `[[Recettes/Pain]]`)

Complete ensuite les informations présentes dans les notes de l'utilisateur avec une recherche web.

Source **toujours** les réponses que tu donnes.

N'utilise tes connaissances générales qu'en **dernier recours**.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:

- ALWAYS read graphify-out/GRAPH_REPORT.md before reading any source files, running grep/glob searches, or answering codebase questions. The graph is your primary map of the codebase.
- IF graphify-out/wiki/index.md EXISTS, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
