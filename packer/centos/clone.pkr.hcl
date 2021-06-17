variable "vsphere_username" {
    type = string
}

variable "vsphere_password" {
    type = string
    sensitive = true
}

variable "admin_password" {
    type = string
    sensitive = true
}

variable "ansible_playbook" {
    type = string
}

variable "vsphere_server" {
    type = object({
        address = string
        insecure = bool
    })
}

variable "vsphere_vcenter" {
    type = object({
        datacenter = string
        cluster = string
        datastore = string
    })
}

variable "vsphere_vm" {
    type = object({
        name = string
        hostname = string
        domain = string
        template = string
        cpus = number
        memory = number
        disks = list(object({
            size = number
            thin = bool
        }))
        network = string
    })
}

source "vsphere-clone" "clone_base" {
  vcenter_server      = var.vsphere_server.address
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = var.vsphere_server.insecure

  datacenter = var.vsphere_vcenter.datacenter
  cluster    = var.vsphere_vcenter.cluster
  datastore  = var.vsphere_vcenter.datastore

  communicator   = "ssh"
  ssh_username = "admin"
  ssh_password = var.admin_password

  vm_name = var.vsphere_vm.name
  template = var.vsphere_vm.template
  network = var.vsphere_vm.network
  CPUs    = var.vsphere_vm.cpus
  RAM     = var.vsphere_vm.memory
  convert_to_template = true

  customize {
      linux_options {
          host_name = var.vsphere_vm.hostname
          domain = var.vsphere_vm.domain
      }
      network_interface {

      }
  }

  disk_controller_type = ["pvscsi"]
  dynamic "storage" {
      for_each = var.vsphere_vm.disks
      content {
          disk_size = storage.value.size
          disk_thin_provisioned = storage.value.thin
      }
  }
}

build {
  sources = ["source.vsphere-clone.clone_base"]

  provisioner "ansible" {
      playbook_file = var.ansible_playbook
      user = "admin"
  }
}