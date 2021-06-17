ansible_playbook = "ws2016core/playbook.yml"

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
    name = "WS2016Core"
    cpus = 4
    memory = 8192
    os = "windows9Server64Guest"
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
        "[Lab] iso/en_windows_server_2016_updated_feb_2018_x64_dvd_11636692.iso",
        "[] /vmimages/tools-isoimages/windows.iso"
    ]
    floppy_files = [
        "ws2016core/autounattend.xml",
        "scripts/bootstrap.ps1",
        "scripts/enable-winrm.ps1",
        "scripts/install-vm-tools.ps1"
    ]
}

winrm = {
    username = "Administrator"
    password = "GlabT3mp!"
}