param($BuildPath, $Package)

$toolsDir = Join-Path $BuildPath 'tools'
$packagesDir = Join-Path $toolsDir 'Packages'
$progetPackage = Get-ChildItem $toolsDir -Filter 'ProGet*'
$hubPackage = Get-ChildItem $toolsDir -Filter 'DesktopHub*.upack'
$hubDir = Join-Path $toolsDir 'hub'

Write-Host 'Expanding hub package...'
& upack unpack $hubPackage $hubDir

Write-Host 'Copying hub files...'
Copy-Item (Join-Path $hubDir '*') $toolsDir -Recurse -Force | Out-Null
Remove-Item $hubDir -Recurse -Force | Out-Null
Remove-Item $hubPackage -Force | Out-Null

Write-Host 'Copying Proget package...'
New-Item $packagesDir -ItemType Directory | Out-Null
Move-Item $progetPackage $packagesDir -Force | Out-Null