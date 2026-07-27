_load() {
  export ZAI_API_KEY=$(op read "op://Alex/Zai - agentgateway/password")
}

_unload() {
  unset ZAI_API_KEY
}

agw() {
  trap '_unload' EXIT
  _load
  agentgateway
}
