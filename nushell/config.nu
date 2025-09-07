# config.nu
#
# Installed by:
# version = "0.107.0"
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

($env.PATH = $env.PATH 
    | append "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    | append "/opt/homebrew/bin"
    | append ($env.HOME + "/.rustup/toolchains/stable-aarch64-apple-darwin/bin")
    | append ($env.HOME + "/.config/npm-packages/bin")
    | append "/opt/homebrew/opt/openjdk/bin"
    | append "/usr/local/share/dotnet"
    | append ($env.HOME + "/.dotnet/tools")
    | append "/opt/tcr"
    | append ($env.HOME + "/.cache/lm-studio/bin")
    | append ($env.HOME + "/tools/flutter/bin"))