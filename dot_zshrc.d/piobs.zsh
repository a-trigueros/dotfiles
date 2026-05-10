piobs() {
  _cleanup() {
    popd
  }

  trap _cleanup EXIT INT TERM

  pushd ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/Reboot/

  pi "$@"
}
