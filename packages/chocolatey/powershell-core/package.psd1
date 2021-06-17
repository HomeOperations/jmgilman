@{
    name          = 'powershell-core'
    processScript = 'process.ps1'
    localFiles    = @(
        @{
            localPath  = 'files/ChocolateyInstall.ps1'
            importPath = 'tools/ChocolateyInstall.ps1'
        }
    )
    remoteFiles   = @(
        @{
            url        = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi'
            sha1       = ''
            importPath = 'tools/PowerShell-7.1.3-win-x64.msi'
        }
        @{
            url        = 'https://dist.nuget.org/win-x86-commandline/v5.9.1/nuget.exe'
            sha1       = ''
            importPath = 'tools/nuget.exe'
        }
        @{
            url        = 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll'
            sha1       = ''
            importPath = 'tools/Microsoft.PackageManagement.NuGetProvider.dll'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'powershell-core'
            title                    = 'Powershell Core'
            version                  = '7.1.3'
            authors                  = 'Microsoft'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Powershell Core'
            description              = 'PowerShell Core is a cross-platform (Windows, Linux, and macOS) automation and configuration tool/framework that works well with your existing tools and is optimized for dealing with structured data (e.g. JSON, CSV, XML, etc.), REST APIs, and object models. It includes a command-line shell, an associated scripting language and a framework for processing cmdlets.'
            projectUrl               = 'https://github.com/PowerShell/PowerShell'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'powershell core'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://github.com/PowerShell/PowerShellGet/blob/development/LICENSE'
            requireLicenseAcceptance = 'false'
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}