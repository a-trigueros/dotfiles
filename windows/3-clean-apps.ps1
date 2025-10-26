#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Remove default Windows apps and bloatware
.DESCRIPTION
    This script removes unwanted default Windows applications and
    uninstalls Microsoft Teams and OneDrive.
#>

$ErrorActionPreference = "Continue"

function Remove-AppxPackages {
    Write-Host "`n=== Removing Default Windows Apps ===" -ForegroundColor Cyan
    
    $toCleanFilter = @(
        'Microsoft.Paint',
        'Microsoft.Xbox.',
        'Microsoft.XboxGaming',
        'Microsoft.XboxIdentityProvider',
        'Microsoft.XboxSpeechToTextOverlay',
        'Microsoft.ZuneMusic',
        'Microsoft.WindowsAlarms',
        'Microsoft.Todos',
        'Microsoft.YourPhone',
        'Microsoft.WindowsSoundRecorder',
        'Microsoft.WindowsCamera',
        'Microsoft.WindowsCalculator',
        'Microsoft.Windows.Photos',
        'Microsoft.MicrosoftStickyNotes',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.MicrosoftOfficeHub',
        'Microsoft.Bing',
        'Clipchamp.Clipchamp',
        'Microsoft.OutlookForWindows',
        'Microsoft.WindowsNotepad',
        'Microsoft.ScreenSketch',
        'Microsoft.Edge.GameAssist',
        'Microsoft.Copilot'
    )
    
    Write-Host "Searching for unwanted AppX packages..." -ForegroundColor Yellow
    
    $removedCount = 0
    $failedCount = 0
    
    Get-AppxPackage | Where-Object {
        $package = $_
        $toCleanFilter | ForEach-Object {
            $package.PackageFullName.StartsWith($_)
        } | Where-Object { $_ }
    } | ForEach-Object {
        try {
            Write-Host "  Removing: $($_.Name)" -ForegroundColor Gray
            Remove-AppxPackage -Package $_.PackageFullName -ErrorAction Stop
            $removedCount++
        }
        catch {
            Write-Warning "  Failed to remove $($_.Name): $_"
            $failedCount++
        }
    }
    
    Write-Host "Removed $removedCount packages" -ForegroundColor Green
    if ($failedCount -gt 0) {
        Write-Host "✗ Failed to remove $failedCount packages" -ForegroundColor Red
    }
}

function Uninstall-MicrosoftTeams {
    Write-Host "=== Removing Microsoft Teams ===" -ForegroundColor Cyan
    
    try {
        # Try WinGet first
        $teamsInstalled = winget list --id Microsoft.Teams --exact 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Uninstalling Microsoft Teams via WinGet..." -ForegroundColor Yellow
            winget uninstall --id Microsoft.Teams --silent --accept-source-agreements
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Microsoft Teams uninstalled" -ForegroundColor Green
            }
            else {
                Write-Warning "Failed to uninstall Teams via WinGet"
            }
        }
        else {
            Write-Host "Microsoft Teams not found (already removed or not installed)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Warning "Error checking for Microsoft Teams: $_"
    }
}

function Uninstall-OneDrive {
    Write-Host "`n=== Removing OneDrive ===" -ForegroundColor Cyan
    
    try {
        # Try WinGet first
        $oneDriveInstalled = winget list --id Microsoft.OneDrive --exact 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Uninstalling OneDrive via WinGet..." -ForegroundColor Yellow
            winget uninstall --id Microsoft.OneDrive --silent --accept-source-agreements
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "OneDrive uninstalled" -ForegroundColor Green
            }
            else {
                Write-Warning "Failed to uninstall OneDrive via WinGet"
            }
        }
        else {
            Write-Host "OneDrive not found (already removed or not installed)" -ForegroundColor Gray
        }
        
        # Clean up OneDrive remnants
        $oneDrivePath = "$env:USERPROFILE\OneDrive"
        if (Test-Path $oneDrivePath) {
            Write-Host "Cleaning up OneDrive folder..." -ForegroundColor Yellow
            Remove-Item -Path $oneDrivePath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "Error checking for OneDrive: $_"
    }
}

function Show-CleanupSummary {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Cleanup completed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "The following have been removed:" -ForegroundColor Yellow
    Write-Host "  - Default Windows apps (Xbox, Paint, etc.)" -ForegroundColor Gray
    Write-Host "  - Microsoft Teams" -ForegroundColor Gray
    Write-Host "  - OneDrive" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
try {
    Write-Host "`n=== Windows Cleanup Script ===" -ForegroundColor Magenta
    Write-Host ""
    
    Remove-AppxPackages
    Uninstall-MicrosoftTeams
    Uninstall-OneDrive
    Show-CleanupSummary
    
    Write-Host "Cleanup completed successfully!" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Error "Cleanup failed: $_"
    exit 1
}


