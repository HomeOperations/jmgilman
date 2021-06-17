@{
    name        = 'azure-agent'
    localFiles  = @(
        @{
            localPath  = 'files/ChocolateyInstall.ps1'
            importPath = 'tools/ChocolateyInstall.ps1'
        }
    )
    remoteFiles = @(
        @{
            url        = 'https://vstsagentpackage.azureedge.net/agent/2.186.1/vsts-agent-win-x64-2.186.1.zip'
            sha1       = '26F7E9B149F1B4288B459D92397F94516F73D0CA'
            importPath = 'tools/vsts-agent-win-x64-2.186.1.zip'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = 'azure-agent'
            title                    = 'Microsoft Azure Agent files'
            version                  = '2.186.1'
            authors                  = 'Microsoft'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Microsoft Azure Agent files'
            description              = 'Provides the required files for installing an Azure agent on a Windows machine and optionally configures and enables the agent'
            projectUrl               = 'https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'azure devops agent microsoft'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://github.com/microsoft/azure-pipelines-agent/blob/master/LICENSE'
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