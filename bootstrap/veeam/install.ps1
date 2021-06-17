param (
    [string] $LicenseFile = '',
    [string] $LicenseUrl = ''
)

$ErrorActionPreference = 'Stop'

if ($LicenseUrl) {
    $licenseFilePath = Join-Path $env:TEMP 'veeam.lic'

    Write-Host ('Downloading license file to {0}...' -f $licenseFilePath)
    Invoke-WebRequest $LicenseUrl -OutFile $licenseFilePath
}
else {
    if (!(Test-Path $License)) {
        throw 'Cannot find license file at {0}' -f $License
    }
    $licenseFilePath = $License
}

$veeamArgs = @(
    'install',
    'veeam',
    '-y',
    '-v',
    '--paramsglobal',
    ("--params `"'/VBR_LICENSE_FILE:{0}'`"" -f $licenseFilePath)
)
$veeamEntArgs = @(
    'install',
    'veeam-enterprise',
    '-y',
    '-v',
    '--paramsglobal',
    ("--params `"'/VBREM_LICENSE_FILE:{0}'`"" -f $licenseFile)
)

Import-Module GLab-Posh

Write-Host 'Installing SQL Server Express...'
$exitCode = Install-ChocolateyPackage -Name sql-express-adv -Verbose
Write-Host ('Install exited with code: ' -f $exitCode)

$veeamArgs = @{
    VBR_LICENSE_FILE = $licenseFilePath
}
Write-Host 'Installing Veeam...'
$exitCode = Install-ChocolateyPackage -Name veeam -Parameters $veeamArgs -Global -Verbose
Write-Host ('Install exited with code: {0}' -f $exitCode)

Write-Host 'Configuring IIS...'
Install-WindowsFeature Web-Server
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication -All

Write-Host 'Installing IIS URL Rewrite...'
$exitCode = Install-ChocolateyPackage -Name iis-url-rewrite -Verbose
Write-Host ('Install exited with code: {0}' -f $exitCode)

$veeamEntArgs = @{
    VBREM_LICENSE_FILE = $licenseFilePath
}
Write-Host 'Installing Veeam Enterprise Manager...'
$exitCode = Install-ChocolateyPackage -Name veeam-enterprise -Parameters $veeamEntArgs -Global -Verbose
Write-Host ('Install exited with code: {0}' -f $exitCode)

Write-Host 'Installation complete. Please reboot when possible.'