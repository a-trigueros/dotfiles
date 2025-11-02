$ErrorActionPreference = "Stop"

$dotfilesPath = Join-Path $PSScriptRoot ".."

function Copy-ConfigDirectory
{
  param(
    [string]$source,
    [string]$target
  )
    
  if (-not (Test-Path $source))
  {
    Write-Warning "Source directory not found: $source"
    return $false
  }
    
  $parentDir = Split-Path -Parent $target
  if (-not (Test-Path $parentDir))
  {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
  }
    
  if (Test-Path $target)
  {
    Write-Host "  Removing existing directory: $target" -ForegroundColor Yellow
    Remove-Item $target -Recurse -Force
  }
    
  Write-Host "  Copying: $source -> $target" -ForegroundColor Green
  Copy-Item -Path $source -Destination $target -Recurse -Force
    
  return $true
}

function Copy-ConfigFile
{
  param(
    [string]$source,
    [string]$target
  )
    
  if (-not (Test-Path $source))
  {
    Write-Warning "Source file not found: $source"
    return $false
  }
    
  $parentDir = Split-Path -Parent $target
  if (-not (Test-Path $parentDir))
  {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
  }
    
  if (Test-Path $target)
  {
    Write-Host "  Overwriting: $target" -ForegroundColor Yellow
  } else
  {
    Write-Host "  Copying: $source -> $target" -ForegroundColor Green
  }
    
  Copy-Item -Path $source -Destination $target -Force
    
  return $true
}

function Adapt-GitConfigForWindows
{
  param([string]$gitConfigPath)
    
  if (-not (Test-Path $gitConfigPath))
  {
    Write-Warning "Git config not found at: $gitConfigPath"
    return $false
  }
    
  Write-Host "  Adapting .gitconfig for Windows (remote development)..." -ForegroundColor Cyan
    
  $content = Get-Content $gitConfigPath -Raw
    
  # Change autocrlf from input to true for Windows
  $content = $content -replace '(?m)^\s*autocrlf\s*=\s*input\s*$', "`tautocrlf = true"
    
  # Disable GPG signing (remove or comment out gpg sections)
  $content = $content -replace '(?ms)^\[gpg\].*?(?=\n\[|\z)', ''
  $content = $content -replace '(?ms)^\[gpg\s+"[^"]+"\].*?(?=\n\[|\z)', ''
  $content = $content -replace '(?m)^\s*gpgsign\s*=\s*true\s*$', "`tgpgsign = false"
    
  # Add credential helper for Windows if not present
  if ($content -notmatch '\[credential\]')
  {
    $content += "`n[credential]`n`thelper = manager-core`n"
  }
    
  # Clean up extra blank lines
  $content = $content -replace '(?m)^\s*\n\s*\n\s*\n', "`n`n"
    
  Set-Content -Path $gitConfigPath -Value $content -NoNewline
    
  Write-Host "    Disabled GPG signing (for remote development)" -ForegroundColor Gray
  Write-Host "    Set autocrlf = true (Windows line endings)" -ForegroundColor Gray
  Write-Host "    Configured credential helper" -ForegroundColor Gray
    
  return $true
}


$directoriesToCopy = @(
  @{ Source = "atuin"; Target = Join-Path $HOME ".config\atuin" }
  @{ Source = "jj"; Target = Join-Path $HOME "AppData\Roaming\jj" }
  @{ Source = "wezterm"; Target = Join-Path $HOME ".config\wezterm" }
  @{ Source = "nvim\\LazyVim"; Target = Join-Path $HOME "AppData\Local\nvim" }
  @{ Source = "nushell\config"; Target = Join-Path $HOME "AppData\Roaming\nushell" }
  @{ Source = "bat\themes"; Target = Join-Path $env:APPDATA "bat\themes" }
  @{ Source = "starship"; Target = Join-Path $HOME ".config\starship" }
  @{ Source = "windows\\config\\starship"; Target = Join-Path $HOME ".config\starship-pwsh" }
  @{ Source = "windows\\config\\powershell"; Target = Join-Path $HOME "Documents\PowerShell" }
  # @{ Source = "windows\\config\\powershell"; Target = Join-Path $HOME "Documents\WindowsPowerShell" }
)

Write-Host "`nCopying configuration directories..." -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($item in $directoriesToCopy)
{
  $source = Join-Path $dotfilesPath $item.Source
  $target = $item.Target
    
  Write-Host "`nProcessing: $($item.Source)" -ForegroundColor Cyan
    
  if (Copy-ConfigDirectory -source $source -target $target)
  {
    $successCount++
  } else
  {
    $failCount++
  }
}

$filesToCopy = @{
  "git" = $HOME
}

Write-Host "`n`nCopying configuration files..." -ForegroundColor Cyan

foreach ($tool in $filesToCopy.Keys)
{
  $sourceFolder = Join-Path $dotfilesPath $tool
    
  if (-not (Test-Path $sourceFolder))
  {
    Write-Warning "Source folder not found: $sourceFolder"
    continue
  }
    
  Write-Host "`nProcessing files from: $tool" -ForegroundColor Cyan
    
  Get-ChildItem -Path $sourceFolder -File | ForEach-Object {
    $sourceFile = $_.FullName
    $targetFile = Join-Path $filesToCopy[$tool] $_.Name
        
    if (Copy-ConfigFile -source $sourceFile -target $targetFile)
    {
      $successCount++
            
      # Special handling for .gitconfig on Windows
      if ($_.Name -eq ".gitconfig")
      {
        Adapt-GitConfigForWindows -gitConfigPath $targetFile
      }
    } else
    {
      $failCount++
    }
  }
}

# Rebuild bat cache
bat cache --build | Out-Null

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Configuration copy completed!" -ForegroundColor Green
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0)
  { "Red" 
  } else
  { "Green" 
  })
Write-Host "========================================" -ForegroundColor Cyan

if ($failCount -gt 0)
{
  exit 1
}

exit 0
