ansible_playbook = "ubhashi/playbook.yml"

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
    name = "UBHashi"
    hostname = "ubhashi"
    template = "UB2004"
    cpus = 4
    memory = 4192
    disks = []
    network = "Dev"
}