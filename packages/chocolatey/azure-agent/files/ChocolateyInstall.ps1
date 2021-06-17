$filePath = 'tools/vsts-agent-win-x64-2.186.1.zip'

$arguments = @{
    INSTALL_DIR               = 'C:\agent' # Path where agent files will be installed
    CONFIGURE                 = 'no' # automatically configure the agent - yes/no
    URL                       = '' # URL of the server
    RESTART                   = 'no' # allow the agent to restart the machine after configuration
    AUTH_METHOD               = 'pat' # authentication method to use for configuration - pat/negotiate/alt/integrated
    AUTH_TOKEN                = '' # PAT to use for authentication, only applicable if AUTH_METHOD is 'pat'
    AUTH_USERNAME             = '' # username to use for authentication, only applicable if AUTH_METHOD is 'negotitate' or 'alt'
    AUTH_PASSWORD             = ''# password to use for authentication, only applicable if AUTH_METHOD is 'negotitate' or 'alt'
    AGENT_POOL                = 'default' # pool name for the agent to join
    AGENT_NAME                = 'default-agent' # agent name
    AGENT_REPLACE             = 'no' # replace the agent in a pool. If another agent is listening by the same name, it will start failing with a conflict
    AGENT_WORK_DIR            = '' # work directory location for the agent
    AGENT_LOG_DISABLE         = 'no' # don't stream or send console log output to the server
    SERVICE_ENABLED           = 'no' # configure the agent to run as a Windows service (requires administrator permission)
    SERVICE_AUTO_LOGON        = 'no' # configure auto-logon and run the agent on startup (requires administrator permission)
    SERVICE_ACCOUNT_NAME      = '' # windows account name to run the service with
    SERVICE_ACCOUNT_PASSWORD  = '' # password for the windows service account
    SERVICE_OVERWRITE_LOGON   = 'no' # used with SERVICE_AUTO_LOGON to overwrite the existing auto logon on the machine
    DEPLOYMENT_GROUP          = 'no' # configure the agent as a deployment group agent
    DEPLOYMENT_GROUP_NAME     = '' # specify the deployment group for the agent to join
    DEPLOYMENT_GROUP_PROJECT  = '' # set the deployment group project name
    DEPLOYMENT_GROUP_ADD_TAGS = 'no' # deployment group tags should be added
    DEPLOYMENT_GROUP_TAGS     = '' # comma separated list of tags for the deployment group agent
    ENV_ADD_TAGS              = 'no' # environment resource tags should be added
    ENV_TAGS                  = '' # comma separated list of tags for the environment resource agent
}

$argument_flag_map = @{
    URL                       = 'url'
    RESTART                   = 'noRestart'
    AUTH_METHOD               = 'auth'
    AUTH_TOKEN                = 'token'
    AUTH_USERNAME             = 'userName'
    AUTH_PASSWORD             = 'password'
    AGENT_POOL                = 'pool'
    AGENT_NAME                = 'agent'
    AGENT_REPLACE             = 'replace'
    AGENT_WORK_DIR            = 'work'
    AGENT_LOG_DISABLE         = 'disableloguploads'
    SERVICE_ENABLED           = 'runAsService'
    SERVICE_AUTO_LOGON        = 'runAsAutoLogon'
    SERVICE_ACCOUNT_NAME      = 'windowsLogonAccount'
    SERVICE_ACCOUNT_PASSWORD  = 'windowsLogonPassword'
    DEPLOYMENT_GROUP          = 'deploymentGroup'
    DEPLOYMENT_GROUP_NAME     = 'deploymentGroupName'
    DEPLOYMENT_GROUP_PROJECT  = 'projectName'
    DEPLOYMENT_GROUP_ADD_TAGS = 'addDeploymentGroupTags'
    DEPLOYMENT_GROUP_TAGS     = 'deploymentGroupTags'
    ENV_ADD_TAGS              = 'addvirtualmachineresourcetags'
    ENV_TAGS                  = 'virtualmachineresourcetags'
}

$params = Get-PackageParameters
Write-Verbose ('Received {0} parameters from user' -f $params.Count)
Write-Verbose ('This package supports {0} arguments' -f $arguments.Count)
if (Get-Command ConvertTo-Json -ErrorAction SilentlyContinue) {
    Write-Verbose ('Parameters passed: {0}' -f (ConvertTo-Json $params -ErrorAction SilentlyContinue))
}

# Build arguments
if (($params.Count -gt 0) -and ($arguments.Count -eq 0)) {
    Write-Warning 'Parameters were given but this package does not take any parameters'
}
elseif (($params.Count -gt 0) -and ($arguments.Count -gt 0)) {
    foreach ($param in $params.GetEnumerator()) {
        if (!($param.Name -in $arguments.Keys)) {
            Write-Warning ('This package does not have a {0} parameter' -f $param.Name)
            continue
        }

        $arguments[$param.Name] = $param.Value
    }
}

if (Get-Command ConvertTo-Json -ErrorAction SilentlyContinue) {
    Write-Verbose ('Final package arguments: {0}' -f (ConvertTo-Json $arguments -ErrorAction SilentlyContinue))
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packageDir = Split-Path -Parent $scriptDir
$fileLocation = Join-Path $packageDir $filePath
$fileLocation = (Get-Item $fileLocation).FullName # Resolve relative paths
Write-Verbose ('Using agent archive at {0}' -f $fileLocation)
Write-Verbose ('Package directory is {0}' -f $packageDir)

Write-Host ('Creating agent files at {0}...' -f $arguments.INSTALL_DIR)
Get-ChocolateyUnzip -FileFullPath $fileLocation -Destination $arguments.INSTALL_DIR

if ($arguments.CONFIGURE -eq 'yes') {
    # Build CLI argument string
    $config_script = Join-Path $arguments.INSTALL_DIR 'config.cmd'
    $arguments.Remove('CONFIGURE')
    $arguments.Remove('INSTALL_DIR')

    $argument_list = [System.Collections.ArrayList]@('--unattended')
    foreach ($argument in $arguments.GetEnumerator()) {
        $flag = $argument_flag_map[$argument.Name]
        if (($argument.Value) -and ($argument.Value -ne 'no')) {
            if ($argument.Value -eq 'yes') {
                $argument_list.Add(('--{0}' -f $flag)) | Out-Null
            }
            else {
                $argument_list.Add(('--{0} "{1}"' -f $flag, $argument.Value)) | Out-Null
            }
        }
    }

    # Run configuration
    $arg_string = $argument_list -join ' '
    Write-Verbose ('Executing the configuration script at {0}' -f $config_script)
    Write-Verbose ('Using the following arguments: {0}' -f $arg_string)
    Write-Host 'Configuring agent...'

    $statement = '/c "{0} {1}"' -f $config_script, $arg_string
    Start-ChocolateyProcessAsAdmin -Statements $statement -ExeToRun 'cmd.exe'
}
