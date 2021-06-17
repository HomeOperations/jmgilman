# Don't let the script continue with errors
$ErrorActionPreference = 'Stop'

$CONFIG = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'config.psd1')

# Create temporary directory
$temp_dir = New-Item -ItemType Directory -Path (Join-Path 'Temp:/' (New-Guid))

# Clone repository
$git_args = @('clone', $CONFIG.netboot.repo, $temp_dir.FullName)
Start-Process 'git' -ArgumentList $git_args -PassThru -Wait

# Copy overrides
New-Item -ItemType Directory -Path (Join-Path $temp_dir.FullName 'custom')
Copy-Item (Join-Path $PSScriptRoot 'pxe/user_overrides.yml') $temp_dir.FullName
Copy-Item (Join-Path $PSScriptRoot 'pxe/custom/*') (Join-Path $temp_dir.FullName 'custom')

# Build docker image
$docker_build_args = @(
    'build',
    '-t',
    'localbuild',
    '-f',
    (Join-Path $temp_dir.FullName 'Dockerfile-build'),
    $temp_dir.FullName
)
Start-Process 'docker' -ArgumentList $docker_build_args -PassThru -Wait

# Generate site
$docker_run_args = @(
    'run',
    '--rm',
    '-it',
    '-v',
    "$($temp_dir.FullName):/buildout",
    'localbuild'
)
Start-Process 'docker' -ArgumentList $docker_run_args -Wait

# Copy generated files
$nas_pxe_path = $CONFIG.nas.address + ':' + $CONFIG.nas.pxe_path
$nas_tftp_path = $CONFIG.nas.address + ':' + $CONFIG.nas.tftp_path

$buildout_path = Join-Path $temp_dir.FullName 'buildout/*'
$custom_path = Join-Path $temp_dir.FullName 'buildout/custom'
$ipxe_path = Join-Path $temp_dir.FullName 'buildout/ipxe/*'
$esxi_path = Join-Path $PSScriptRoot 'pxe/esxi'

& scp $buildout_path $nas_pxe_path
& scp -r $custom_path $nas_pxe_path
& scp $ipxe_path $nas_tftp_path
& scp -r $esxi_path $nas_pxe_path