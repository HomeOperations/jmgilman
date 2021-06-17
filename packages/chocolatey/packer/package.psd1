@{
    name          = 'packer'
    processScript = 'process.ps1'
    shim          = $true
    remoteFiles   = @(
        @{
            url        = 'https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_windows_amd64.zip'
            sha1       = 'AFCAA6323BE9403C50329D040CFE16165B51DD76'
            importPath = 'tools/packer_1.7.2_windows_amd64.zip'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'packer'
            title                    = 'Packer'
            version                  = '1.7.2'
            authors                  = 'Hashicorp'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Packer CLI tool'
            description              = 'HashiCorp Packer automates the creation of any type of machine image. It embraces modern configuration management by encouraging you to use automated scripts to install and configure the software within your Packer-made images.'
            projectUrl               = 'https://www.packer.io/'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'hashicorp packer'
            copyright                = '2021 Hashicorp'
            licenseUrl               = 'https://github.com/hashicorp/packer/blob/master/LICENSE'
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