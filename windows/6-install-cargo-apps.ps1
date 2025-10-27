# TODO : SETUP Build tools

rustup default stable

# Essential tools for PowerShell profile
if ($env:PROCESSOR_ARCHITECTURE -ne 'ARM64')
{
  cargo install atuin
}

cargo install --locked tree-sitter-cli

# Optional but recommended
# cargo install bat # Already available via winget (sharkdp.bat)
# cargo install fd-find  # Already available via winget (sharkdp.fd)
# cargo install ripgrep  # Already available via winget (BurntSushi.ripgrep.MSVC)
