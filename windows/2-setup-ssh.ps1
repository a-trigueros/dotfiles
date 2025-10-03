#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configure OpenSSH Server on Windows with key-based authentication
.DESCRIPTION
    This script installs and configures OpenSSH Server with secure defaults:
    - Disables password authentication
    - Enables public key authentication only
    - Configures keepalive settings
    - Sets up authorized keys for user and administrators
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Constants
$SSHD_CONFIG_PATH = "C:\ProgramData\ssh\sshd_config"
$SSH_COMPUTER_DIR = "C:\ProgramData\ssh"
$PUBLIC_KEYS_SOURCE = "./ssh/public_keys"

function Install-OpenSSHServer {
    <#
    .SYNOPSIS
        Installs OpenSSH Server capability if not already installed
    #>
    Write-Host "Installing OpenSSH Server..." -ForegroundColor Cyan
    
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server -ErrorAction Stop
        Write-Host "✓ OpenSSH Server installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install OpenSSH Server: $_"
        throw
    }
}

function Initialize-SSHDConfigFile {
    <#
    .SYNOPSIS
        Initializes the SSH daemon configuration file by starting and stopping the service
    #>
    Write-Host "Initializing SSH daemon configuration..." -ForegroundColor Cyan
    
    Start-Service sshd -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Stop-Service sshd -ErrorAction SilentlyContinue
    
    Write-Host "✓ SSH daemon configuration initialized" -ForegroundColor Green
}

function Add-SSHFirewallRule {
    <#
    .SYNOPSIS
        Creates a firewall rule to allow SSH connections on port 22
    #>
    Write-Host "Configuring firewall rule for SSH..." -ForegroundColor Cyan
    
    $existingRule = Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "  Firewall rule already exists, skipping..." -ForegroundColor Yellow
        return
    }
    
    New-NetFirewallRule `
        -Name 'sshd' `
        -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22 | Out-Null
    
    Write-Host "✓ Firewall rule configured" -ForegroundColor Green
}

function Backup-SSHDConfig {
    <#
    .SYNOPSIS
        Creates a backup of the original sshd_config file
    #>
    $backupPath = "$SSHD_CONFIG_PATH.bak"
    
    if (-Not (Test-Path $backupPath)) {
        Write-Host "Creating backup of original sshd_config..." -ForegroundColor Cyan
        Copy-Item $SSHD_CONFIG_PATH $backupPath
        Write-Host "✓ Backup created at $backupPath" -ForegroundColor Green
    }
}

function Set-SSHDConfigLine {
    <#
    .SYNOPSIS
        Updates or adds a configuration line in the SSH daemon config
    .PARAMETER Config
        The configuration content array
    .PARAMETER Key
        The configuration key to set
    .PARAMETER Value
        The value to assign to the key
    #>
    param(
        [Parameter(Mandatory)]
        [string[]]$Config,
        
        [Parameter(Mandatory)]
        [string]$Key,
        
        [Parameter(Mandatory)]
        [string]$Value
    )
    
    $pattern = "^\s*#?\s*$Key\s+.*$"
    
    if ($Config -match $pattern) {
        return $Config -replace $pattern, "$Key $Value"
    }
    else {
        return $Config + "$Key $Value"
    }
}

function Set-SSHDSecurityConfiguration {
    <#
    .SYNOPSIS
        Configures SSH daemon with secure authentication settings
    #>
    Write-Host "Configuring SSH daemon security settings..." -ForegroundColor Cyan
    
    Backup-SSHDConfig
    
    $config = Get-Content $SSHD_CONFIG_PATH
    
    # Disable password authentication, enable key-based only
    $config = Set-SSHDConfigLine -Config $config -Key "PasswordAuthentication" -Value "no"
    $config = Set-SSHDConfigLine -Config $config -Key "ChallengeResponseAuthentication" -Value "no"
    $config = Set-SSHDConfigLine -Config $config -Key "PubkeyAuthentication" -Value "yes"
    $config = Set-SSHDConfigLine -Config $config -Key "AuthorizedKeysFile" -Value ".ssh/authorized_keys"
    
    # Configure keepalive to prevent disconnections
    $config = Set-SSHDConfigLine -Config $config -Key "ClientAliveInterval" -Value "60"
    $config = Set-SSHDConfigLine -Config $config -Key "ClientAliveCountMax" -Value "3"
    $config = Set-SSHDConfigLine -Config $config -Key "TCPKeepAlive" -Value "yes"
    
    $config | Set-Content -Encoding UTF8 $SSHD_CONFIG_PATH
    
    Write-Host "✓ SSH daemon security configured" -ForegroundColor Green
}

