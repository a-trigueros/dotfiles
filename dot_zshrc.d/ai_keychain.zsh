readonly _AK_OPENROUTER_REF="op://Alex/OpenRouter - Shell/identifiant"

ak_load() {
  export SHELL_OPENROUTER_API_KEY="$(op read "$_AK_OPENROUTER_REF")"
  export SHELL_OMLX_API_KEY="local"
}

ak_unload() {
  unset SHELL_OPENROUTER_API_KEY
  unset SHELL_OMLX_API_KEY
}

ak() {
  case "$1" in
    load)   ak_load ;;
    unload) ak_unload ;;
    *)      trap 'ak_unload' EXIT
            ak_load
            "$@"
            ;;
  esac
}
