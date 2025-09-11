$HOME = [Environment]::GetFolderPath("UserProfile")
$DOTFILES = (Get-Location).Path

git -C $DOTFILES submodule update --init --recursive --depth 1

function New-Symlink
{
  param(
    [string]$Source,
    [string]$Target
  )

  if (Test-Path $Target)
  { Remove-Item $Target -Recurse -Force 
  }
  $parent = Split-Path $Target
  if (-not (Test-Path $parent))
  { New-Item -ItemType Directory -Path $parent -Force | Out-Null 
  }

  New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
  Write-Host "🔗 Symlink créé : $Target → $Source"
}

$folderAndDestinations = @{
  "git"      = Join-Path $HOME ".gitconfig"
  "atuin"    = Join-Path $HOME "AppData\Roaming\atuin"
  "carapace" = Join-Path $HOME "AppData\Roaming\carapace"
  "jj"       = Join-Path $HOME "AppData\Local\jj"
  "nvim"     = Join-Path $HOME "AppData\Local\nvim"
  "wezterm"  = Join-Path $HOME "AppData\Local\wezterm"
}

foreach ($tool in $folderAndDestinations.Keys)
{
  $src = Join-Path $DOTFILES $tool
  $dst = $folderAndDestinations[$tool]
  New-Symlink -Source $src -Target $dst
}

$nushellDir = Join-Path $HOME "AppData\Roaming\nushell"
if (-not (Test-Path $nushellDir)) 
{ 
  New-Item -ItemType Directory -Path $nushellDir -Force | Out-Null 
}

New-Symlink -Source (Join-Path $DOTFILES "nushell\config.nu") -Target (Join-Path $nushellDir "config.nu")

$nushellScriptsDir = Join-Path $HOME ".config\nushell"
if (-not (Test-Path $nushellScriptsDir))
{
  New-Item -ItemType Directory -Path $nushellScriptsDir -Force | Out-Null
}

foreach ($sub in @("nu_scripts","completions"))
{
  $srcSub = Join-Path $DOTFILES "nushell\$sub"
  $dstSub = Join-Path $nushellScriptsDir $sub
  if (Test-Path $dstSub)
  { Remove-Item $dstSub -Recurse -Force 
  }
  New-Symlink -Source $srcSub -Target $dstSub
}

Write-Host "`n✅ Tous les symlinks ont été créés avec succès !"
