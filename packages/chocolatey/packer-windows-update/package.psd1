@{
    name          = 'packer-windows-update'
    processScript = 'process.ps1'
    shim          = $true
    remoteFiles   = @(
        @{
            url        = 'https://github.com/rgl/packer-plugin-windows-update/releases/download/v0.12.0/packer-plugin-windows-update_v0.12.0_x5.0_windows_amd64.zip'
            sha1       = '19DEA6918C5848665D4F05B7E5B9CC738F3F1258'
            importPath = 'tools/packer-plugin-windows-update_v0.12.0_x5.0_windows_amd64.zip'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'packer-windows-update'
            title                    = 'Packer Windows Update Plugin'
            version                  = '0.12.0'
            authors                  = 'Rui Lopes'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Packer Windows Update Plugin'
            description              = 'This is a Packer plugin for installing Windows updates '
            projectUrl               = 'https://github.com/rgl/packer-plugin-windows-update'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'hashicorp packer windows update microsoft'
            copyright                = '2021 Rui Lopes'
            licenseUrl               = 'https://github.com/rgl/packer-plugin-windows-update/blob/master/LICENSE.txt'
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