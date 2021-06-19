ansible_playbook = "nomad/playbook.yml"

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
    name = "UBNomad"
    hostname = "ubnomad"
    template = "UB2004"
    cpus = 4
    memory = 4192
    disks = []
    network = "Dev"
}