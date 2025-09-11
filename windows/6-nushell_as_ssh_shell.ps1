$NuPath = (Get-Command nu).Path
$User = $env:USERNAME
$SshdConfig = "C:\ProgramData\ssh\sshd_config"

if (-Not (Test-Path $NuPath)) {
    Write-Error "NuShell introuvable à $NuPath"
    exit 1
}

if (-Not (Test-Path $SshdConfig)) {
    Write-Error "Fichier sshd_config introuvable à $SshdConfig"
    exit 1
}

$ConfigBlock = @"
Match User $User
    ForceCommand "$NuPath"
"@

Copy-Item $SshdConfig "$SshdConfig.bak" -Force

if (-Not (Select-String -Path $SshdConfig -Pattern "Match User $User")) {
    Add-Content -Path $SshdConfig -Value "`n$ConfigBlock`n"
    Write-Output "Bloc ajouté pour l'utilisateur $User"
} else {
    Write-Output "Bloc déjà présent pour l'utilisateur $User"
}

Write-Output "Configuration SSH terminée. Veuillez redémarrer le service sshd pour appliquer les changements."

