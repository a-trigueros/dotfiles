# config.nu
#
# Installed by:
# version = "0.111.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

source ./themes/catppuccin_macchiato.nu

$env.EDITOR = "nvim"
$env.config.edit_mode = 'vi'

let autoloadPath = $nu.default-config-dir | path join autoload
^atuin init nu | save --force ($autoloadPath | path join atuin.nu)
^carapace _carapace nushell | save --force ($autoloadPath | path join carapace.nu)
^mise activate nu | save ($autoloadPath | path join mise.nu) --force
^starship init nu | save ($autoloadPath | path join starship.nu) --force
^zoxide init nushell | save ($autoloadPath | path join zodixe.nu) --force
