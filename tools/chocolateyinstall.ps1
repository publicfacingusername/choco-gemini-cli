# tools\chocolateyinstall.ps1
$ErrorActionPreference = 'Stop'

# Refresh PATH in this process
$env:Path = (@(
  [System.Environment]::GetEnvironmentVariable('Path','Machine'),
  [System.Environment]::GetEnvironmentVariable('Path','User')
) -join ';')
try { refreshenv } catch { }

# Verify Node.js is available
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
  throw "Node.js not found. Install 'nodejs-lts' first."
}

# Verify Node >= 20
$nodeVersion = (& $nodeCmd --version) -replace '^[vV]'
$nodeMajor = [int]($nodeVersion.Split('.')[0])
if ($nodeMajor -lt 20) {
  throw "Gemini CLI requires Node.js >= 20. Found $nodeVersion."
}

# Install the package
$pkgVersion = $env:ChocolateyPackageVersion
npm install -g "@google/gemini-cli@$pkgVersion" --no-fund --no-audit --loglevel=error
if ($LASTEXITCODE -ne 0) {
  throw "npm install failed with exit code $LASTEXITCODE"
}

# Create Chocolatey shim
$npmPrefix = (npm prefix -g).Trim()
$geminiCmd = Join-Path $npmPrefix 'gemini.cmd'

if (-not (Test-Path $geminiCmd)) {
  $geminiCmd = Join-Path $env:APPDATA 'npm\gemini.cmd'
  if (-not (Test-Path $geminiCmd)) {
    throw "gemini.cmd not found after installation"
  }
}

Install-BinFile -Name 'gemini' -Path $geminiCmd

Write-Host "Installation complete! Run: gemini --help"