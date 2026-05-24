---
description: Create one or many notes in Obsidian vault
agent: libraire
---

- Crée une nouvelle note dans le vault Obsidian de l'utilisateur.
- Demande à l'utilisateur s'il manque des informations avant de commencer.
- Source les informations (URL, date).

## Ton et style

- Ton professionnel, factuel, sans émojis.
- Pas de tournures narratives ou "article de blog". La note est une référence, pas un texte explicatif.
- Sections courtes. Tableaux et listes plutôt que des paragraphes.

## Contenu

- Présenter d'abord la valeur / le problème résolu (1-2 phrases max), puis les détails.
- Exclure les informations éphémères : nombre d'étoiles GitHub, statut alpha/beta, version courante, roadmap.
- Les attributs stables (licence, langage, site) vont dans le frontmatter, pas dans le corps.

## Frontmatter

- `Licence` : attribut dédié (ex: `Licence: MIT`), pas un tag.
- Pas de champ `Statut` ni de version dans le frontmatter.

## Liens

- Créer des wikilinks `[[Nom]]` vers des notes existantes ET vers des notes qui n'existent pas encore, dès qu'un concept mérite une note propre.
- Créer des wikilinks `[[Nom]]` vers des notes existantes ET vers des notes qui n'existent pas encore, dès qu'un outil est cité.
- Ajouter une section "Voir aussi" avec les liens les plus pertinents.

La note concerne $ARGUMENTS
