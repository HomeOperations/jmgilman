@{
    name        = 'iis-url-rewrite'
    installer   = @{
        scriptPath      = 'tools'
        installerPath   = 'tools/rewrite_x86_en-US.msi'
        installerPath64 = 'tools/rewrite_amd64_en-US.msi'
        installerType   = 'msi'
        exitCodes       = @(0, 1641, 3010)
        flags           = '/qn /norestart'
    }
    remoteFiles = @(
        @{
            url        = 'https://download.microsoft.com/download/D/8/1/D81E5DD6-1ABB-46B0-9B4B-21894E18B77F/rewrite_x86_en-US.msi'
            sha1       = '4EFCC6C95B20B0A842C78CFA7781B17D9165EC9E'
            importPath = 'tools/rewrite_x86_en-US.msi'
        }
        @{
            url        = 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi'
            sha1       = '8F41A67FA49110155969DCCFF265B8623A66448F'
            importPath = 'tools/rewrite_amd64_en-US.msi'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = 'iis-url-rewrite'
            title                    = 'URL Rewrite'
            version                  = '2.1.0'
            authors                  = 'Microsoft'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs URL Rewrite for IIS'
            description              = 'IIS URL Rewrite 2.1 enables Web administrators to create powerful rules to implement URLs that are easier for users to remember and easier for search engines to find'
            projectUrl               = 'https://www.iis.net/downloads/microsoft/url-rewrite'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'IIS url rewrite'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://www.iis.net/community/files/EULA/URL_REWRITE_RTW.html'
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