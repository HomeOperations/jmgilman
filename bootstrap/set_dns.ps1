<#
.Synopsis
   Adds the given DNS A records to the desired DNS zone
.DESCRIPTION
   This script is intended to be run by a machine deployed within glab and is
   primarily used to bootstrap the glab domain with the necessary DNS records.
.EXAMPLE
   .\set_dns.ps1 -ComputerName DC00 -ZoneName my.domain -RecordsFile .\dns\records.psd1
.NOTES
    Name: set_dns.ps1
    Author: Joshua Gilman (@jmgilman)
#>

# Parameters
param(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1
    )]
    [string]  $ComputerName,
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 2
    )]
    [string]  $ZoneName,
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 3
    )]
    [string]  $RecordsFile
)

# Don't let the script continue with errors
$ErrorActionPreference = 'Stop'

# Update A records
$records = Import-PowerShellDataFile $RecordsFile
$all_res = Get-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName
foreach ($record in $Records.GetEnumerator()) {
    $res = $all_res | Where-Object HostName -EQ $record.Name
    if (!$res) {
        Write-Verbose "Adding record for $($record.Name)"
        Add-DnsServerResourceRecordA -ComputerName $ComputerName -ZoneName $ZoneName -Name $record.Name -IPv4Address $record.Value
    }
}