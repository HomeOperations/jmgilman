param($BuildPath, $Package)

$toolsDir = Join-Path $BuildPath 'tools'
$zipFile = Join-Path $BuildPath $Package.RemoteFiles[0].ImportPath

Expand-Archive $zipFile $toolsDir
Remove-Item $zipFile