<#
.SYNOPSIS
    Creates a Chocolatey package using the given manifest file and file list
.DESCRIPTION
    Creates a Chocolatey package file by downloading the files from the given 
    file list and combining them with the given manifest file. The Chocolatey 
    package file is saved to OutPath. 
.PARAMETER Name
    The name of the package
.PARAMETER Manifest
    A manifest object with the required nuspec properties
.PARAMETER BuildPath
    A temporary directory where build files will be downloaded
.PARAMETER OutPath
    The directory where the Chocolatey package file will be output
.PARAMETER RemoteFiles
    An optional array of dictionaries specifying the files to download and 
    include in the package:

    @( @{name='myfile.exe';url='http://my.com/myfile.exe'} )
.PARAMETER LocalFiles
    An optional array of local file paths to copy and include in the package
.PARAMETER Process
    An optional script block which will be called with a single parameter
    pointing to the build directory. This is called after all files have been
    copied/downloaded but before the package is built. The intended use is to
    do any additional processing on files before the package is built.
.EXAMPLE
    New-ChocolateyPackage `
        -Name mypackage `
        -Manifest $myManifest `
        -RemoteFiles @( @{name='myfile.exe';url='http://my.com/myfile.exe'} ) `
        -BuildPath (Join-Path (Get-Location) 'tmp') `
        -OutPath (Join-Path (Get-Location) 'bin')

    The above would create mypackage.<VER>.nupkg in the current directory and
    would contain myfile.exe downloaded from the given url.
.OUTPUTS
    The exit code of the Chocolatey package process
#>
Function New-ChocolateyPackage {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Name,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [object[]] $Manifest,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $BuildPath,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $OutPath,
        [object[]] $RemoteFiles = @{},
        [string[]] $LocalFiles = @(),
        [scriptblock] $Process = {}
    )
    $buildDir = Join-Path $BuildPath ('glab.packages.{0}' -f $Name)
    $toolsDir = Join-Path $buildDir 'tools'

    # Clear build directory
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force | Out-Null
    }

    # Create build directory
    Write-Host 'Creating build directory...'
    New-Item -ItemType Directory -Path $buildDir | Out-Null
    New-Item -ItemType Directory -Path $toolsDir | Out-Null

    Write-Host 'Creating NuSpec file...'
    $nuspecPath = (Join-Path $buildDir ($Manifest.metadata.Id + '.nuspec'))
    Publish-NuSpec $Manifest $nuspecPath | Out-Null

    if ($RemoteFiles) {
        # Download files
        Write-Host 'Downloading remote package files...'
        foreach ($file in $RemoteFiles) {
            $outFilePath = Join-Path $toolsDir $file.name

            Write-Host ('Downloading {0}...' -f $file.name)
            Invoke-WebRequest $file.url -OutFile $outFilePath

            Write-Host ('Scanning {0}...' -f $file.name)
            $exitCode = Invoke-WindowsDefenderScan $outFilePath

            if ($exitCode -ne 0) {
                throw '{0} was flagged by Windows Defender as dangerous' -f $file.name
            }
        }
    }

    if ($LocalFiles) {
        # Copy local files
        Write-Host 'Copying local package files...'
        foreach ($file in $LocalFiles) {
            Write-Host "Copying $file..."
            Copy-Item $file $toolsDir
        }
    }

    if ($Process) {
        Write-Host 'Running process script...'
        $Process.Invoke($buildDir)
    }

    # Build package
    Write-Host 'Building package...'
    $chocoArgs = @(
        'pack',
        $nuspecPath,
        '--outputdirectory {0}' -f $OutPath
    )
    $proc = Start-Process 'choco' -ArgumentList $chocoArgs -WorkingDirectory $buildDir -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}

<#
.SYNOPSIS
    Creates a UPack package using the given manifest and file list
.DESCRIPTION
    Creates a UPack package file by downloading the files from the given file
    list and combining them with a manifest file generated with the given
    manifest. The UPack file is saved to OutPath. 
.PARAMETER Manifest
    A dictionary containing the desired manifest file properties
.PARAMETER Files
    A list of arrays ordered as such: @('file_name', 'file_url')
.PARAMETER CreatedBy
    The entity that is creating this package
.PARAMETER BuildPath
    A temporary directory where build files will be downloaded
.PARAMETER OutPath
    The directory where the UPack package file will be output
.EXAMPLE
    New-UniversalPackage `
        -Manifest @{name='MyPackage';version='0.0.1'} `
        -Files @(@('myfile.exe', 'http://downloads.com/myfile.exe')) `
        -CreatedBy 'BuildAgent01' `
        -BuildPath (Join-Path (Get-Location) 'tmp')
        -OutPath (Join-Path (Get-Location) 'bin')

    The above would create MyPackage-0.0.1.upack in the current directory and
    would contain myfile.exe downloaded from the given url.
.OUTPUTS
    A .upack file in the format of <name>-<version>.upack located at OutPath
#>
Function New-UniversalPackage {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Name,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [hashtable] $Manifest,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [object[]] $Files,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $BuildPath,
        [Parameter(
            Mandatory = $true,
            Position = 5
        )]
        [string] $OutPath
    )

    $buildDir = Join-Path $BuildPath ('glab.packages.{0}' -f $Name)
    $binDir = Join-Path $buildDir 'bin'

    # Clear build directory
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force | Out-Null
    }
    
    # Create build directory
    Write-Host 'Creating build directory...'
    New-Item -ItemType Directory -Path $buildDir | Out-Null
    New-Item -ItemType Directory -Path $binDir | Out-Null

    # Create manifest file
    Write-Host 'Creating package manifest file...'
    $Manifest.Add('createdDate', (Get-Date -Format u))

    $manifestPath = Join-Path $buildDir 'upack.json'
    Set-Content $manifestPath (ConvertTo-Json $Manifest) | Out-Null

    # Download files
    Write-Host 'Downloading package files...'
    foreach ($file in $Files) {
        $outFilePath = Join-Path $binDir $file.name

        Write-Host ('Downloading {0}...' -f $file.name)
        Invoke-WebRequest $file.url -OutFile $outFilePath

        Write-Host ('Scanning {0}...' -f $file.name)
        $exitCode = Invoke-WindowsDefenderScan $outFilePath

        if ($exitCode -ne 0) {
            throw '{0} was flagged by Windows Defender as dangerous' -f $file.name
        }
    }

    # Build package
    Write-Host 'Building package...'
    & upack pack $binDir --manifest="$manifestPath" --targetDirectory="$OutPath"
}

<#
.SYNOPSIS
    Creates a chocolatey extension package using the given manifest and module
.DESCRIPTION
    Creates a Chocolatey extension package by downloading the given Powershell
    module and compiling it into an extension with Chocolatey. 
.PARAMETER Name
    The name of the package
.PARAMETER Manifest
    A path to the package manifest file
.PARAMETER Module
    The name of the module to fetch from PSGallery and embed in the package
.PARAMETER Version
    The version of the module to fetch from PSGallery
.PARAMETER BuildPath
    A temporary directory where build files will be downloaded
.PARAMETER OutPath
    The directory where the Chocolatey extension package file will be output
.EXAMPLE
    New-ChocolateyExtension `
        -Name myext `
        -Manifest 'myext.nuspec'
        -Module MyExtension `
        -BuildPath (Join-Path (Get-Location) 'tmp') `
        -OutPath (Join-Path (Get-Location) 'bin')
.OUTPUTS
    The exit code of the Chocolatey package process
#>
Function New-ChocolateyExtension {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Name,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [object[]] $Manifest,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Module,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $Version,
        [Parameter(
            Mandatory = $true,
            Position = 5
        )]
        [string] $BuildPath,
        [Parameter(
            Mandatory = $true,
            Position = 6
        )]
        [string] $OutPath
    )

    $buildDir = Join-Path $BuildPath ('glab.packages.{0}' -f $Name)
    $extDir = Join-Path $buildDir 'extensions'

    # Clear build directory
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force | Out-Null
    }

    # Create build directory
    Write-Host 'Creating build directory...'
    New-Item -ItemType Directory -Path $buildDir | Out-Null
    New-Item -ItemType Directory -Path $extDir | Out-Null

    Write-Host 'Creating NuSpec file...'
    $nuspecPath = (Join-Path $buildDir ($Manifest.metadata.Id + '.nuspec'))
    Publish-NuSpec $Manifest $nuspecPath | Out-Null

    # Download module
    if ( -not (Find-Module $Module -RequiredVersion $Version -ErrorAction SilentlyContinue)) {
        throw 'Unable to find module with name ' -f $Module
    }

    Write-Host 'Downloading module...'
    Save-Module $Module $buildDir -RequiredVersion $Version
    Copy-Item (Join-Path $buildDir ('{0}\{1}\*' -f $Module, $Version)) $extDir -Recurse
    Remove-Item (Join-Path $buildDir $Module) -Recurse -Force

    # Build package
    Write-Host 'Building package...'
    $chocoArgs = @(
        'pack',
        $nuspecPath,
        '--outputdirectory {0}' -f $OutPath
    )
    $proc = Start-Process 'choco' -ArgumentList $chocoArgs -WorkingDirectory $buildDir -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}

<#
.SYNOPSIS
    Publishes the given Chocolatey package to the given Chocolatey ProGet feed
.DESCRIPTION
    Using the given API key, connects to and publishes the given Chocolatey 
    package to the given ProGet server. This function will fail if the package 
    version already exists or the API key has insufficient permissions on the 
    feed. This function is intended to be called after New-ChocolateyPackage. 
    Any files downloaded as part of the build will automatically be scanned with
    Windows Defender and negative results will throw an exception and stop the 
    build process.
.PARAMETER Server
    The ProGet server to publish to
.PARAMETER Feed
    The name of the Chocolatey package feed to publish to
.PARAMETER ApiKey
    A ProGet API key with sufficient privileges to publish the package
.PARAMETER PackageFilePath
    The path to the Chocolatey package file
.EXAMPLE
    Publish-ChocolateyPackage `
        -Server proget.my.com `
        -Feed chocolatey `
        -ApiKey 'myapikey' `
        -PackageFilePath 'path/to/package.nupkg'
.OUTPUTS
    None
#>
Function Publish-ChocolateyPackage {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Server,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $Feed,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $ApiKey,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $PackageFilePath
    )

    $url = 'http://{0}/nuget/{1}/' -f $Server, $Feed

    Write-Host 'Deploying package...'
    $chocoArgs = @(
        'push',
        $PackageFilePath,
        ('--source "{0}"' -f $url),
        ('--api-key "{0}"' -f $ApiKey),
        '--force'
    )
    
    $proc = Start-Process 'choco' -ArgumentList $chocoArgs -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}

<#
.SYNOPSIS
    Publishes the given UPack packaget to the given UPack ProGet feed
.DESCRIPTION
    Using the given API key, connects to and publishes the given UPack package
    to the given ProGet server. This function will fail if the package version
    already exists or the API key has insufficient permissions on the feed. This
    function is intended to be called after New-UniversalPackage. Any files
    downloaded as part of the build will automatically be scanned with Windows
    Defender and negative results will throw an exception and stop the build
    process.
.PARAMETER Server
    The ProGet server to publish to
.PARAMETER Feed
    The name of the universal package feed to publish to
.PARAMETER ApiKey
    A ProGet API key with sufficient privileges to publish the package
.PARAMETER Manifest
    A dictionary containing the manifest file properties
.PARAMETER PackagePath
    The path to the directory containing the UPack package file
.EXAMPLE
    Publish-UniversalPackage `
        -Server proget.my.com `
        -Feed universal `
        -ApiKey 'myapikey' `
        -Manifest @{} `
        -PackagePath 'path/to/package/dir'
