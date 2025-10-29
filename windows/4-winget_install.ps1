$ErrorActionPreference = "Stop"

function Get-PackageFiles {
    $packagesPath = Join-Path $PSScriptRoot "packages"
    
    if (-not (Test-Path $packagesPath)) {
        throw "Packages folder not found at: $packagesPath"
    }
    
    return Get-ChildItem -Path $packagesPath -Filter "*.winget" | Sort-Object Name
}

function Show-PackageMenu {
    param([array]$packages)
    
    Write-Host "`nAvailable packages:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $packages.Count; $i++) {
        Write-Host "  [$($i + 1)] $($packages[$i].BaseName)" -ForegroundColor Yellow
    }
    Write-Host "  [A] All packages" -ForegroundColor Green
    Write-Host "  [Q] Quit" -ForegroundColor Red
}

function Get-UserSelection {
    param([array]$packages)
    
    Show-PackageMenu -packages $packages
    
    $selection = Read-Host "`nYour choice (enter numbers separated by commas, A for all, Q to quit)"
    
    if ($selection -eq 'Q' -or $selection -eq 'q') {
        return $null
    }
    
    if ($selection -eq 'A' -or $selection -eq 'a') {
        return $packages
    }
    
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() }
    $selectedPackages = @()
    
    foreach ($index in $indices) {
        if ($index -match '^\d+$') {
            $idx = [int]$index - 1
            if ($idx -ge 0 -and $idx -lt $packages.Count) {
                $selectedPackages += $packages[$idx]
            }
        }
    }
    
    if ($selectedPackages.Count -eq 0) {
        Write-Host "`nNo valid packages selected. Please enter valid numbers." -ForegroundColor Red
    }
    
    return $selectedPackages
}

function Enable-WingetConfigure {
    Write-Host "`nEnabling winget configure feature..." -ForegroundColor Cyan
    
    try {
        winget configure --enable
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Winget configure enable returned exit code: $LASTEXITCODE"
        }
    }
    catch {
        Write-Warning "Failed to enable winget configure: $_"
        Write-Host "Continuing anyway, the feature might already be enabled." -ForegroundColor Yellow
    }
}

function Install-WingetPackages {
    param([array]$packageFiles)
    
    Enable-WingetConfigure
    
    $failedPackages = @()
    
    foreach ($file in $packageFiles) {
        Write-Host "`nConfiguring packages from: $($file.Name)" -ForegroundColor Green
        
        try {
            winget configure -f $file.FullName --accept-configuration-agreements --disable-interactivity --suppress-initial-details
            
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Configuration failed for $($file.Name) with exit code: $LASTEXITCODE"
                $failedPackages += $file.Name
            }
        }
        catch {
            Write-Error "Error configuring packages from $($file.Name): $_"
            $failedPackages += $file.Name
        }

        if($file.Name -eq "compilers.winget") {
           $InstallerDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer"
            $VsInstaller = Join-Path $InstallerDir "vs_installer.exe"

            & $VsInstaller modify --installPath "$InstallPath" --quiet --wait --norestart --importConfig "./BuildTools/.vsconfig"
        }
    }
    
    if ($failedPackages.Count -gt 0) {
        Write-Host "`nFailed package configurations:" -ForegroundColor Red
        foreach ($failed in $failedPackages) {
            Write-Host "  - $failed" -ForegroundColor Red
        }
        return $false
    }
    
    return $true
}

$packageFiles = Get-PackageFiles

if ($packageFiles.Count -eq 0) {
    Write-Host "No package files found in 'packages' folder" -ForegroundColor Red
    exit 1
}

$selectedPackages = Get-UserSelection -packages $packageFiles

if ($null -eq $selectedPackages -or $selectedPackages.Count -eq 0) {
    Write-Host "`nNo packages selected. Exiting." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nSelected packages:" -ForegroundColor Cyan
foreach ($pkg in $selectedPackages) {
    Write-Host "  - $($pkg.BaseName)" -ForegroundColor White
}

$success = Install-WingetPackages -packageFiles $selectedPackages

if ($success) {
    Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`nInstallation completed with errors." -ForegroundColor Yellow
    exit 1
}  