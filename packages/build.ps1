[cmdletbinding()]
param(
    [string] $PackageFile,
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'
Import-Module ChocolateyPackageCreator

if (!(Test-Path $PackageFile)) {
    throw 'Cannot find config file at {0}' -f $PackageFile
}

if (!(Test-Path $OutPath)) {
    throw 'The output path must already exist at {0}' -f $OutPath
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
$hasDefender = Test-Path (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue)


$config = Import-PowerShellDataFile $PackageFile
$packagePath = New-ChocolateyPackage (Split-Path $PackageFile) $config | 
    Build-ChocolateyPackage -OutPath $OutPath -ScanFiles:$hasDefender -Verbose:$verbose

Write-Output "##vso[task.setvariable variable=packagePath;]$packagePath"