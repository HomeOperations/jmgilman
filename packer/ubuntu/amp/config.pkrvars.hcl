ansible_playbook = "amp/playbook.yml"

network = {
    address = "192.168.1.80/24"
    gateway = "192.168.1.1"
}

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
    network = "Prod"
}