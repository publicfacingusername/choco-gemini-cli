$ErrorActionPreference = 'Stop'

# Refresh PATH in this process
$env:Path = (@(
  [System.Environment]::GetEnvironmentVariable('Path','Machine'),
  [System.Environment]::GetEnvironmentVariable('Path','User')
) -join ';')
try { refreshenv } catch { }

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Verify Node.js and npm are available
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
  throw "Node.js not found. Install 'nodejs-lts' first."
}

$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) {
  throw "npm not found. Install 'nodejs-lts' first."
}

# Verify Node >= 20
$nodeVersion = (& $nodeCmd --version) -replace '^[vV]'
$nodeMajor = [int]($nodeVersion.Split('.')[0])
if ($nodeMajor -lt 20) {
  throw "Gemini CLI requires Node.js >= 20. Found $nodeVersion."
}

# Install the package locally to avoid user-global npm paths
$pkgVersion = $env:ChocolateyPackageVersion
$npmRoot = Join-Path $toolsDir 'npm'
if (-not (Test-Path $npmRoot)) {
  New-Item -ItemType Directory -Path $npmRoot | Out-Null
}

Write-Host "Installing @google/gemini-cli@$pkgVersion via npm (this can take a few minutes)..."
& $npmCmd install --prefix $npmRoot "@google/gemini-cli@$pkgVersion" `
  --no-fund --no-audit --loglevel=error --progress=false --no-update-notifier `
  --registry=https://registry.npmjs.org/
if ($LASTEXITCODE -ne 0) {
  throw "npm install failed with exit code $LASTEXITCODE"
}
Write-Host "npm install completed."

# Create Chocolatey shim from local install
$geminiCmd = Join-Path $npmRoot 'node_modules\.bin\gemini.cmd'
if (-not (Test-Path $geminiCmd)) {
  throw "gemini.cmd not found after installation"
}

Install-BinFile -Name 'gemini' -Path $geminiCmd

Write-Host "Installation complete! Run: gemini --help"
