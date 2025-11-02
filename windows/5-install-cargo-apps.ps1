# TODO : SETUP Build tools

rustup default stable

# Essential tools for PowerShell profile
cargo install --git https://github.com/ltrzesniewski/atuin.git --branch powershell-pr
cargo install --locked tree-sitter-cli

# Optional but recommended
# cargo install bat # Already available via winget (sharkdp.bat)
# cargo install fd-find  # Already available via winget (sharkdp.fd)
# cargo install ripgrep  # Already available via winget (BurntSushi.ripgrep.MSVC)

Write-Host "`nIf something went wrong, try again from a developper command prompt." -ForegroundColor Blue
