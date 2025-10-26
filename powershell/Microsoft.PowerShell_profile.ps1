# PowerShell Profile
# Equivalent to .zshrc configuration

#region Module Dependencies

# Ensure PSReadLine is installed and up to date
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
  }
}

# Import PSReadLine (should be automatic, but ensures it's loaded)
Import-Module PSReadLine -ErrorAction SilentlyContinue

#endregion

#region Basic Configuration

# Set editor
$env:EDITOR = "nvim"

# Jujutsu (jj) configuration
$env:JJ_EDITOR = "nvim"
$env:JJ_CONFIG = Join-Path $HOME ".config" "jj" "config.toml"

# Diff and merge tools for version control
$env:VISUAL = "nvim"
$env:MERGE_TOOL = "nvim"
$env:DIFF_TOOL = "nvim"

# PSReadLine options for better command line editing
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

# Color scheme for directory listing
$PSStyle.FileInfo.Directory = "`e[34;1m"

#endregion

#region Prompt (Starship)

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue)
{
  # Use PowerShell-specific Starship config
  $ENV:STARSHIP_CONFIG = Join-Path $HOME ".config" "starship" "starship-powershell.toml"
    
  # Enable ANSI escape sequences support (important for Windows)
  if ($IsWindows)
  {
    # Enable Virtual Terminal Processing for ANSI colors
    $null = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $null = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
  }
    
  Invoke-Expression (&starship init powershell)
} else
{
  Write-Warning "Starship not found. Install it with: winget install Starship.Starship"
}

#endregion

#region Completion (Carapace)

# Initialize Carapace for completions
if (Get-Command carapace -ErrorAction SilentlyContinue)
{
  if (Get-Module -Name PSReadLine)
  {
    Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
  }
  carapace _carapace | Out-String | Invoke-Expression
} else
{
  Write-Warning "Carapace not found. Install it with: winget install rsteube.carapace"
}

#endregion

#region History (Atuin)

