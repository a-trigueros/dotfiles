$ErrorActionPreference = "Stop"

function Get-PwshPath {
    try {
        $pwshPath = (Get-Command pwsh -ErrorAction Stop).Path
        return $pwshPath
    }
    catch {
        Write-Error "PowerShell Core (pwsh) not found. Please install it first: https://github.com/PowerShell/PowerShell"
        exit 1
    }
}

function Backup-SshdConfig {
    param([string]$configPath)
    
    $backupPath = "$configPath.bak"
    Copy-Item $configPath $backupPath -Force
    Write-Host "Backup created at: $backupPath" -ForegroundColor Green
}

function Test-ConfigurationExists {
    param(
        [string]$configPath,
        [string]$username
    )
    
    return (Select-String -Path $configPath -Pattern "Match User $username" -Quiet)
}

function Add-PwshConfiguration {
    param(
        [string]$configPath,
        [string]$username,
        [string]$pwshPath
    )
    
    $configBlock = @"
Match User $username
    ForceCommand $pwshPath -NoLogo
"@
    
    Add-Content -Path $configPath -Value "`n$configBlock`n"
    Write-Host "Configuration added for user: $username" -ForegroundColor Green
}

function Restart-SshdService {
    Write-Host "`nRestarting sshd service..." -ForegroundColor Cyan
    
    try {
        Restart-Service sshd -Force
        Write-Host "Service restarted successfully!" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to restart sshd service: $_"
        Write-Host "Please restart the service manually: Restart-Service sshd" -ForegroundColor Yellow
    }
}

$pwshPath = Get-PwshPath
$user = $env:USERNAME
$sshdConfig = "C:\ProgramData\ssh\sshd_config"

if (-Not (Test-Path $sshdConfig)) {
    Write-Error "sshd_config file not found at: $sshdConfig"
    exit 1
}

Write-Host "PowerShell path: $pwshPath" -ForegroundColor Cyan
Write-Host "User: $user" -ForegroundColor Cyan
Write-Host "Config file: $sshdConfig" -ForegroundColor Cyan

Backup-SshdConfig -configPath $sshdConfig

if (Test-ConfigurationExists -configPath $sshdConfig -username $user) {
    Write-Host "`nConfiguration already exists for user: $user" -ForegroundColor Yellow
    $replace = Read-Host "Do you want to replace it? (Y/N)"
    
    if ($replace -eq 'Y' -or $replace -eq 'y') {
        Write-Host "Please remove the existing configuration manually from $sshdConfig" -ForegroundColor Yellow
        exit 0
    }
    else {
        Write-Host "Configuration unchanged." -ForegroundColor Yellow
        exit 0
    }
}

Add-PwshConfiguration -configPath $sshdConfig -username $user -pwshPath $pwshPath

$restart = Read-Host "`nRestart sshd service now to apply changes? (Y/N)"
if ($restart -eq 'Y' -or $restart -eq 'y') {
    Restart-SshdService
}
else {
    Write-Host "`nConfiguration applied. Please restart the sshd service manually when ready:" -ForegroundColor Yellow
    Write-Host "  Restart-Service sshd" -ForegroundColor Cyan
}

Write-Host "`nConfiguration completed successfully!" -ForegroundColor Green

