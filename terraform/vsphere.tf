data "vsphere_datacenter" "datacenter" {
  name = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
}

data "vsphere_compute_cluster" "cluster" {
  name          = jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_custom_attribute" "consul_policies" {
  name                = "consul_policies"
  managed_object_type = "VirtualMachine"
}