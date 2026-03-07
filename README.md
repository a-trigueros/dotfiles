## Prerequisites

### MacOS : Install homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Windows: Allow script execution

```powershell
Set-ExecutionPolicy RemoteSigned
```

#### Scoop - Install Scoop

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```powershell
scoop install main/git
```

#### Chocolatey - Install Chocolatey

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Linux

TODO

## Install Git, chezmoi & mise-en-place

### MacOS

```shell
brew install git chezmoi mise
```

### Windows

#### Winget

```powershell
winget install --source winget -e --id Git.Git
winget install --source winget -e --id twpayne.chezmoi
winget install --source winget -e --id jdx.mise
```

#### Scoop

```powershell
scoop install main/git
scoop install main/mise
scoop install main/chezmoi
```

#### Chocolatey

TODO

### Linux

TODO
