param(
    [string] $Name,
    [string] $Token,
    [pscredential] $ServiceAccount
)

$parameters = @{
    CONFIGURE                = 'yes'
    URL                      = 'https://dev.azure.com/GilmanLab'
    AUTH_TOKEN               = $Token
    AGENT_POOL               = 'lab'
    AGENT_NAME               = $Name
    AGENT_REPLACE            = 'yes'
    SERVICE_ENABLED          = 'yes'
    SERVICE_ACCOUNT_NAME     = $ServiceAccount.GetNetworkCredential().UserName
    SERVICE_ACCOUNT_PASSWORD = $ServiceAccount.GetNetworkCredential().Password
}

Import-Module GLab-Posh
Install-ChocolateyPackage -Name azure-agent -Parameters $parameters -Verbose