vsphere_server = {
    address = "vcenter.gilman.io"
    insecure = true
}

vsphere_vcenter = {
    datacenter = "Gilman"
    cluster = "Lab"
    datastore = "iSCSI"
}

vsphere_vm = {
    name = "WD10"
    cpus = 4
    memory = 8192
    os = "windows9_64Guest"
    firmware = "efi"
    disks = [
        {
            size = 40960
            thin = true
        }
    ]
    networks = [
        {
            name = "Dev"
            type = "vmxnet3"
        }
    ]
}

vsphere_media = {
    boot = {
        command = ["a<enter><wait>a<enter><wait>a<enter><wait>a<enter>"]
        wait = "-1s"
    }
    iso_paths = [
        "[Lab] iso/en_windows_10_consumer_editions_version_20h2_updated_march_2021_x64_dvd_68a3fcec.iso",
        "[] /vmimages/tools-isoimages/windows.iso"
    ]
    floppy_files = [
        "wd10/autounattend.xml",
        "scripts/install-vm-tools.ps1",
        "scripts/enable-winrm-wd10.ps1"
    ]
}

winrm = {
    username = "Administrator"
    password = "GlabT3mp!"
}