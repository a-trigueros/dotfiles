# PowerShell Profile
# Equivalent to .zshrc configuration

function Initialize-PSReadLine
{
  if (-not (Get-Module -ListAvailable -Name PSReadLine))
  {
    Write-Host "PSReadLine not found. Installing..." -ForegroundColor Yellow
    try
    {
      Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -Repository PSGallery
      Write-Host "✓ PSReadLine installed successfully" -ForegroundColor Green
    } catch
    {
      Write-Warning "Failed to install PSReadLine: $_"
      Write-Warning "Some features may not work. Install manually with: Install-Module PSReadLine -Scope CurrentUser -Force"
      return
    }
  }

  Import-Module PSReadLine -ErrorAction SilentlyContinue

  if (Get-Module -Name PSReadLine)
  {
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 10000
  } else
  {
    Write-Warning "PSReadLine not available. Vi mode and advanced editing features disabled."
  }
}

function Set-EnvironmentVariables
{
  $env:EDITOR = "nvim"
  $env:VISUAL = "nvim"
  
  # Visual styling
  $PSStyle.FileInfo.Directory = "`e[34;1m"
}

function Initialize-NodeEnvironment
{
  if (Test-Path "$env:NVM_HOME\nvm.exe")
  {
    Write-Verbose "NVM detected at $env:NVM_HOME"
    & "$env:NVM_HOME\nvm.exe" use lts | Out-Null
  }
}

function Initialize-Starship
{
  if (Get-Command starship -ErrorAction SilentlyContinue)
  {
    $ENV:STARSHIP_CONFIG = Join-Path $HOME ".config" "starship" "starship-powershell.toml"
    
    $null = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $null = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
    
    Invoke-Expression (&starship init powershell)
  } 
}

function Initialize-Carapace
{
  if (Get-Command carapace -ErrorAction SilentlyContinue)
  {
    if (Get-Module -Name PSReadLine)
    {
      Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
      Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    }
    carapace _carapace | Out-String | Invoke-Expression
  } 
}

function Initialize-Atuin
{
  if (Get-Command atuin -ErrorAction SilentlyContinue)
  {
    atuin init powershell | Out-String | Invoke-Expression
  } 
}

function Initialize-Zoxide
{
  if (Get-Command zoxide -ErrorAction SilentlyContinue)
  {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })

    Set-Alias -Name cd -Value z -Option AllScope -Scope Global -Force
  }
}

function Initialize-Bat
{
  if (Get-Command bat -ErrorAction SilentlyContinue)
  {
    $batThemes = bat --list-themes 2>$null | Out-String
    if ($batThemes -match "Catppuccin Macchiato")
    {
      $env:BAT_THEME = "Catppuccin Macchiato"
    }    

    $env:BAT_STYLE = "numbers,changes,header,grid"
    $env:BAT_PAGER = "less -RF"
    $env:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
    $env:MANROFFOPT = "-c"
  }
}

function Initialize-Fzf
{
  if (Get-Command fzf -ErrorAction SilentlyContinue)
  {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
    
    if (Get-Module -Name PSReadLine)
    {
      Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
        $file = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | 
          Select-Object -ExpandProperty FullName | 
          fzf --preview 'type {}'
            
        if ($file)
        {
          [Microsoft.PowerShell.PSConsoleReadLine]::Insert($file)
        }
      }
        
      if (-not (Get-Command atuin -ErrorAction SilentlyContinue))
      {
        Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
          $history = Get-Content (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue
          $selection = $history | Select-Object -Unique | fzf --tac --no-sort
                
          if ($selection)
          {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
          }
        }
      }
    }
  }
}

function Register-CommandCompletions
{
  # dotnet CLI completion
  if (Get-Command dotnet -ErrorAction SilentlyContinue)
  {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
      param($commandName, $wordToComplete, $cursorPosition)
      dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
    }
  }

  # winget completion
  if (Get-Command winget -ErrorAction SilentlyContinue)
  {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
      param($commandName, $wordToComplete, $cursorPosition)
      [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
      $Local:word = $wordToComplete.Replace('"', '""')
      $Local:ast = $null
      [System.Management.Automation.Language.Parser]::ParseInput($commandLine, [ref]$ast, [ref]$null) | Out-Null
      $Local:cursor = $ast.Extent.Text.Length
      winget complete --word="$Local:word" --commandline "$commandLine" --position $Local:cursor | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
    }
  }
}

