ansible_playbook = "ubagent/playbook.yml"

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
    name = "UBAgent"
    hostname = "ubtest"
    domain = "gilman.io"
    template = "UB2004"
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