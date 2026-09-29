#!/usr/bin/env bash
# Enrichit base-costs.json avec le provider 'zai' (API directe Z.AI).
# Liste des modèles : endpoint LIVE du GLM Coding Plan (/v4/models) -> toujours à jour.
# Prix : models.dev (provider 'zai') quand le modèle y figure.
# Idempotent. À relancer après chaque "Refresh base costs" de l'UI (qui écrase le fichier).
#
# Lancement (clé depuis 1Password via fnox) :
#   fnox exec -- ~/.config/agentgateway/add-zai-provider.sh
set -euo pipefail

DIR="${HOME}/.config/agentgateway"
FILE="${DIR}/base-costs.json"
DEV_URL="https://models.dev/api.json"
ZAI_MODELS_URL="https://api.z.ai/api/coding/paas/v4/models"
PROVIDER="zai"   # doit correspondre à provider.custom.providerOverride dans config.yaml

command -v jq    >/dev/null || { echo "erreur: jq requis" >&2; exit 1; }
command -v curl  >/dev/null || { echo "erreur: curl requis" >&2; exit 1; }
[[ -f "$FILE" ]]            || { echo "erreur: $FILE introuvable" >&2; exit 1; }
[[ -n "${ZAI_API_KEY:-}" ]] || { echo "erreur: ZAI_API_KEY absente — lancez : fnox exec -- $0" >&2; exit 1; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# 1. Modèles réellement exposés par le Coding Plan (source de vérité pour la liste)
curl -fsSL --max-time 30 -H "Authorization: Bearer $ZAI_API_KEY" "$ZAI_MODELS_URL" -o "$TMP/zai.json"
ZAI_IDS=$(jq -c '[.data[].id] | sort | unique' "$TMP/zai.json")
N_ZAI=$(jq 'length' <<< "$ZAI_IDS")
[[ "$N_ZAI" -gt 0 ]] || { echo "erreur: liste vide de l'endpoint Z.AI" >&2; exit 1; }

# 2. Prix depuis models.dev (provider zai), tolérance panne réseau/absence
HAS_DEV=0
if curl -fsSL --max-time 30 "$DEV_URL" -o "$TMP/dev.json" 2>/dev/null \
   && jq -e --arg p "$PROVIDER" '.[$p].models' "$TMP/dev.json" >/dev/null 2>&1; then
  HAS_DEV=1
else
  echo "warn: models.dev indisponible ou sans '$PROVIDER' — modèles sans prix" >&2
fi

# 3. Bloc provider : tous les modèles du Coding Plan, prix quand connus
if [[ "$HAS_DEV" == 1 ]]; then
  BLOCK=$(jq -n --arg p "$PROVIDER" --argjson ids "$ZAI_IDS" --slurpfile dev "$TMP/dev.json" '
    ($dev[0][$p].models // {}) as $devm
    | reduce $ids[] as $id ({};
        ($devm[$id].cost // null) as $c
        | if $c == null then .[$id] = {}
          else
            ({input: $c.input, output: $c.output,
              cacheRead: $c.cache_read, cacheWrite: $c.cache_write}
             | map_values(if . != null then tostring else null end)) as $r
            | .[$id] = (if ($r | length) == 0 then {} else {rates: $r} end)
          end)
    | {models: .}
  ')
else
  BLOCK=$(jq -n --argjson ids "$ZAI_IDS" '{models: ($ids | map({key: ., value: {}}) | from_entries)}')
fi

# 4. Fusion atomique + contrôle d'intégrité
BAK="${FILE}.bak.$(date +%Y%m%d-%H%M%S)"
cp "$FILE" "$BAK"
jq --arg p "$PROVIDER" --argjson block "$BLOCK" '.providers[$p] = $block' "$FILE" > "${FILE}.tmp"
jq -e . "${FILE}.tmp" >/dev/null || { echo "erreur: JSON invalide, fichier non modifié" >&2; exit 1; }
mv "${FILE}.tmp" "$FILE"

N_WITH=$(jq -r --arg p "$PROVIDER" '[.providers[$p].models[] | select(.rates.input)] | length' "$FILE")
echo "OK : provider '$PROVIDER' = $N_ZAI modèles du Coding Plan ($N_WITH avec prix models.dev)"
echo "     Reload : automatique (watcher)"
# succès => la sauvegarde ne sert plus à rien
rm -f "$BAK"
