ansible_playbook = "ub2004/playbook.yml"

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
    name = "UB2004"
    cpus = 4
    memory = 8192
    os = "ubuntu64Guest"
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
            "<enter><enter><f6><esc><wait> ",
            "autoinstall ds=nocloud-net;s=http://ipxe.gilman.io/ubuntu/",
            "<enter>",
        ]
        wait = "5s"
    }
    iso_paths = [
        "[Lab] iso/ubuntu-20.04.2-live-server-amd64.iso"
    ]
    http_dir = "ub2004"
}

ssh = {
    username = "admin"
    password = "GlabT3mp!"
}