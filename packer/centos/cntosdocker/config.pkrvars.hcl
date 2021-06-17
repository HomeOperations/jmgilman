ansible_playbook = "docker/playbook.yml"

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
    name = "CNTOSDocker"
    hostname = "cntosdocker"
    domain = "gilman.io"
    template = "CNTOS8"
    cpus = 4
    memory = 8192
    disks = []
    network = "Dev"
}