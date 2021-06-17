@{
    name          = 'proget'
    processScript = 'process.ps1'
    localFiles    = @(
        @{
            localPath  = 'files/ChocolateyInstall.ps1'
            importPath = 'tools/ChocolateyInstall.ps1'
        }
        @{
            localPath  = 'files/DesktopHub.config'
            importPath = 'tools/DesktopHub.config'
        }
    )
    remoteFiles   = @(
        @{
            url        = 'https://proget.inedo.com/upack/Products/download/InedoReleases/ProGet/5.3.27'
            importPath = 'tools/ProGet-5.3.27.upack'
        }
        @{
            url        = 'https://proget.inedo.com/upack/Products/download/InedoReleases/DesktopHub/1.2.6'
            importPath = 'tools/DesktopHub-1.2.6.upack'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'proget'
            title                    = 'ProGet'
            version                  = '5.3.27'
            authors                  = 'Inedo'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Inedo ProGet server'
            description              = 'ProGet helps you package applications and components so you can ensure your software is built only once, and then deployed consistently across environments. This means everyone can be certain that what goes to production is exactly what was built and tested.'
            projectUrl               = 'https://inedo.com/proget'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'proget inedo repository package'
            copyright                = '2021 Inedo'
            licenseUrl               = 'https://inedo.com/proget/license-agreement'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'sql-express-adv'
                    version = '15.0.2000.5'
                }
            )
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}