function Set-FileExplorerAliases
{
  # Yazi file manager integration
  function y
  {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
    {
      Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
  }

  # Enhanced ls with eza/exa
  if (Get-Command eza -ErrorAction SilentlyContinue)
  {
    function ls
    { eza --icons --group-directories-first $args 
    }
    function ll
    { eza --icons --group-directories-first -l $args 
    }
    function la
    { eza --icons --group-directories-first -la $args 
    }
    function lt
    { eza --icons --group-directories-first --tree $args 
    }
  } 
}

function Set-NavigationShortcuts
{
  function ..
  { Set-Location .. 
  }
  function ...
  { Set-Location ..\.. 
  }
  function ....
  { Set-Location ..\..\.. 
  }
  function ~
  { Set-Location $HOME 
  }
}

function Set-ProfileManagement
{
  function Edit-Profile
  { nvim $PROFILE 
  }
  Set-Alias -Name ep -Value Edit-Profile -Force

  function Reload-Profile
  { 
    . $PROFILE
    Write-Host "Profile reloaded!" -ForegroundColor Green
  }
  Set-Alias -Name rp -Value Reload-Profile -Force
}

function Set-SystemUtilities
{
  function sysinfo
  {
    Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsArchitecture
  }

  function which($command)
  {
    Get-Command -Name $command -ErrorAction SilentlyContinue | 
      Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
  }

  function touch($file)
  {
    if (Test-Path $file)
    {
      (Get-Item $file).LastWriteTime = Get-Date
    } else
    {
      New-Item -ItemType File -Path $file | Out-Null
    }
  }

  function explorer
  { Start-Process explorer . 
  }
  Set-Alias -Name open -Value explorer
}

function Set-DevelopmentUtilities
{
  function mkcd($path)
  {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Location $path
  }

  function Extract-Archive
  {
    param([string]$Path)
    
    $extension = [System.IO.Path]::GetExtension($Path)
    
    switch ($extension)
    {
      '.zip'
      { Expand-Archive -Path $Path -DestinationPath (Get-Location) 
      }
      '.tar'
      { tar -xf $Path 
      }
      '.gz'
      { tar -xzf $Path 
      }
      '.tgz'
      { tar -xzf $Path 
      }
      '.bz2'
      { tar -xjf $Path 
      }
      default
      { Write-Error "Unsupported archive format: $extension" 
      }
    }
  }
  Set-Alias -Name extract -Value Extract-Archive
}

# ============================================================================
# Main Initialization
# ============================================================================

function Initialize-Profile
{
  # Core modules
  Initialize-PSReadLine
  
  # Environment setup
  Set-EnvironmentVariables
  Initialize-NodeEnvironment
  
  # Shell integrations
  Initialize-Starship
  Initialize-Carapace
  Initialize-Atuin
  Initialize-Zoxide
  Initialize-Bat
  Initialize-Fzf
  Register-CommandCompletions
  
  # Aliases and functions
  Set-FileExplorerAliases
  Set-NavigationShortcuts
  Set-ProfileManagement
  Set-SystemUtilities
  Set-DevelopmentUtilities
  
  # Welcome message
  if ($Host.UI.RawUI.WindowSize.Width -gt 80)
  {
    Write-Host ""
    Write-Host "  PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
    Write-Host "  Type 'ep' to edit profile, 'rp' to reload" -ForegroundColor Gray
    Write-Host ""
  }
  
  # Load local overrides
  $localProfile = Join-Path $PSScriptRoot "profile.local.ps1"
  if (Test-Path $localProfile)
  {
    . $localProfile
  }
}

# Run initialization
Initialize-Profile
