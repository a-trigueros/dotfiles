$toCleanFilter = (
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

Get-AppxPackage `
| Where-Object { `
  $package = $_; `
  $toCleanFilter | ForEach-Object { `
    $Package.PackageFullName.StartsWith($_) `
  } | Where-Object { $_ } } | Remove-AppxPackage

