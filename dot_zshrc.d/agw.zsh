_load() {
  export ZAI_APIKEY=$(op read "op://Alex/Zai - agentgateway/password")
}

_unload() {
  unset ZAI_APIKEY
}

agw() {
  trap '_unload' EXIT
  _load
  curl https://api.z.ai/api/coding/paas/v4/models \
  -H "Authorization: Bearer $ZAI_APIKEY"
  agentgateway
}
