@{
    assets      = @(
        @{
            name = 'bootstrap.ps1'
            type = 'text/plain'
        }
        @{
            name = 'nuget.exe'
            type = 'application/octet-stream'
        }
        @{
            name = 'provider.zip'
            type = 'application/zip'
        }
        @{
            name = 'posh-proget.zip'
            type = 'application/zip'
        }
    )
    choco       = @{
        package_name = 'chocolatey'
        url          = 'https://www.nuget.org/api/v2/package/chocolatey/0.10.14'
        file_name    = 'chocolatey.0.10.14.nupkg'
    }
    nuget       = @{
        url       = 'https://aka.ms/psget-nugetexe'
        file_name = 'nuget.exe'
        path      = 'Microsoft\Windows\PowerShell\PowerShellGet'
    }
    posh_proget = @{
        url       = 'https://github.com/jmgilman/posh-proget/archive/refs/heads/main.zip'
        file_name = 'posh-proget.zip'
        name      = 'Posh-Proget'
    }
    proget      = @{
        server     = 'http://proget.gilman.io:8624'
        port       = '8624'
        file_name  = 'proget.zip'
        executable = 'hub.exe'
        feeds      = @{
            bootstrap  = @{ 
                Name        = 'bootstrap'
                FeedType    = 'asset'
                Description = 'Chocolatey bootstrap files'
                Active      = $true
            }
            chocolatey = @{
                Name        = 'internal-chocolatey'
                FeedType    = 'chocolatey'
                Description = 'Internal Chocolatey feed for hosting programs'
                Active      = $true
            }
            powershell = @{
                Name        = 'internal-powershell'
                FeedType    = 'powershell'
                Description = 'Internal Powershell feed for hosting modules'
                Active      = $true
            }
        }
        api        = @{
            feeds_endpoint = '/api/management/feeds/'
        }
    }
    provider    = @{
        name      = 'nuget'
        file_name = 'provider.zip'
        version   = '2.8.5.201'
        path      = 'PackageManagement\ProviderAssemblies'
    }
    sql         = @{
        file_name  = 'sql.zip'
        executable = 'SETUP.EXE'
    }
}