ansible_playbook = "cntos8/playbook.yml"

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
    name = "CNTOS8"
    cpus = 4
    memory = 8192
    os = "centos64Guest"
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
        command = [
            "<tab><bs><bs><bs><bs><bs>",
            "text ks=http://ipxe.gilman.io/centos/ks.cfg",
            "<enter><wait>",
        ]
        wait = "5s"
    }
    iso_paths = [
        "[Lab] iso/CentOS-8.3.2011-x86_64-dvd11.iso"
    ]
    http_dir = "cntos8"
}

ssh = {
    username = "admin"
    password = "GlabT3mp!"
}