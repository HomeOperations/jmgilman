$packageName = 'proget'
$fileName = 'hub.exe'
$fileType = 'exe'

$config = @{
    CONN_STRING = 'Data Source=localhost\SQLEXPRESS; Integrated Security=True;'
    LICENSE     = ''
}

$param = Get-PackageParameters
foreach ($p in $param.GetEnumerator()) {
    if ($p.Name -in $config.Keys) {
        $config[$p.Name] = $p.Value
    }
}

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fileLocation = Join-Path $toolsDir $fileName

$silentArgs = "install ProGet --ConnectionString=`"$($config.CONN_STRING)`""
if ($config.LICENSE) {
    $silentArgs += " --LicenseKey=$($config.LICENSE)"
}

Install-ChocolateyInstallPackage `
    -PackageName $packageName `
    -FileType $fileType `
    -File64 $fileLocation `
    -SilentArgs $silentArgs