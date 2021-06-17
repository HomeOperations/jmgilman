@{
    name          = 'terraform'
    processScript = 'process.ps1'
    shim          = $true
    remoteFiles   = @(
        @{
            url        = 'https://releases.hashicorp.com/terraform/0.15.2/terraform_0.15.2_windows_amd64.zip'
            sha1       = '678696549577D84D17EAFC4016EA11A56125AB65'
            importPath = 'tools/terraform_0.15.2_windows_amd64.zip'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'terraform'
            title                    = 'Terraform'
            version                  = '0.15.2'
            authors                  = 'Hashicorp'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Terraform CLI tool'
            description              = 'Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.'
            projectUrl               = 'https://www.terraform.io/'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'hashicorp terraform'
            copyright                = '2021 Hashicorp'
            licenseUrl               = 'https://github.com/hashicorp/terraform/blob/main/LICENSE'
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