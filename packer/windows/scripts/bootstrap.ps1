Function Install-ChocolateyPackage {
    param(
        [string] $Repository,
        [string] $PackageName
    )

    Write-Host ('Searching for latest version of package {0}...' -f $PackageName)
    $searchPath = '/Packages()?$filter=(Id%20eq%20%27{0}%27)%20and%20IsLatestVersion' -f $PackageName
    $searchUrl = $Repository.Trim('/') + $searchPath
    [xml] $resp = Invoke-WebRequest $searchUrl -UseBasicParsing
    $packageUrl = $resp.feed.entry.content.src

    Write-Host 'Creating temporary directory...'
    $tempFolder = Join-Path $env:TEMP New-Guid
    if (Test-Path $tempFolder) {
        Remove-Item $tempFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempFolder | Out-Null

    Write-Host ('Downloading package from {0}...' -f $packageUrl)
    $packagePath = Join-Path $tempFolder ($PackageName + '.zip')
    Invoke-WebRequest $packageUrl -OutFile $packagePath

    Write-Host 'Installing package...'
    $installScript = Join-Path $tempFolder 'tools/ChocolateyInstall.ps1'
    Expand-Archive $packagePath $tempFolder
    Start-Process 'powershell' -ArgumentList @('-File', $installScript) -NoNewWindow -Wait

    Write-Host 'Cleaning up...'
    Remove-Item $tempFolder -Recurse -Force
}

$CHOCOLATEY_REPO = 'http://proget.gilman.io:8624/nuget/internal-chocolatey/'
$POWERSHELL_REPO = 'http://proget.gilman.io:8624/nuget/internal-powershell/'

# Install Chocolatey
Write-Host 'Installing Chocolatey...'
Install-ChocolateyPackage -Repository $CHOCOLATEY_REPO -PackageName 'chocolatey'
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Add Chocolatey repository
choco source remove -n 'chocolatey'
choco source add -n 'internal-chocolatey' -s $CHOCOLATEY_REPO

# Install Powershell Core
Write-Host 'Installing Powershell Core...'
Start-Process 'choco' -ArgumentList @('install', 'powershell-core', '-y', '--no-progress') -NoNewWindow -Wait
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Add Powershell repository
Register-PSRepository -Name 'internal-powershell' -SourceLocation $POWERSHELL_REPO -PublishLocation $POWERSHELL_REPO -InstallationPolicy Trusted 