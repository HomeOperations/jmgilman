<#
.Synopsis
   Installs and configures a ProGet server designed to be used within glab.
.DESCRIPTION
   This script is intended to be run on a machine within glab that needs to be
   configured as a ProGet server. The script takes options for installing the
   required SQL Server and ProGet Server applications as well as doing the
   initial configuration of the ProGet server once installed. The configuration
   portion is idempotent and can be run several times. 
.EXAMPLE
   .\choco\proget.ps1 -ConfigFile .\choco\config.psd1 -Install ProGet -License mylicense
.NOTES
    Name: proget.ps1
    Author: Joshua Gilman (@jmgilman)
#>

# Parameters
param(
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1
    )]
    [ValidateSet('ProGet', 'SQL')]
    [string]  $Install,
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 2
    )]
    [switch]  $Configure,
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 3
    )]
    [string]  $ConfigFile,
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 4
    )]
    [string]  $License,
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 5
    )]
    [string]  $ApiKey
)

function Install-SQL {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $FileFolder,
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
        [string]  $SqlConfigFile,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [string]  $SqlExecutable
    )
    # Unzip SQL archive
    $sql_folder = Join-Path $FileFolder 'sql'
    Expand-Archive -Path (Join-Path $FileFolder $SqlFileName) -DestinationPath $sql_folder -Force

    # Run SQL installer
    $sql_installer_path = Join-Path $sql_folder $SqlExecutable
    $proc = Start-Process $sql_installer_path -ArgumentList "/ConfigurationFile=$SqlConfigFile", '/IAcceptSQLServerLicenseTerms' -PassThru -NoNewWindow -Wait
    return $proc.ExitCode -eq 0
}

