cloclo() {
  typeset -gA _blaude_saved=(
    ANTHROPIC_BASE_URL          "$ANTHROPIC_BASE_URL"
    ANTHROPIC_AUTH_TOKEN        "$ANTHROPIC_AUTH_TOKEN"
    ANTHROPIC_DEFAULT_OPUS_MODEL   "$ANTHROPIC_DEFAULT_OPUS_MODEL"
    ANTHROPIC_DEFAULT_SONNET_MODEL "$ANTHROPIC_DEFAULT_SONNET_MODEL"
    ANTHROPIC_DEFAULT_HAIKU_MODEL  "$ANTHROPIC_DEFAULT_HAIKU_MODEL"
  )

  _restore() {
    local v
    for v in "${(k)_blaude_saved[@]}"; do
      if [[ -n "${_blaude_saved[$v]}" ]]; then
        export "$v=${_blaude_saved[$v]}"
      else
        unset "$v"
      fi
    done
  }
  trap _restore EXIT INT TERM

  local key
  key=$(op read 'op://Alex - Services/BIFROST_VKEY_PI/password') || {
    echo "blaude: lecture 1Password échouée (op)" >&2
    return 1
  }
  [[ -n "$key" ]] || { echo "blaude: clé BIFROST_VKEY_PI vide" >&2; return 1; }

  # 127.0.0.1 et non localhost : Bifrost n'écoute qu'en IPv4, Node tenterait ::1 en premier
  export ANTHROPIC_BASE_URL="http://127.0.0.1:16000/anthropic"
  export ANTHROPIC_AUTH_TOKEN="$key"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="zai/glm-5.3"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="zai/glm-5.3-flash"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="zai/glm-5.3-flash"

  claude "$@"
}
