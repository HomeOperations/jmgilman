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

// Groups and Tags //

// Consul
resource "vsphere_tag_category" "consul" {
  name        = "Consul"
  description = "Consul"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "consul_client" {
  name        = "Client"
  category_id = "${vsphere_tag_category.consul.id}"
  description = "Consul clients"
}

resource "vsphere_tag" "consul_server" {
  name        = "Server"
  category_id = "${vsphere_tag_category.consul.id}"
  description = "Consul servers"
}

// Nomad
resource "vsphere_tag_category" "nomad" {
  name        = "Nomad"
  description = "Nomad"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "nomad_client" {
  name        = "Client"
  category_id = "${vsphere_tag_category.nomad.id}"
  description = "Nomad clients"
}

resource "vsphere_tag" "nomad_server" {
  name        = "Server"
  category_id = "${vsphere_tag_category.nomad.id}"
  description = "Nomad servers"
}

// Vault
resource "vsphere_tag_category" "vault" {
  name        = "Vault"
  description = "Vault"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "vault_server" {
  name        = "Server"
  category_id = "${vsphere_tag_category.vault.id}"
  description = "Vault servers"
}