function Install-UserAuthorizedKeys {
    <#
    .SYNOPSIS
        Installs authorized_keys file in the user's .ssh directory
    #>
    Write-Host "Setting up user authorized keys..." -ForegroundColor Cyan
    
    $userSshDir = Join-Path $env:USERPROFILE ".ssh"
    $authorizedKeysPath = Join-Path $userSshDir "authorized_keys"
    
    if (-Not (Test-Path $userSshDir)) {
        New-Item -ItemType Directory -Path $userSshDir | Out-Null
        Write-Host "  Created directory: $userSshDir" -ForegroundColor Gray
    }
    
    if (-Not (Test-Path $authorizedKeysPath)) {
        if (Test-Path $PUBLIC_KEYS_SOURCE) {
            Copy-Item $PUBLIC_KEYS_SOURCE $authorizedKeysPath
            Write-Host "✓ User authorized keys installed" -ForegroundColor Green
        }
        else {
            Write-Warning "Public keys source file not found: $PUBLIC_KEYS_SOURCE"
        }
    }
    else {
        Write-Host "  Authorized keys already exist, skipping..." -ForegroundColor Yellow
    }
}

function Install-AdministratorAuthorizedKeys {
    <#
    .SYNOPSIS
        Installs authorized_keys file for administrators in the ProgramData directory
    #>
    Write-Host "Setting up administrator authorized keys..." -ForegroundColor Cyan
    
    $adminKeysPath = Join-Path $SSH_COMPUTER_DIR "administrators_authorized_keys"
    
    if (-Not (Test-Path $adminKeysPath)) {
        if (Test-Path $PUBLIC_KEYS_SOURCE) {
            Copy-Item $PUBLIC_KEYS_SOURCE $adminKeysPath -Force
            Write-Host "✓ Administrator authorized keys installed" -ForegroundColor Green
        }
        else {
            Write-Warning "Public keys source file not found: $PUBLIC_KEYS_SOURCE"
        }
    }
    else {
        Write-Host "  Administrator authorized keys already exist, skipping..." -ForegroundColor Yellow
    }
}

function Start-SSHServices {
    <#
    .SYNOPSIS
        Starts SSH daemon and agent services and sets them to automatic startup
    #>
    Write-Host "Starting SSH services..." -ForegroundColor Cyan
    
    # Start and configure SSH daemon
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Write-Host "✓ SSH daemon started and set to automatic" -ForegroundColor Green
    
    # Start and configure SSH agent
    Start-Service 'ssh-agent'
    Set-Service -Name 'ssh-agent' -StartupType 'Automatic'
    Write-Host "✓ SSH agent started and set to automatic" -ForegroundColor Green
}

# Main execution
try {
    Write-Host "`n=== OpenSSH Server Setup ===" -ForegroundColor Magenta
    Write-Host ""
    
    Install-OpenSSHServer
    Initialize-SSHDConfigFile
    Add-SSHFirewallRule
    Set-SSHDSecurityConfiguration
    Install-UserAuthorizedKeys
    Install-AdministratorAuthorizedKeys
    Start-SSHServices
    
    Write-Host ""
    Write-Host "=== Setup completed successfully! ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "SSH Server is now running and configured with:" -ForegroundColor Green
    Write-Host "  • Key-based authentication only" -ForegroundColor Gray
    Write-Host "  • Password authentication disabled" -ForegroundColor Gray
    Write-Host "  • Keepalive configured (60s interval)" -ForegroundColor Gray
    Write-Host "  • Firewall rule enabled on port 22" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Error "Setup failed: $_"
    exit 1
}

