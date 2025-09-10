Add-WindowsCapability -Online -Name OpenSSH.Server


# ssh config file initialization
Start-Service sshd
sleep 5
Stop-Service sshd


New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Configuration du fichier sshd_config : on n'autorise que l'authentification par clé
$sshdConfig = "C:\ProgramData\ssh\sshd_config"
# Sauvegarde du fichier original
if (-Not (Test-Path "$sshdConfig.bak")) {
    Copy-Item $sshdConfig "$sshdConfig.bak"
}

$config = Get-Content $sshdConfig

function Set-ConfigLine($key, $value) {
    $pattern = "^\s*#?\s*$key\s+.*$"
    if ($config -match $pattern) {
        $script:config = $config -replace $pattern, "$key $value"
    } else {
        $script:config += "$key $value"
    }
}

Set-ConfigLine "PasswordAuthentication" "no"
Set-ConfigLine "ChallengeResponseAuthentication" "no"
Set-ConfigLine "PubkeyAuthentication" "yes"
Set-ConfigLine "AuthorizedKeysFile" ".ssh/authorized_keys"

$config | Set-Content -Encoding utf8 $sshdConfig

$userProfile = $env:USERPROFILE
$userSshDir = Join-Path $userProfile ".ssh"

if (-Not (Test-Path $userSshDir)) {
    New-Item -ItemType Directory -Path $userSshDir | Out-Null
    Copy-Item "./ssh/public_keys" "$userSshDir/authorized_keys"
}

$sshComputerDir = "C:\ProgramData\ssh"

if (-Not (Test-Path "$sshComputerDir\administrators_authorized_keys")) {
    Copy-Item "./ssh/public_keys" "$sshComputerDir\administrators_authorized_keys" -Force
}

Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

Start-Service 'ssh-agent'
Set-Service -Name 'ssh-agent' -StartupType 'Automatic'

