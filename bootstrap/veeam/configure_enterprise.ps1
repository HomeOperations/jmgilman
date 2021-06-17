$ENDPOINTS = @{
    login              = '/api/sessionMngr/?v=latest'
    createBackupServer = '/api/backupServers?action=create'
}

Function Join-Uri {
    param(
        [string] $BaseUri,
        [string] $RelativeUri
    )

    (New-Object -TypeName 'System.Uri' -ArgumentList ([System.Uri]$BaseUri), $RelativeUri).AbsoluteUri
}

Function New-VEMSession {
    param(
        [string] $Address,
        [string] $Username,
        [string] $Password
    )

    $authStr = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $Username, $Password)))
    $headers = @{
        Authorization = ('Basic {0}' -f $authStr)
    }
    $params = @{
        Method      = 'POST'
        Uri         = Join-Uri $Address $ENDPOINTS.login
        ContentType = 'application/json'
        Headers     = $headers
    }
    
    $res = Invoke-WebRequest @params -UseBasicParsing
    [PSCustomObject]@{
        Address   = $Address
        Username  = $Username
        SessionId = $res.Headers['X-RestSvcSessionId']
    }
}

Function Invoke-VEMApi {
    param(
        [object] $Session,
        [string] $Endpoint,
        [string] $Method = 'GET',
        [object] $Data = @{}
    )

    $headers = @{
        'X-RestSvcSessionId' = $Session.SessionId
    }
    $params = @{
        Method      = $Method
        Uri         = Join-Uri $Session.Address $Endpoint
        ContentType = 'application/json'
        Headers     = $headers
    }

    if ($Data.Count) {
        $params.Add('Body', (ConvertTo-Json $Data -Depth 3))
    }

    Invoke-RestMethod @params
}

$requiredEnvVars = @(
    'VEEAM_ENT_API'
    'VEEAM_USERNAME'
    'VEEAM_PASSWORD'
    'VEEAM_SERVER'
)

$ErrorActionPreference = 'Stop'

foreach ($var in $requiredEnvVars) {
    if (!(Test-Path ('env:{0}' -f $var))) {
        throw ('You must provide the {0} environment variable' -f $var)
    }
}

# This is a nasty hack to enable using self-signed certificates
if (-not('dummy' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }

    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
'@
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()

Write-Host 'Authenticating to API...'
$ses = New-VEMSession `
    -Address $env:VEEAM_ENT_API `
    -Username $env:VEEAM_USERNAME `
    -Password $env:VEEAM_PASSWORD

Write-Host 'Registering VBR server...'
$data = @{
    description        = 'Backup server'
    DnsNameOrIpAddress = $env:VEEAM_SERVER
    Port               = '9392'
    Username           = $env:VEEAM_USERNAME
    Password           = $env:VEEAM_PASSWORD
}
Invoke-VEMApi -Session $ses -Endpoint $ENDPOINTS.createBackupServer -Method 'POST' -Data $data