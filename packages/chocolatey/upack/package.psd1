@{
    name          = 'upack'
    processScript = ''
    shim          = $True
    remoteFiles   = @(
        @{
            url        = 'https://github.com/Inedo/upack/releases/download/upack-2.3.0.6/upack.exe'
            sha1       = ''
            importPath = 'tools/upack.exe'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'upack'
            title                    = 'UPack'
            version                  = '2.3.0'
            authors                  = 'Indeo'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Indeo UPack CLI tool'
            description              = 'UPack is a technology-neutral packaging platform that allows you to uniformly distribute your applications and components across environments to enable consistent deployment and testing.'
            projectUrl               = 'https://github.com/Inedo/upack'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'upack inedo'
            copyright                = '2021 Indeo'
            licenseUrl               = 'https://github.com/Inedo/upack/blob/master/LICENSE'
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