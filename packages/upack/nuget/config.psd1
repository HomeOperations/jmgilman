CONFIG = @{
    name     = 'nuget'
    version  = '5.9.1'
    type     = 'upack'
    files    = @(
        @{
            name = 'nuget.exe'
            url  = 'https://dist.nuget.org/win-x86-commandline/v5.9.1/nuget.exe'
        },
        @{
            name = 'Microsoft.PackageManagement.NuGetProvider.dll'
            url  = 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll'
        }
    )
    manifest = @{
        name        = 'NuGet'
        version     = '5.9.1'
        title       = 'NuGet'
        description = 'Contains nuget.exe and the associated PSGet provider'
    }
}