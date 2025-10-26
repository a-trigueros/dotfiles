# Install VS Build tools including C++ (does't works using winget files)
winget install --id Microsoft.VisualStudio.2022.BuildTools --source winget --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --includeRecommended"
