private _load() {
  pushd "$HOME/.config/bifrost"
  export ZAI_API_KEY=$(op read "op://Alex/Zai - agentgateway/password")
}

private _unload() {
  unset ZAI_API_KEY
  popd
}

bf() (
  trap _unload EXIT
  _load
  bifrost -app-dir .
)
