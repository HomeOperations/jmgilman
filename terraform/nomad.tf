module "nomad_servers" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["servers"]
  source           = "Terraform-VMWare-Modules/vm/vsphere"
  version          = "3.0.0"
  dc               = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
  datastore        = jsondecode(data.consul_keys.vsphere.var.vcenter)["iscsi"]["name"]
  vmtemp           = "UB2004"
  staticvmname           = each.key
  vmrp             = "${jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]}/Resources"
  enable_disk_uuid = true
  network = {
    Prod = [each.value.networking.ip]
  }
  custom_attributes = {"${vsphere_custom_attribute.consul_policies.id}" = jsonencode(each.value.consul.roles)}
  tags = {
    "Consul" = "Server"
    "Nomad" = "Server"
  }
  domain          = jsondecode(data.consul_keys.dns.var.dns)["domain"]
  dns_server_list = [jsondecode(data.consul_keys.dns.var.dns)["server"]]
  vmgateway       = each.value.networking.gateway
  data_disk = {}
}

module "nomad_clients" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["clients"]
  source           = "Terraform-VMWare-Modules/vm/vsphere"
  version          = "3.0.0"
  dc               = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
  datastore        = jsondecode(data.consul_keys.vsphere.var.vcenter)["iscsi"]["name"]
  vmtemp           = "UBDocker"
  staticvmname           = each.key
  vmrp             = "${jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]}/Resources"
  enable_disk_uuid = true
  network = {
    Prod = [each.value.networking.ip]
  }
  custom_attributes = {"${vsphere_custom_attribute.consul_policies.id}" = jsonencode(each.value.consul.roles)}
  tags = {
    "Consul" = "Client"
    "Nomad" = "Client"
  }
  domain          = jsondecode(data.consul_keys.dns.var.dns)["domain"]
  dns_server_list = [jsondecode(data.consul_keys.dns.var.dns)["server"]]
  vmgateway       = each.value.networking.gateway
  data_disk = {}
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "nomad_servers_anti_affinity_rule" {
  name                = "nomad_servers"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = values(module.nomad_servers)[*].uuid[0]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "nomad_clients_anti_affinity_rule" {
  name                = "nomad_clients"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = values(module.nomad_clients)[*].uuid[0]
}