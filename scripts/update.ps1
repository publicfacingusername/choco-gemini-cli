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
$updatedNuspec = [regex]::Replace(
  $nuspecContent,
  '<version>[^<]+</version>',
  "<version>$latest</version>"
)
if ($updatedNuspec -ne $nuspecContent) {
  Set-Content -Path $nuspec.FullName -Value $updatedNuspec -Encoding utf8
}

$newNuspecName = "$packageName.$latest.nuspec"
if ($nuspec.Name -ne $newNuspecName) {
  Rename-Item -Path $nuspec.FullName -NewName $newNuspecName
}

Write-Host "Updated $packageName to $latest"
