param($BuildPath, $Package)

$packageManagementVersion = '1.4.7'
$powershellGetVersion = '2.2.5'

$toolsDir = Join-Path $BuildPath 'tools'

Write-Verbose ('Saving PackageManagement version {0} to {1}' -f $packageManagementVersion, $toolsDir)
Save-Module -Name PackageManagement -RequiredVersion $packageManagementVersion -Path $toolsDir -Repository internal-powershell

Write-Verbose ('Saving PowershellGet version {0} to {1}' -f $powershellGetVersion, $toolsDir)
Save-Module -Name PowershellGet -RequiredVersion $powershellGetVersion -Path $toolsDir -Repository internal-powershell