.OUTPUTS
    None
#>
Function Publish-UniversalPackage {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Server,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $Feed,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $ApiKey,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [hashtable] $Manifest,
        [Parameter(
            Mandatory = $true,
            Position = 5
        )]
        [string] $PackagePath
    )

    $url = 'http://{0}/upack/{1}/' -f $Server, $Feed
    $packageFileName = '{0}-{1}.upack' -f $Manifest.name, $Manifest.version
    $packageFilePath = Join-Path $PackagePath $packageFileName

    & upack push $packageFilePath $url --user="api:$ApiKey"
}

<#
.SYNOPSIS
    Scans the given file using Windows Defender
.DESCRIPTION
    Executes MpCmdRun.exe and performs a custom scan against the given file, 
    returning the exit code of the process. 
.PARAMETER FilePath
    The path to the file the scan
.EXAMPLE
    $exitCode = Invoke-WindowsDefenderScan path\to\file.exe
.OUTPUTS
    The exit code of the scan process: 0 is safe, 2 is unsafe.
#>
Function Invoke-WindowsDefenderScan {
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $FilePath
    )

    $mpCmd = Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe'
    $mpArgs = @(
        '-Scan',
        '-ScanType 3',
        '-File "{0}"' -f $FilePath
    )

    $proc = Start-Process $mpCmd -ArgumentList $mpArgs -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}