# Initialize Atuin for enhanced history
if (Get-Command atuin -ErrorAction SilentlyContinue)
{
  if (Get-Module -Name PSReadLine)
  {
    # Atuin keybindings
    Set-PSReadLineKeyHandler -Key UpArrow -ScriptBlock {
      [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert('atuin search --shell-up-key-binding')
      [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
        
    Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
      [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert('atuin search -i')
      [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
  }
    
  # Initialize Atuin
  $env:ATUIN_SESSION = (atuin uuid).ToString().Trim()
    
  # Hook for command history
  $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)
  }
} else
{
  Write-Warning "Atuin not found. Install it with: cargo install atuin"
}

#endregion

#region Fast Navigation (zoxide)

# Initialize zoxide for fast directory navigation
if (Get-Command zoxide -ErrorAction SilentlyContinue)
{
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else
{
  Write-Warning "Zoxide not found. Install it with: winget install ajeetdsouza.zoxide"
}

#endregion

#region bat (Better cat)

# Configure bat if available
if (Get-Command bat -ErrorAction SilentlyContinue)
{
  # Check if Catppuccin theme is available
  $batThemes = bat --list-themes 2>$null | Out-String
  if ($batThemes -match "Catppuccin Macchiato")
  {
    $env:BAT_THEME = "Catppuccin Macchiato"
  } else
  {
    # Fallback to a good default dark theme
    $env:BAT_THEME = "Monokai Extended"
        
    # Show installation hint only once per session
    if (-not $env:BAT_THEME_WARNING_SHOWN)
    {
      Write-Host "Tip: Install Catppuccin themes for bat with: " -NoNewline -ForegroundColor DarkGray
      Write-Host "./powershell/install-bat-themes.ps1" -ForegroundColor Cyan
      $env:BAT_THEME_WARNING_SHOWN = "1"
    }
  }
    
  $env:BAT_STYLE = "numbers,changes,header,grid"
  $env:BAT_PAGER = "less -RF"
    
  # Set bat as pager for man pages
  $env:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
  $env:MANROFFOPT = "-c"
}

#endregion

#region Fuzzy Finder (fzf)

# Initialize fzf for fuzzy finding
if (Get-Command fzf -ErrorAction SilentlyContinue)
{
  # Set fzf default options
  $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
    
  if (Get-Module -Name PSReadLine)
  {
    # Ctrl+T: File search
    Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
      $file = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | 
        Select-Object -ExpandProperty FullName | 
        fzf --preview 'type {}'
            
      if ($file)
      {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($file)
      }
    }
        
    # Ctrl+R: History search (if not using Atuin)
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

#endregion

#region Aliases

# Explorer alias (y for yazi)
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

# Navigation alias (z from zoxide)
if (Get-Command zoxide -ErrorAction SilentlyContinue)
{
  Set-Alias -Name cd -Value z -Option AllScope -Scope Global -Force
}

# Better ls with colors (if eza/exa available, otherwise use default)
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
} elseif (Get-Command exa -ErrorAction SilentlyContinue)
{
  function ls
  { exa --icons --group-directories-first $args 
  }
  function ll
  { exa --icons --group-directories-first -l $args 
  }
  function la
  { exa --icons --group-directories-first -la $args 
  }
  function lt
  { exa --icons --group-directories-first --tree $args 
  }
} else
{
  function ls
  { Get-ChildItem @args 
  }
  function ll
  { Get-ChildItem -Force @args | Format-Table -AutoSize 
  }
  function la
  { Get-ChildItem -Force @args 
  }
}

# Useful shortcuts
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

# Quick edit profile
function Edit-Profile
{ nvim $PROFILE 
}
Set-Alias -Name ep -Value Edit-Profile -Force

# Reload profile
function Reload-Profile
{ 
  . $PROFILE
  Write-Host "Profile reloaded!" -ForegroundColor Green
}
Set-Alias -Name rp -Value Reload-Profile -Force

# System information
function sysinfo
{
  Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsArchitecture
}

# Which command (like Unix which)
function which($command)
{
  Get-Command -Name $command -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

#endregion

#region PATH Configuration

# Add common paths if they exist
$pathsToAdd = @(
  (Join-Path $HOME ".cargo" "bin"),                    # Rust
  (Join-Path $HOME ".dotnet" "tools"),                 # .NET tools
  (Join-Path $HOME "go" "bin")                         # Go binaries
)

# Windows-specific paths
if ($IsWindows)
{
  $pathsToAdd += @(
    (Join-Path $HOME "AppData" "Local" "Microsoft" "WinGet" "Links"),  # WinGet packages
    (Join-Path $HOME "AppData" "Roaming" "npm")                        # npm global packages
  )
    
  if ($env:ProgramFiles)
  {
    $pathsToAdd += @(
      (Join-Path $env:ProgramFiles "Docker" "Docker" "resources" "bin"),  # Docker
      (Join-Path $env:ProgramFiles "nodejs")                              # Node.js
    )
  }
    
  if (${env:ProgramFiles(x86)})
  {
    $pathsToAdd += (Join-Path ${env:ProgramFiles(x86)} "GnuWin32" "bin")  # GnuWin32 tools
  }
}

foreach ($path in $pathsToAdd)
{
  if (Test-Path $path)
  {
    $env:PATH = "$path;$env:PATH"
  }
}

#endregion

#region Node.js Configuration (NVM)

# Initialize nvm-windows if available
if (Test-Path "$env:NVM_HOME\nvm.exe")
{
  # NVM is already configured via environment variables
  Write-Verbose "NVM detected at $env:NVM_HOME"
}

# Set npm global packages location
$env:NPM_CONFIG_PREFIX = Join-Path $HOME ".config" "npm-packages"
if (-not (Test-Path $env:NPM_CONFIG_PREFIX))
{
  New-Item -ItemType Directory -Path $env:NPM_CONFIG_PREFIX -Force | Out-Null
}
$env:PATH = "$env:NPM_CONFIG_PREFIX;$env:PATH"

#endregion

#region Development Tools

# Docker (if using Podman on Windows)
if (Get-Command podman -ErrorAction SilentlyContinue)
{
  $env:DOCKER_HOST = "unix://$HOME/.local/share/containers/podman/machine/podman.sock"
}

# Java (if using multiple versions)
# $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
# $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

#endregion

#region Utility Functions

# Create a directory and cd into it
function mkcd($path)
{
  New-Item -ItemType Directory -Path $path -Force | Out-Null
  Set-Location $path
}

# Extract archives
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

# Find files
function Find-File
{
  param(
    [Parameter(Mandatory)]
    [string]$Pattern
  )
  Get-ChildItem -Recurse -Filter $Pattern -ErrorAction SilentlyContinue
}
Set-Alias -Name ff -Value Find-File

# Grep equivalent
function grep
{
  param(
    [Parameter(Mandatory)]
    [string]$Pattern,
    [Parameter(ValueFromPipeline)]
    [object]$InputObject
  )
    
  process
  {
    if ($InputObject)
    {
      $InputObject | Select-String -Pattern $Pattern
    } else
    {
      Select-String -Pattern $Pattern -Path * -Recurse
    }
  }
}

# Touch command
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

# Open file explorer in current directory
function explorer
{ Start-Process explorer . 
}
Set-Alias -Name open -Value explorer

#endregion

#region Completion Enhancements

# Enable argument completion for dotnet CLI
if (Get-Command dotnet -ErrorAction SilentlyContinue)
{
  Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }
}

# Enable argument completion for winget
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

#endregion

#region Welcome Message

# Show welcome message (comment out if you don't want it)
if ($Host.UI.RawUI.WindowSize.Width -gt 80)
{
  Write-Host ""
  Write-Host "  PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
  Write-Host "  Type 'ep' to edit profile, 'rp' to reload" -ForegroundColor Gray
  Write-Host ""
}

#endregion

# Load local profile overrides if exists
$localProfile = Join-Path $PSScriptRoot "profile.local.ps1"
if (Test-Path $localProfile)
{
  . $localProfile
}
