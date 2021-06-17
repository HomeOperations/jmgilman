@{
    name        = 'git'
    installer   = @{
        scriptPath      = 'tools'
        installerPath   = 'tools\Git-2.31.1-32-bit.exe'
        installerPath64 = 'tools\Git-2.31.1-64-bit.exe'
        installerType   = 'exe'
        flags           = '/VERYSILENT /NORESTART'
        argumentPrefix  = '/'
        arguments       = @{
            InstallAllUsers = '1'
        }
    }
    remoteFiles = @(
        @{
            url        = 'https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-32-bit.exe'
            sha1       = '71B137637A4D057D53C93AEA23DCD8710850FA78'
            importPath = 'tools/Git-2.31.1-32-bit.exe'
        }
        @{
            url        = 'https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe'
            sha1       = '538B338F01E723D4452725B1874164117F98650C'
            importPath = 'tools/Git-2.31.1-64-bit.exe'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = 'git'
            title                    = 'Git for Windows'
            version                  = '2.31.1'
            authors                  = 'Git for Windows'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Git for Windows'
            description              = 'Git for Windows focuses on offering a lightweight, native set of tools that bring the full feature set of the Git SCM to Windows while providing appropriate user interfaces for experienced Git users and novices alike.'
            projectUrl               = 'https://gitforwindows.org/index.html'
            packageSourceUrl         = 'https://dev.azure.com/GilmanLab/Lab/_git/Packages'
            tags                     = 'git windows'
            copyright                = '2021 Git for Windows'
            licenseUrl               = 'https://github.com/git-for-windows/build-extra/blob/main/ReleaseNotes.md#licenses'
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