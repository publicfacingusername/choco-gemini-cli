$ErrorActionPreference = 'Stop'

# Refresh PATH for this process
$env:Path = @(
  [System.Environment]::GetEnvironmentVariable('Path','Machine'),
  [System.Environment]::GetEnvironmentVariable('Path','User')
) -join ';'
try { refreshenv } catch {}

Write-Host "Attempting to uninstall @google/gemini-cli globally..."

# Uninstall the npm package
npm uninstall -g @google/gemini-cli --loglevel=error

# Remove the Chocolatey shim
Write-Host "Removing Chocolatey shim for gemini..."
Uninstall-BinFile -Name 'gemini' -ErrorAction SilentlyContinue

Write-Host "`nUninstall completed successfully."
