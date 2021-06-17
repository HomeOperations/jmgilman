ansible_playbook = "amp/playbook.yml"

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
    name = "Amp"
    hostname = "amp"
    domain = "gilman.io"
    template = "UB2004"
    cpus = 8
    memory = 16384
    disks = [
        {
            size = 81920
            thin = true
        }
    ]
    network = "Dev"
}