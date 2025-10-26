function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-ElevatedProcess {
    if (-NOT (Test-Administrator)) {
        Write-Host "This script requires administrator privileges. Attempting to restart with elevation..." -ForegroundColor Yellow
        
        try {
            $scriptPath = $MyInvocation.ScriptName
            if ([string]::IsNullOrEmpty($scriptPath)) {
                $scriptPath = $PSCommandPath
            }
            
            Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
            exit
        } catch {
            Write-Error "Failed to restart with administrator privileges: $_"
            Write-Host "Please run this script as Administrator manually." -ForegroundColor Red
            Read-Host "Press any key to exit"
            exit 1
        }
    }
}

function Set-ComputerName {
    Write-Host "=== Machine Configuration ===`n"
    
    $newName = Read-Host "Enter the name you want to give to this machine"
    if (![string]::IsNullOrWhiteSpace($newName)) {
        try {
            Rename-Computer -NewName $newName -Force
            Write-Host "Machine name set to: $newName (restart required to apply changes)"
        } catch {
            Write-Warning "Unable to rename the machine: $_"
        }
    }
}

function Set-AutoLoginRegistryKeys {
    param(
        [string]$Username = "",
        [string]$Password = "",
        [bool]$Enable
    )
    
    if ($Enable) {
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "1" /f
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d $Username /f
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t REG_SZ /d $Password /f
    } else {
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "0" /f
    }
}

function Set-AutoLogin {
    $autoLoginChoice = Read-Host "Do you want to enable automatic login (Y/N)?"
    if ($autoLoginChoice -match '^[Yy]$') {
        $username = $env:USERNAME
        $password = Read-Host "Enter the password for user $username" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

        Set-AutoLoginRegistryKeys -Username $username -Password $plainPassword -Enable $true
        Write-Host "Automatic login enabled for user $username"
    } else {
        Set-AutoLoginRegistryKeys -Enable $false
        Write-Host "Automatic login disabled"
    }
}

function Set-PowerConfigurationSettings {
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
}

function Set-LockScreenRegistryKey {
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t REG_SZ /d "1" /f
}

function Disable-AutoLock {
    $lockChoice = Read-Host "Do you want to disable automatic screen lock (Y/N)?"
    if ($lockChoice -match '^[Yy]$') {
        try {
            Set-PowerConfigurationSettings
            Set-LockScreenRegistryKey
            Write-Host "Automatic screen lock disabled"
        } catch {
            Write-Warning "Unable to disable auto-lock: $_"
        }
    } else {
        Write-Host "No changes made to auto-lock settings"
    }
}

function Enable-WindowsSudo {
    Write-Host "`nConfiguring Windows Sudo..." -ForegroundColor Cyan
    try {
        $winVersion = [System.Environment]::OSVersion.Version
        if ($winVersion.Build -lt 26045) {
            Write-Host "Windows 11 Build 26045+ required for sudo" -ForegroundColor Yellow
            Write-Host "Current build: $($winVersion.Build). Skipping sudo configuration." -ForegroundColor Gray
            return
        }

        # Ensure current user is in Administrators (required to run sudo)
        $currentUser = "$env:USERDOMAIN\$env:USERNAME"
        $adminsGroup = "Administrators"
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        $inAdmins = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $inAdmins) {
            Write-Host "Adding $currentUser to local Administrators group..." -ForegroundColor Yellow
            $addResult = & net localgroup $adminsGroup "$currentUser" /add 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to add user to Administrators: $addResult"
            }
            Write-Host "User added to Administrators. You must sign out and sign in again for changes to take effect." -ForegroundColor Green
        } else {
            Write-Host "User is already in Administrators group." -ForegroundColor Gray
        }

        $sudoPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo"
        if (-not (Test-Path $sudoPath)) {
            New-Item -Path $sudoPath -Force | Out-Null
            Write-Host "Created sudo registry key" -ForegroundColor Gray
        }

        # Enable sudo and set mode
        New-ItemProperty -Path $sudoPath -Name "Enabled" -Value 1 -PropertyType DWord -Force | Out-Null
        # Mode: 0 = inline, 1 = new window, 2 = disable input
        New-ItemProperty -Path $sudoPath -Name "Mode" -Value 0 -PropertyType DWord -Force | Out-Null
        # Optional: Require UAC prompt for elevation (0 = no, 1 = yes). Keep default behavior: 1
        New-ItemProperty -Path $sudoPath -Name "RequireUAC" -Value 1 -PropertyType DWord -Force | Out-Null

        Write-Host "Sudo enabled and configured (inline mode)." -ForegroundColor Green
        Write-Host "If you were just added to Administrators, sign out/in or reboot before using 'sudo'." -ForegroundColor Yellow
    } catch {
        Write-Warning "Failed to configure sudo: $_"
        Write-Host "You can configure it manually later with: .\windows\8-enable-sudo.ps1" -ForegroundColor Gray
    }
}

function Start-MachineConfiguration {
    # Check for administrator privileges and elevate if necessary
    Start-ElevatedProcess
    
    Write-Host "Running with administrator privileges..." -ForegroundColor Green
    
    Set-ComputerName
    Set-AutoLogin
    Disable-AutoLock
    Enable-WindowsSudo
    
    Write-Host "`n=== Configuration completed. ==="
    Read-Host "Press any key to restart the computer."
    Restart-Computer -Force
}

Start-MachineConfiguration