function Install-ProGet {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $FileFolder,
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
        [string]  $ProGetExecutable,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [string]  $SqlInstance,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [string]  $License
    )
    # Unzip ProGet archive
    $proget_folder = Join-Path $FileFolder 'proget'
    Expand-Archive -Path (Join-Path $FileFolder $ProGetFileName) -DestinationPath $proget_folder -Force

    # Run ProGet installer
    $proget_installer_path = Join-Path $proget_folder $ProGetExecutable
    $proget_args = @('install', 
        'ProGet', 
        "--ConnectionString=`"Data Source=localhost\$SqlInstance; Integrated Security=True;`"",
        "--LicenseKey=$License")
    $proc = Start-Process $proget_installer_path -ArgumentList $proget_args -PassThru -NoNewWindow -Wait

    if ($proc.ExitCode -ne 0) {
        return $false
    }

    # Add firewall rule for ProGet web server
    New-NetFirewallRule -DisplayName 'ProGet Server' -Direction Inbound -LocalPort 8624 -Protocol TCP -Action Allow | Out-Null
    
    return $true
}

function Install-Provider {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $FileFolder,
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
        [string]  $ProviderPath
    )
    New-Item -Type Directory -Path $ProviderPath -Force | Out-Null
    Expand-Archive -Path (Join-Path $FileFolder $FileName) -DestinationPath $ProviderPath -Force
}

function Install-NuGet {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $FileFolder,
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
        [string]  $NuGetPath
    )
    New-Item -Type Directory -Path $NuGetPath -Force | Out-Null
    Copy-Item -Path (Join-Path $FileFolder $FileName) -Destination (Join-Path $NuGetPath $FileName) -Force
}

function Invoke-ProGetApi {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Type,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $ApiKey,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Endpoint,
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [object[]]  $Data
    )
    $headers = @{
        'X-ApiKey' = $ApiKey
    }
    $params = @{
        Method      = $Type
        Uri         = $Endpoint
        ContentType = 'application/json'
        Headers     = $headers
        Body        = ($Data | ConvertTo-Json)
    }
    Invoke-RestMethod @params
}

function Invoke-NuGetApi {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]  $Type,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]  $ApiKey,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]  $Endpoint,
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [object[]]  $Data
    )
    $headers = @{
        'X-ApiKey' = $ApiKey
    }
    $params = @{
        Method      = $Type
        Uri         = $Endpoint
        ContentType = 'application/json'
        Headers     = $headers
        Body        = ($Data | ConvertTo-Json)
    }
    Invoke-RestMethod @params
}

# Don't let the script continue with errors
$ErrorActionPreference = 'Stop'

$CONFIG = Import-PowerShellDataFile $ConfigFile
$local_file_folder = Join-Path (Get-Location) 'files'
$sql_config_file = Join-Path $PSScriptRoot 'sql.ini'

# Check for files
if (!(Test-Path $local_file_folder)) {
    Write-Error 'Please run the download script before running this script'
    exit
}

switch ($Install) {
    'SQL' {
        # Install SQL Express
        $result = Install-SQL -FileFolder $local_file_folder -SqlFileName $CONFIG.sql.file_name -SqlConfigFile $sql_config_file -SqlExecutable $CONFIG.sql.executable
        if (!$result) {
            Write-Error 'Installation of SQL Express failed. Please check logs and try again.'
        }
        break
    }
    'ProGet' {
        # Determine SQL instance name
        [string](Get-Content -Path $sql_config_file) -match 'INSTANCENAME="(.*?)"'
        $sql_instance_name = $Matches[1]

        # Install ProGet
        $result = Install-ProGet -FileFolder $local_file_folder -ProGetFileName $CONFIG.proget.file_name -ProGetExecutable $CONFIG.proget.executable -SqlInstance $sql_instance_name -License $License
        if (!$result) {
            Write-Error 'Installation of ProGet failed. Please check the logs and try again.'
        
            # ProGet tends to leave artifacts behind, so we remove them just in case
            $proget_installer_path = Join-Path (Join-Path $local_file_folder 'proget') $ProGetExecutable
            Start-Process $proget_installer_path -ArgumentList 'uninstall', 'ProGet' -PassThru -NoNewWindow -Wait
            Exit
        }
        break
    }
}

# Make this idempotent since it has a decent chance of failing and needing to be rerun
if ($Configure) {
    # Check for API key
    if (!$PSBoundParameters.ContainsKey('ApiKey')) {
        Write-Error 'Please supply an API key to configure the ProGet server'
        exit
    }

    # Check for NuGet files
    $provider_path = Join-Path $env:ProgramFiles $CONFIG.provider.path
    $provider_full_path = Join-Path $env:ProgramFiles $CONFIG.provider.path | Join-Path -ChildPath $CONFIG.provider.name | Join-Path -ChildPath $CONFIG.provider.version
    if (!(Test-Path $provider_full_path)) {
        Install-Provider -FileFolder $local_file_folder -FileName $CONFIG.provider.file_name -ProviderPath $provider_path
    }

    $nuget_path = Join-Path $env:ProgramData $CONFIG.nuget.path
    $nuget_full_path = Join-Path $env:ProgramData $CONFIG.nuget.path | Join-Path -ChildPath $CONFIG.nuget.file_name
    if (!(Test-Path $nuget_full_path)) {
        Install-NuGet -FileFolder $local_file_folder -FileName $CONFIG.nuget.file_name -NuGetPath $nuget_path
    }

    # Import Posh-Proget module
    $posh_proget_path = Join-Path $local_file_folder $CONFIG.posh_proget.file_name
    Expand-Archive $posh_proget_path $local_file_folder -Force
    Import-Module (Join-Path $local_file_folder 'posh-proget-main\Posh-Proget')

    # Check for existing feeds
    $session = New-ProGetSession $CONFIG.proget.server $ApiKey
    $feeds = Get-ProGetFeeds $session

    # Powershell feed
    if (!($feeds | Where-Object Name -EQ $CONFIG.proget.feeds.powershell.name)) {
        $feed_obj = New-ProGetFeedObject $CONFIG.proget.feeds.powershell
        $feed = New-ProGetFeed $session $feed_obj

        if (!$feed) {
            Write-Error "Failed creating Powershell feed: $($Error[0])"
            exit
        }
    }

    # Chocolatey feed
    if (!($feeds | Where-Object Name -EQ $CONFIG.proget.feeds.chocolatey.name)) {
        $feed_obj = New-ProGetFeedObject $CONFIG.proget.feeds.chocolatey
        $feed = New-ProGetFeed $session $feed_obj

        if (!$feed) {
            Write-Error "Failed creating Chocolatey feed: $($Error[0])"
            exit
        }
    }

    # Assets feed
    if (!($feeds | Where-Object Name -EQ $CONFIG.proget.feeds.bootstrap.name)) {
        $feed_obj = New-ProGetFeedObject $CONFIG.proget.feeds.bootstrap
        $feed = New-ProGetFeed $session $feed_obj

        if (!$feed) {
            Write-Error "Failed creating bootstrap assets feed: $($Error[0])"
            exit
        }
    }

    # Register Powershell feed locally
    if (!(Get-PSRepository | Where-Object Name -EQ $CONFIG.proget.feeds.powershell.name)) {
        $url = Get-ProGetFeedUrl $session (Get-ProGetFeed $session $CONFIG.proget.feeds.powershell.name)
        Register-PSRepository -Name $CONFIG.proget.feeds.powershell.name -SourceLocation $url -PublishLocation $url -InstallationPolicy Trusted 
    }

    # Publish Posh-ProGet module
    if (!(Find-Module -Name $CONFIG.posh_proget.name -Repository $CONFIG.proget.feeds.powershell.name -ErrorAction SilentlyContinue)) {
        Publish-Module -Path (Join-Path $local_file_folder 'posh-proget-main\Posh-Proget') -NuGetApiKey $ApiKey -Repository $CONFIG.proget.feeds.powershell.name 
    }

    # Install Chocolatey (locally)
    if (!(Get-Command choco -ErrorAction 'SilentlyContinue')) {
        # Unzip NuGet file
        $choco_nuget_path = Join-Path $local_file_folder $CONFIG.choco.file_name
        $choco_zip_path = Join-Path $local_file_folder 'choco.zip'
        $choco_folder = Join-Path $local_file_folder 'choco'
        Copy-Item $choco_nuget_path $choco_zip_path -Force
        Expand-Archive -Path $choco_zip_path -DestinationPath $choco_folder -Force

        # Run install file
        $installFile = Join-Path $choco_folder 'tools' | Join-Path -ChildPath 'chocolateyInstall.ps1'
        Start-Process 'powershell.exe' -ArgumentList $installFile -PassThru -NoNewWindow -Wait | Out-Null

        # Modify path
        if (!('C:\ProgramData\chocolatey\bin' -in ($env:PATH -split ';'))) {
            $env:PATH = $env:PATH + ';C:\ProgramData\chocolatey\bin'
        }
    }

    # Publish Chocolatey NuGet
    $choco_url = Get-ProGetFeedUrl $session (Get-ProGetFeed $session $CONFIG.proget.feeds.chocolatey.name)
    if (!(Find-Package -Source $choco_url -Name $CONFIG.choco.package_name -ErrorAction SilentlyContinue)) {
        $choco_nuget_path = Join-Path $local_file_folder $CONFIG.choco.file_name
        $choco_args = @(
            $choco_nuget_path,
            '-source',
            $choco_url,
            '-api-key',
            $ApiKey,
            '-force'
        )
        Start-Process 'cpush.exe' -ArgumentList $choco_args -PassThru -NoNewWindow -Wait
    }

    # Upload assets
    $CONFIG.assets | ForEach-Object {
        if (!(Get-ProGetAsset $session $CONFIG.proget.feeds.bootstrap.name $_.name -ErrorAction SilentlyContinue)) {
            New-ProGetAsset `
                -Session $session `
                -FeedName $CONFIG.proget.feeds.bootstrap.name `
                -Path $_.name `
                -ContentType $_.type `
                -InFile (Join-Path $local_file_folder $_.name)
        }
    }
}