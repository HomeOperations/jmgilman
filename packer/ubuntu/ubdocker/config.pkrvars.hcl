ansible_playbook = "ubdocker/playbook.yml"

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
    name = "UBDocker"
    hostname = "ubdocker"
    domain = "gilman.io"
    template = "UB2004"
    cpus = 4
    memory = 8192
    disks = [
        {
            size = 20480
            thin = true
        },
        {
            size = 20480
            thin = true
        },
        {
            size = 20480
            thin = true
        }
    ]
    network = "Dev"
}