<#
.Synopsis
   Downloads and copies all required files into the current working directory
   under the 'files' folder. 
.DESCRIPTION
   This script is intended to be run by a machine deployed within glab that has
   internet access. The script will download required files as well as copy
   required installation files from the given paths (see README for instructions).
.EXAMPLE
   .\download.ps1 -ConfigFile .\choco\config.psd1 -ProGetPath C:\path\to\proget -SqlPath C:\path\to\sql
.NOTES
    Name: download.ps1
    Author: Joshua Gilman (@jmgilman)
#>

# Parameters
param(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1
    )]
    [string]  $ConfigFile,
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 2
    )]
    [string]  $ProGetPath,
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 3
    )]
    [string]  $SqlPath
)

function Get-Provider {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Name,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $FileName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Version,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [string]  $ProviderPath,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [string]  $Path
    )

    # Check if the provider is already installed on the local system
    $full_provider_path = Join-Path $ProviderPath "nuget\$Version"
    if (!(Test-Path $full_provider_path)) {
        Write-Verbose 'Installing the NuGet provider to the local machine...'
        Install-PackageProvider -Name $Name -RequiredVersion $Version -Force | Out-Null
    }

    # Copy the provider to the path
    Compress-Archive -Path (Join-Path $ProviderPath 'nuget') -DestinationPath (Join-Path $Path $FileName) -Force
}

function Get-NuGet {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Url,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $FileName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Path
    )
    # Download the NuGet executable to the path
    Invoke-WebRequest -Uri $Url -OutFile (Join-Path $Path $FileName)
}

function Get-Chocolatey {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Url,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $FileName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Path
    )
    # Download Chocolatey NuGet package to the path
    Invoke-WebRequest -Uri $Url -OutFile (Join-Path $Path $FileName)
}

function Get-Bootstrap {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Path
    )
    # Copy the bootstrap script to the path
    Copy-Item (Join-Path $PSScriptRoot '..\choco\bootstrap.ps1') $Path
}

function Get-ProGet {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $ProGetPath,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $ProGetFileName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Path
    )
    # Archive ProGet installation files
    Compress-Archive -Path (Join-Path $ProGetPath '*') -DestinationPath (Join-Path $Path $ProGetFileName)
}

function Get-Sql {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $SqlPath,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $SqlFileName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Path
    )
    # Archive SQL installer
    Compress-Archive -Path (Join-Path $SqlPath '*') -DestinationPath (Join-Path $Path $SqlFileName)
}

function Get-PoshProget {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Url,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $Path,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $FileName
    )

    Invoke-WebRequest -Uri $Url -OutFile (Join-Path $Path $FileName)
}

# Don't let the script continue with errors
$ErrorActionPreference = 'Stop'

$CONFIG = Import-PowerShellDataFile $ConfigFile
$local_path = Join-Path (Get-Location) 'files'
$provider_path = Join-Path $env:ProgramFiles $CONFIG.provider.path

# If local path exists, clear it out, otherwise create it
if (Test-Path $local_path) {
    Remove-Item (Join-Path $local_path '*') -Recurse -Force
}
else {
    New-Item -ItemType Directory -Path $local_path -Force
}

Get-PoshProget -Url $CONFIG.posh_proget.url -Path $local_path -FileName $CONFIG.posh_proget.file_name
Get-Provider -Name $CONFIG.provider.name -FileName $CONFIG.provider.file_name -Version $CONFIG.provider.version -ProviderPath $provider_path -Path $local_path
Get-NuGet -Url $CONFIG.nuget.url -FileName $CONFIG.nuget.file_name -Path $local_path
Get-Chocolatey -Url $CONFIG.choco.url -FileName $CONFIG.choco.file_name -Path $local_path
Get-Bootstrap -Path $local_path
Get-ProGet -ProGetPath $ProGetPath -ProGetFileName $CONFIG.proget.file_name -Path $local_path
Get-Sql -SqlPath $SqlPath -SqlFileName $CONFIG.sql.file_name -Path $local_path