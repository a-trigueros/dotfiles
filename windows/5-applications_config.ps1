$DOTFILES = Split-Path -Parent (Get-Location).Path

function Symlink-Dir {
    param(
      [string]$Source,
      [string]$Target
    )

    if (Test-Path $Target) 
    {
      Remove-Item $Target -Recurse -Force 
    }

    $parent = Split-Path -Parent $Target
    if (-not (Test-Path $parent)) 
    {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null 
    }
    cmd /c mklink /D $Target $Source | Out-Null
}

function Symlink-File {
  param(
    [string]$Source,
    [string]$Target
  )
  if (Test-Path $Target) 
  { 
    Remove-Item $Target -Force 
  }
  New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
}

$linkToFolders = @{
  "atuin" = Join-Path $HOME ".config\atuin"
  "carapace" = Join-Path $HOME ".config\carapace"
  "jj"       = Join-Path $HOME ".config\jj"
  "wezterm"  = Join-Path $HOME ".config\wezterm"
  "nvim"     = Join-Path $HOME "AppData\Local\nvim"
  "nushell\config" = Join-Path $HOME "AppData\Roaming\nushell"
}

foreach ($tool in $linkToFolders.Keys)
{
  $src = Join-Path $DOTFILES $tool
  $dst = $linkToFolders[$tool]

  Symlink-Dir -Source $src -Target $dst
}

$linkToFiles = @{
  "git"       = $HOME
  "starship"  = Join-Path $HOME ".config"
}

foreach($tool in $linkToFiles.Keys)
{
  $srcFolder = Join-Path $DOTFILES $tool

  Get-ChildItem -Path $srcFolder -File | ForEach-Object {
        $file = $_.FullName
        $dst = Join-Path $linkToFiles[$tool] $_.Name
        Symlink-File -Source $file -Target $dst
    }
}

Write-Host "Tous les symlinks ont été créés avec succès !"
