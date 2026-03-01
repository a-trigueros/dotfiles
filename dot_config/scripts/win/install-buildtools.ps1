# Download VS installer for buildtools
$vsInstaller = "$env:TEMP\vs_buildtools.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile $vsInstaller

# Run installer with arguments
 Start-Process -FilePath $vsInstaller -ArgumentList `
    "--quiet --wait --norestart --nocache `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --includeRecommended" -Wait
