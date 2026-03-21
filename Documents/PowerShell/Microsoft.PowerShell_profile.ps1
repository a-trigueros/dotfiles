$env:path += ";$env:LOCALAPPDATA\mise\shims"

$script:AutoloadDirectory = Join-Path (Split-Path -Parent $PROFILE) "autoload"

$env:CARAPACE_BRIDGES = 'pwsh,zsh,fish,bash,inshellisense' # optional
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

Get-ChildItem -Path $script:AutoloadDirectory -Filter "*.ps1" -File -ErrorAction SilentlyContinue |
    Sort-Object Name |
    ForEach-Object {
        . $_.FullName
    }
