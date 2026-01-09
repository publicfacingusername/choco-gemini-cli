$ErrorActionPreference = 'Stop'

# Refresh PATH for this process
$env:Path = @(
  [System.Environment]::GetEnvironmentVariable('Path','Machine'),
  [System.Environment]::GetEnvironmentVariable('Path','User')
) -join ';'
try { refreshenv } catch {}

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$npmRoot = Join-Path $toolsDir 'npm'

Write-Host "Removing Chocolatey shim for gemini..."
Uninstall-BinFile -Name 'gemini' -ErrorAction SilentlyContinue

if (Test-Path $npmRoot) {
  Remove-Item $npmRoot -Recurse -Force
}

Write-Host "`nUninstall completed successfully."
