$ErrorActionPreference = 'Stop'

$packageName = 'gemini-cli'
$registryUrl = 'https://registry.npmjs.org/@google/gemini-cli'

$registry = Invoke-RestMethod -Uri $registryUrl -Headers @{
  'User-Agent' = 'Gemini-CLI-Choco-Updater'
}

$latest = $registry.'dist-tags'.latest
if ([string]::IsNullOrWhiteSpace($latest)) {
  throw 'Latest npm dist-tag is empty.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$nuspec = Get-ChildItem -Path $repoRoot -Filter "$packageName.*.nuspec" | Select-Object -First 1
if (-not $nuspec) {
  throw "Could not find a $packageName nuspec file."
}

$nuspecContent = Get-Content -Path $nuspec.FullName -Raw
$currentVersionMatch = [regex]::Match($nuspecContent, '<version>([^<]+)</version>')
$currentVersion = if ($currentVersionMatch.Success) { $currentVersionMatch.Groups[1].Value } else { '' }

$expectedNuspecName = "$packageName.$latest.nuspec"
if ($currentVersion -eq $latest -and $nuspec.Name -eq $expectedNuspecName) {
  Write-Host "$packageName is already at $latest. No update needed."
  return
}

$updatedNuspec = [regex]::Replace(
  $nuspecContent,
  '<version>[^<]+</version>',
  "<version>$latest</version>"
)
if ($updatedNuspec -ne $nuspecContent) {
  Set-Content -Path $nuspec.FullName -Value $updatedNuspec -Encoding utf8
}

if ($nuspec.Name -ne $expectedNuspecName) {
  Rename-Item -Path $nuspec.FullName -NewName $expectedNuspecName
}

Write-Host "Updated $packageName to $latest"