<#
.SYNOPSIS
    Creates a nuspec file from the given object
.DESCRIPTION
    Given a valid object, constructs the appropriate XML to create a valid
    nuspec file and saves it to the given destination.
.PARAMETER Nuspec
    The nuspec object to convert to an XML file
.PARAMETER OutFile
    The path to the XML file to output to
.EXAMPLE
    Publish-NuSpec `
        -Nuspec $myNuSpec `
        -OutFile 'package.nuspec'
.OUTPUTS
    None
#>
Function Publish-NuSpec {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [object[]] $Manifest,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $OutFile
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $xml.AppendChild($xml.CreateXmlDeclaration('1.0', 'UTF-8', $null))
    
    $package = $xml.CreateNode('element', 'package', $null)
    $package.SetAttribute('xmlns', 'http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd')

    $metadata = $xml.CreateNode('element', 'metadata', $null)
    foreach ($property in $Manifest.metadata.GetEnumerator()) {
        $xmlProperty = $xml.CreateNode('element', $property.Name, $null)
        $xmlProperty.InnerText = $property.Value
        $metadata.AppendChild($xmlProperty)
    }
    $package.AppendChild($metadata)

    if ($Manifest.dependencies) {
        $dependencies = $xml.CreateNode('element', 'dependencies', $null)
        foreach ($dep in $Manifest.dependencies) {
            $xmlDep = $xml.CreateNode('element', 'dependency', $null)
            $xmlDep.SetAttribute('id', $dep.id)
            $xmlDep.SetAttribute('version', $dep.version)
            $dependencies.AppendChild($xmlDep)
        }
        $metadata.AppendChild($dependencies)
    }

    if ($Manifest.files) {
        $files = $xml.CreateNode('element', 'files', $null)
        foreach ($file in $Manifest.files) {
            $xmlFile = $xml.CreateNode('element', 'file', $null)
            $xmlFile.SetAttribute('src', $file.source)
            $xmlFile.SetAttribute('target', $file.target)
            $files.AppendChild($xmlFile)
        }
        $package.AppendChild($files)
    }

    $xml.AppendChild($package)
    $xml.Save($OutFile)
}