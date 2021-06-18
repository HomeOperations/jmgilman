data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "disk_datastore" {
  count         = var.disk_datastore != "" ? 1 : 0
  name          = var.disk_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  count         = length(var.nics)
  name          = var.nics[count.index].network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_tag_category" "category" {
  count = var.tags != null ? length(var.tags) : 0
  name  = keys(var.tags)[count.index]
}

data "vsphere_tag" "tag" {
  count       = var.tags != null ? length(var.tags) : 0
  name        = var.tags[keys(var.tags)[count.index]]
  category_id = data.vsphere_tag_category.category[count.index].id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vm_folder
  tags             = data.vsphere_tag.tag[*].id
  custom_attributes       = var.custom_attributes
  enable_disk_uuid = true

  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus     = var.cpu
  memory       = var.memory
  guest_id     = data.vsphere_virtual_machine.template.guest_id
  scsi_type    = data.vsphere_virtual_machine.template.scsi_type
  scsi_controller_count = max(
    max(0, flatten([
      for item in values(var.data_disk) : [
        for elem, val in item :
        elem == "data_disk_scsi_controller" ? val : 0
    ]])...) + 1,
    ceil((max(0, flatten([
      for item in values(var.data_disk) : [
        for elem, val in item :
        elem == "unit_number" ? val : 0
  ]])...) + 1) / 15), 0)

  dynamic "network_interface" {
    for_each = var.nics
    content {
      network_id   = data.vsphere_network.network[network_interface.key].id
      adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
  }

  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks
    content {
      label            = length(var.disk_label) > 0 ? var.disk_label[template_disks.key] : "disk${template_disks.key}"
      size             = var.disk_size_gb != null ? var.disk_size_gb[template_disks.key] : data.vsphere_virtual_machine.template.disks[template_disks.key].size
      unit_number      = template_disks.key
      thin_provisioned = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
      datastore_id     = var.disk_datastore != "" ? data.vsphere_datastore.disk_datastore[0].id : null
    }
  }

  dynamic "disk" {
    for_each = var.data_disk
    iterator = terraform_disks
    content {
      label = terraform_disks.key
      size  = lookup(terraform_disks.value, "size_gb", null)
      unit_number = (
        lookup(
          terraform_disks.value,
          "unit_number",
          -1
          ) < 0 ? (
          lookup(
            terraform_disks.value,
            "data_disk_scsi_controller",
            0
            ) > 0 ? (
            (terraform_disks.value.data_disk_scsi_controller * 15) +
            index(keys(var.data_disk), terraform_disks.key) +
            (var.scsi_controller == tonumber(terraform_disks.value["data_disk_scsi_controller"]) ? local.template_disk_count : 0)
            ) : (
            index(keys(var.data_disk), terraform_disks.key) + local.template_disk_count
          )
          ) : (
          tonumber(terraform_disks.value["unit_number"])
        )
      )
      thin_provisioned  = lookup(terraform_disks.value, "thin_provisioned", "true")
      eagerly_scrub     = lookup(terraform_disks.value, "eagerly_scrub", "false")
      datastore_id      = lookup(terraform_disks.value, "datastore_id", null)
      storage_policy_id = lookup(terraform_disks.value, "storage_policy_id", null)
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata" = base64encode(templatefile(
      "${path.module}/templates/metadata.yml",
      {
        hostname = var.vm_name
        nics = var.nics
        dns = var.dns
        domains = var.domains
      }
    ))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(var.script)
    "guestinfo.userdata.encoding" = "base64"
  }
}
