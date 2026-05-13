# Agent Instructions

## Sources de connaissance

Tu disposes de trois sources de connaissance. Consulte-les toujours dans l'ordre de priorité défini ci-dessous.

| Source | Emplacement | Accès |
|--------|-------------|-------|
| **Graphe Vault** | `~/.local/obsidian/graphify/notes/` | `graphify query/path/explain` |
| **Vault Obsidian** | `~/.local/obsidian/notes/` | `obsidian-cli` |
| **Graphe Projet** | `{CWD}/../graphify/{CWD_BASENAME}/` | `graphify query/path/explain` — si le dossier existe |

---

## Règles de routing

Avant de répondre, interroge les sources dans l'ordre strict ci-dessous. Dès qu'une source fournit une réponse satisfaisante, tu peux arrêter. Les réponses des sources 1-3 peuvent être enrichies par la source 4 (web/connaissances générales) pour compléter le contexte, mais ne jamais contredire une source de rang supérieur.

```
❶ Graphe vault     (~/.local/obsidian/graphify/notes/)
   → graphify query "<question>" — si réponse satisfaisante → répondre
❷ Vault Obsidian   (~/.local/obsidian/notes/)
   → obsidian search query="<termes>" → lire les notes → répondre
❸ Graphe projet    ({CWD}/../graphify/{CWD_BASENAME}/)
   → graphify query "<question>" — si le dossier existe → répondre
❹ Connaissances générales / web
   → dernier recours — citer systématiquement la provenance
```

### Règle de sourçage

Toute réponse doit indiquer sa provenance :

| Source | Format de citation |
|--------|-------------------|
| Graphe vault | `[Graphe vault] Nœud X → Nœud Y` ou `[Graphe vault] nœud:label`, avec `source_file` |
| Vault Obsidian | `[[Note]]` (wikilink syntaxe Obsidian) |
| Graphe projet | `[Graphe projet] Nœud X`, avec `source_file` |
| Web | URL de la page |
| Connaissances générales | `[Connaissances générales]` |

---

## 1. Vault Obsidian — base de connaissances personnelle

Contrainte:

- Le seul moyen d'intéragir avec la vault est d'utiliser **exclusivement** `obsidian-cli`.

### Workflow

1. **Recherche initiale** — `obsidian search query="<termes>"` pour trouver les notes pertinentes
2. **Lecture** — `obsidian read file="<nom>"` pour chaque note pertinente
3. **Graph vault** — si la recherche textuelle ne suffit pas, lis `~/.local/obsidian/graphify/notes/GRAPH_REPORT.md` pour naviguer par concepts et relations
4. **Synthèse** — cite les sources en wikilinks `[[Note]]`, respecte la syntaxe Obsidian Flavored Markdown (skill `obsidian-markdown`)
5. **Si rien trouvé** — indique-le explicitement, puis complète avec une recherche web

### Exemple

> **Utilisateur :** Quelle est ma convention de nommage pour les composants React ?
>
> **Agent :** lance `obsidian search query="convention nommage React composant"` → lit les notes trouvées → répond en citant `[[Conventions/React]]`

### Skills disponibles

- **obsidian-cli** — recherche, lecture, création, modification de notes, tags, propriétés, tâches
- **obsidian-markdown** — rédiger en syntaxe Obsidian (wikilinks, callouts, embeds, propriétés)

---

## 2. Graph vault

Le graph est ta carte primaire.

### Workflow

1. **Orientation** — lis `~/.local/obsidian/graphify/notes/GRAPH_REPORT.md` (god nodes, communautés, connexions surprenantes)
2. **Navigation** — pour les questions de relations entre modules, préfère les commandes graphify aux recherches fichier :
   - `graphify query "<question>"` — contexte large autour d'un concept (BFS)
   - `graphify query "<question>" --dfs` — tracer un chemin précis
   - `graphify path "<A>" "<B>"` — chemin le plus court entre deux concepts
   - `graphify explain "<concept>"` — tout ce qui est connecté à un nœud

3. **Lecture ciblée** — lis les fichiers source uniquement pour les détails d'implémentation que le graph ne contient pas
4. **Après modification de code** — lance `graphify update .` pour maintenir le graph à jour (AST uniquement, sans coût LLM)

### Croiser vault et codebase

Quand une question croise savoir-faire personnel et code existant :

1. Cherche la convention ou décision dans le vault (`obsidian search`)
2. Localise le point d'application dans le code (`graphify query` ou `graphify path`)
3. Synthétise en citant les deux sources

> **Exemple :** "Comment dois-je structurer ce nouveau module ?"
> → `graphify query "module structure"` pour voir comment les modules existants sont organisés
> → `obsidian search query="architecture module structure"` pour les conventions
> → répond en appliquant les conventions personnelles à la structure observée dans le code

### Déterminer le graphe à utiliser

- **Question sur le savoir personnel, une convention, une technologie** → graphe vault (`~/.local/obsidian/graphify/notes/`)
- **Question sur le projet courant** → graphe projet (`{CWD}/../graphify/{CWD_BASENAME}/`) s'il existe, sinon graphe vault
- **Question générale** → graphe vault d'abord

### Important

- Le graph est ta carte primaire
- Le graph est rarement accessible depuis le dossier dans lequel l'agent s'exécute. Arrange-toi pour toujours être explicite quand à la localisation du path.
- Pour construire un graphe : `graphify <chemin>` — la sortie ira automatiquement dans `{chemin}/../graphify/{nom_dossier}/`

### Skills disponibles

- **graphify** — api pour construire et interroger le graphe

---

## Priorité de consultation

1. Graphe vault     (~/.local/obsidian/graphify/notes/)
2. Vault Obsidian   (~/.local/obsidian/notes/)
3. Graphe projet    ({CWD}/../graphify/{CWD_BASENAME}/)
4. Fichiers source  (lecture directe, ciblée)
5. Recherche web
6. Connaissances générales
