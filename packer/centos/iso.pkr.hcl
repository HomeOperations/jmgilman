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
        cpus = number
        memory = number
        os = string
        disks = list(object({
            size = number
            thin = bool
        }))
        networks = list(object({
            name = string
            type = string
        }))
    })
}

variable "vsphere_media" {
    type = object({
        boot = object({
            command = list(string)
            wait = string
        })
        iso_paths = list(string)
        http_dir = string
    })
}

variable "ssh" {
    type = object({
        username = string
        password = string
    })
    sensitive = true
}

source "vsphere-iso" "centos_base" {
  vcenter_server      = var.vsphere_server.address
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = var.vsphere_server.insecure

  boot_command = var.vsphere_media.boot.command
  boot_wait = var.vsphere_media.boot.wait

  datacenter = var.vsphere_vcenter.datacenter
  cluster    = var.vsphere_vcenter.cluster
  datastore  = var.vsphere_vcenter.datastore

  iso_paths = var.vsphere_media.iso_paths
  http_directory = var.vsphere_media.http_dir

  convert_to_template = true

  communicator   = "ssh"
  ssh_username = var.ssh.username
  ssh_password = var.ssh.password
  ssh_timeout = "10m"
  ssh_handshake_attempts = 20

  vm_name = var.vsphere_vm.name
  CPUs    = var.vsphere_vm.cpus
  RAM     = var.vsphere_vm.memory

  guest_os_type = var.vsphere_vm.os

  disk_controller_type = ["pvscsi"]
  dynamic "storage" {
      for_each = var.vsphere_vm.disks
      content {
          disk_size = storage.value.size
          disk_thin_provisioned = storage.value.thin
      }
  }

  dynamic "network_adapters" {
      for_each = var.vsphere_vm.networks
      content {
          network = network_adapters.value.name
          network_card = network_adapters.value.type
      }
  }
}

build {
  sources = ["source.vsphere-iso.centos_base"]

  provisioner "ansible" {
      playbook_file = var.ansible_playbook
      user = "admin"
      ansible_env_vars = [
          "ADMIN_PASSWORD=${var.admin_password}"
      ]
  }
}