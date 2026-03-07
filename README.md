## Prerequisites

### MacOS : Install homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Windows: Allow script execution & Git

```powershell
Set-ExecutionPolicy RemoteSigned
```

#### Winget - Install Git

```powershell
winget install --source winget -e --id Git.Git
```

#### Scoop - Install Scoop and git

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```powershell
scoop install main/git
```

#### Chocolatey - Install Chocolatey and git

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

```powershell
choco install git
```

### Linux

TODO

## Install chezmoi & mise-en-place

### MacOS

```shell
brew install git chezmoi mise
```

### Windows

#### Winget

```powershell
winget install --source winget -e --id twpayne.chezmoi
winget install --source winget -e --id jdx.mise
```

#### Scoop

TODO

#### Chocolatey

TODO

```powershell
scoop install main/mise
scoop install main/chezmoi
```

### Linux

TODO
