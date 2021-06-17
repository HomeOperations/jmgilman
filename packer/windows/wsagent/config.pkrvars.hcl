ansible_playbook = "wsagent/playbook.yml"

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
    name = "WSAgent"
    template = "WS2016Core"
    cpus = 4
    memory = 8192
    disks = [
        {
            size = 40960
            thin = true
        }
    ]
    network = "Dev"
}

vsphere_media = {
    floppy_files = [
        "scripts/enable-winrm.ps1"
    ]
    sysprep = "wsagent/sysprep.xml"
}

winrm = {
    username = "Administrator"
    password = "GlabT3mp!"
}