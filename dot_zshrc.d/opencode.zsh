oc() {
  _cleanup() {
    rm -rf ./.opencode
  }

  trap _cleanup EXIT INT TERM

  git clone \
    --depth 1 \
    --single-branch \
    --no-tags \
    git@github.com:a-trigueros/opencode.git .opencode

  opencode "$@"
}
