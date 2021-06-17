$PROVIDER_VERSION = '2.8.5.208'

# Install Powershell 7
$packageName = 'powershell-core'
$fileName = 'PowerShell-7.1.3-win-x64.msi'
$fileType = 'msi'
$silentArgs = '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fileLocation = Join-Path $toolsDir $fileName

Write-Host 'Installing Powershell Core...'
Install-ChocolateyInstallPackage `
    -PackageName $packageName `
    -FileType $fileType `
    -File64 $fileLocation `
    -SilentArgs $silentArgs

# Install NuGet provider and PowershellGet
$PROVIDER_PATH = Join-Path $env:ProgramFiles ('PackageManagement\ProviderAssemblies\nuget\{0}' -f $PROVIDER_VERSION)
$NUGET_PATH = Join-Path $env:ProgramData 'Microsoft\Windows\PowerShell\PowerShellGet'

$providerFilePath = Join-Path $toolsDir 'Microsoft.PackageManagement.NuGetProvider.dll'
$nugetFilePath = Join-Path $toolsDir 'nuget.exe'
$packageManagementFilePath = Join-Path $toolsDir 'PackageManagement'
$powershellGetFilePath = Join-Path $toolsDir 'PowerShellGet'

$modulePath = Join-Path ${env:ProgramFiles} 'PowerShell\7\Modules'

Write-Host 'Installing NuGet provider...'
New-Item -ItemType Directory -Path $PROVIDER_PATH
Copy-Item $providerFilePath $PROVIDER_PATH -Force

Write-Host 'Installing NuGet binary...'
New-Item -ItemType Directory -Path $NUGET_PATH
Copy-Item $nugetFilePath $NUGET_PATH -Force

Write-Host 'Installing PowershellGet...'
if (Test-Path (Join-Path $modulePath 'PackageManagement')) {
    Remove-Item (Join-Path $modulePath 'PackageManagement') -Recurse -Force
}
Copy-Item $packageManagementFilePath $modulePath -Recurse -Force

if (Test-Path (Join-Path $modulePath 'PowerShellGet')) {
    Remove-Item (Join-Path $modulePath 'PowerShellGet') -Recurse -Force
}
Copy-Item $powershellGetFilePath $modulePath -Recurse -Force