$requiredEnvVars = @(
    'VEEAM_SERVER'
    'ENC_KEY_PASSWORD'
    'NAS_USERNAME'
    'NAS_PASSWORD'
    'NAS_ADDRESS'
    'VCENTER_ADDRESS'
    'VCENTER_USERNAME'
    'VCENTER_PASSWORD'
)

$ErrorActionPreference = 'Stop'
$CONFIG = @{
    repository = @{
        name = 'NAS'
        path = 'nas.gilman.io:/volume1/Backups/Veeam'
    }
    job        = @{
        name = 'VM Backup'
        tag  = 'Backup'
    }
}

foreach ($var in $requiredEnvVars) {
    if (!(Test-Path ('env:{0}' -f $var))) {
        throw ('You must provide the {0} environment variable' -f $var)
    }
}

# Connect to server
Write-Host 'Connecting to VBR server...'
Connect-VBRServer -Server $env:VEEAM_SERVER | Out-Null

# Update applicable servers
Write-Host 'Updating servers...'
$servers = Get-VBRPhysicalHost -UpdateRequired
if ($servers) {
    Update-VBRServerComponent -Component $servers | Out-Null
}

# Add NAS as a backup repository
Write-Host 'Adding backup repository...'
Add-VBRBackupRepository -Name $CONFIG.repository.name -Folder $CONFIG.repository.path -Type Nfs | Out-Null

# Create encryption key
Write-Host 'Creating encryption key'
$enc_password = ConvertTo-SecureString $env:ENC_KEY_PASSWORD -AsPlainText -Force
$enc_key = Add-VBREncryptionKey -Password $enc_password

# Configure config backup job
Write-Host 'Configuring configuration backup...'
$repo = Get-VBRBackupRepository -Name $CONFIG.repository.name
$configWeeklyOptions = New-VBRDailyOptions -DayOfWeek Sunday -Period 23:00
$configWeeklySchedule = New-VBRConfigurationBackupScheduleOptions -Type Daily -DailyOptions $configWeeklyOptions
Set-VBRConfigurationBackupJob `
    -Repository $repo `
    -ScheduleOptions $configWeeklySchedule `
    -RestorePointsToKeep 52 `
    -EnableEncryption `
    -EncryptionKey $enc_key | Out-Null

# Add vCenter server
Write-Host 'Adding vCenter server...'
Add-VBRvCenter `
    -Name $env:VCENTER_ADDRESS `
    -User $env:VCENTER_USERNAME `
    -Password $env:VCENTER_PASSWORD | Out-Null

# Connect to NAS
Write-Host 'Connecting to NAS...'
$nasPassword = ConvertTo-SecureString $env:NAS_PASSWORD -AsPlainText -Force
$nasCred = New-Object System.Management.Automation.PSCredential ($env:NAS_USERNAME, $nasPassword)
New-PSDrive -Name 'NAS' -PSProvider FileSystem -Root $env:NAS_ADDRESS -Credential $nasCred | Out-Null

# Check for existing backup job
$jobPath = Join-Path 'NAS:' ('{0}\{0}.vbm' -f $CONFIG.job.name)
$imported = $false
if (Test-Path $jobPath) {
    # Import existing job
    Write-Host 'Importing existing backup files...'
    Import-VBRbackup -FileName ('{0}/{1}/{1}.vbm' -f $repo.FriendlyPath, $CONFIG.job.name) -Repository $repo | Out-Null
    $imported = $true
}

# Create VM backup job
Write-Host 'Creating backup job...'
$server = Get-VBRServer -Name $env:VCENTER_ADDRESS
$tag = Find-VBRViEntity -Server $server -Tags -Name $CONFIG.job.tag
$job = Add-VBRViBackupJob -Name $CONFIG.job.name -BackupRepository $repo -Entity $tag

# Configure job settings
$retention = New-VBRJobOptions -ForBackupJob
$retention.BackupStorageOptions.RetainCycles = 14
$retention.BackupStorageOptions.EnableFullBackup = $true
$retention.BackupTargetOptions.FullBackupDays = 'Sunday'

$retention.GfsPolicy.IsEnabled = $true
$retention.GfsPolicy.Weekly.IsEnabled = $true
$retention.GfsPolicy.Weekly.KeepBackupsForNumberOfWeeks = 12
$retention.GfsPolicy.Monthly.IsEnabled = $true
$retention.GfsPolicy.Monthly.KeepBackupsForNumberOfMonths = 12

Set-VBRJobOptions -Job $job -Options $retention | Out-Null

# Set job schedule
Set-VBRJobSchedule -Job $job -Daily -At '23:30' -DailyKind Everyday | Out-Null
Enable-VBRJobSchedule -Job $job | Out-Null

if ($imported) {
    Write-Host 'Mapping job to existing backup files...'
    $backup = Get-VBRBackup -Name $CONFIG.job.name
    $backup.Update($job)
}