# Script de configuration machine

Write-Host "=== Configuration de la machine ===`n"

### 1. Changement du nom de la machine
$newName = Read-Host "Entrez le nom que vous souhaitez donner à cette machine"
if (![string]::IsNullOrWhiteSpace($newName)) {
    try {
        Rename-Computer -NewName $newName -Force
        Write-Host "Nom de machine défini sur : $newName (redémarrage nécessaire pour appliquer)"
    } catch {
        Write-Warning "Impossible de renommer la machine : $_"
    }
}

### 2. Authentification au démarrage (auto-login)
$autoLoginChoice = Read-Host "Souhaitez-vous activer la connexion automatique (O/N) ?"
if ($autoLoginChoice -match '^[Oo]$') {
    $username = $env:USERNAME
    $password = Read-Host "Entrez le mot de passe de l'utilisateur $username" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    # Écrit dans la base de registre pour activer l'auto-login
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "1" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d $username /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t REG_SZ /d $plainPassword /f

    Write-Host "Connexion automatique activée pour l'utilisateur $username"
} else {
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "0" /f
    Write-Host "Connexion automatique désactivée"
}

### 3. Désactivation de l’autolock
$lockChoice = Read-Host "Souhaitez-vous désactiver le verrouillage automatique (O/N) ?"
if ($lockChoice -match '^[Oo]$') {
    try {
        # Désactive l’écran de veille et le lock
        powercfg /change monitor-timeout-ac 0
        powercfg /change monitor-timeout-dc 0
        powercfg /change standby-timeout-ac 0
        powercfg /change standby-timeout-dc 0
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t REG_SZ /d "1" /f
        Write-Host "Verrouillage automatique désactivé"
    } catch {
        Write-Warning "Impossible de désactiver l’autolock : $_"
    }
} else {
    Write-Host "Aucune modification apportée à l’autolock"
}

Write-Host "`n=== Configuration terminée. ==="
Read-Host "Appuyez sur une touche pour redémarrer."
Restart-Computer -Force