$ErrorActionPreference = 'Stop'

# Refresh PATH for this process
$env:Path = @(
  [System.Environment]::GetEnvironmentVariable('Path','Machine'),
  [System.Environment]::GetEnvironmentVariable('Path','User')
) -join ';'
try { refreshenv } catch {}

$toolsLocation = Get-ToolsLocation
$installRoot = Join-Path $toolsLocation 'gemini-cli'

Write-Host "Removing Chocolatey shim for gemini..."
Uninstall-BinFile -Name 'gemini' -ErrorAction SilentlyContinue

if (Test-Path $installRoot) {
  Remove-Item $installRoot -Recurse -Force
}

Write-Host "`nUninstall completed successfully."
