$env:path += ";$env:LOCALAPPDATA\mise\shims"

$env:CARAPACE_BRIDGES = 'pwsh,zsh,fish,bash,inshellisense' # optional
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression
starship init powershell | Out-String | Invoke-Expression
zoxide init powershell | Out-String | Invoke-Expression

atuin init powershell | Out-String | Invoke-Expression
