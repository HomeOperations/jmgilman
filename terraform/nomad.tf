module "nomad_servers" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["servers"]
  source             = "./modules/machine"
  datacenter         = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
  datastore          = jsondecode(data.consul_keys.vsphere.var.vcenter)["iscsi"]["name"]
  resource_pool_name = "${jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]}/Resources"
  template_name      = "UB2004"
  vm_name            = each.key
  dns = [jsondecode(data.consul_keys.dns.var.dns)["server"]]
  domains = [jsondecode(data.consul_keys.dns.var.dns)["domain"]]
  nics = [each.value.networking]
  custom_attributes = {"${vsphere_custom_attribute.consul_policies.id}" = jsonencode(each.value.consul.roles)}
  tags = {
    "Consul" = "Server"
    "Nomad" = "Server"
  }
}

module "nomad_clients" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["clients"]
  source             = "./modules/machine"
  datacenter         = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
  datastore          = jsondecode(data.consul_keys.vsphere.var.vcenter)["iscsi"]["name"]
  resource_pool_name = "${jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]}/Resources"
  template_name      = "UBDocker"
  vm_name            = each.key
  dns = [jsondecode(data.consul_keys.dns.var.dns)["server"]]
  domains = [jsondecode(data.consul_keys.dns.var.dns)["domain"]]
  nics = [each.value.networking]
  custom_attributes = {"${vsphere_custom_attribute.consul_policies.id}" = jsonencode(each.value.consul.roles)}
  tags = {
    "Consul" = "Client"
    "Nomad" = "Client"
  }
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "nomad_servers_anti_affinity_rule" {
  name                = "nomad_servers"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = values(module.nomad_servers)[*].uuid[0]
}

// resource "null_resource" "nomad_servers_provisioner" {
//   depends_on = [
//     module.nomad_servers,
//   ]
//   provisioner "local-exec" {
//     command = "sleep 180"
//   }
//   provisioner "local-exec" {
//     command = "ansible-playbook -i ../ansible/inventory/consul.vmware.yml ../ansible/consul_server.yml"
//   }
//   provisioner "local-exec" {
//     command = "ansible-playbook -i ../ansible/inventory/nomad.vmware.yml ../ansible/nomad_server.yml"
//   }
// }

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "nomad_clients_anti_affinity_rule" {
  name                = "nomad_clients"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = values(module.nomad_clients)[*].uuid[0]
}

// resource "null_resource" "nomad_clients_provisioner" {
//   depends_on = [
//     module.nomad_servers,
//     module.nomad_clients,
//     null_resource.nomad_servers_provisioner,
//   ]
//   provisioner "local-exec" {
//     command = "sleep 180"
//   }
//   provisioner "local-exec" {
//     command = "ansible-playbook -i ../ansible/inventory/consul.vmware.yml ../ansible/consul_client.yml"
//   }
//   provisioner "local-exec" {
//     command = "ansible-playbook -i ../ansible/inventory/nomad.vmware.yml ../ansible/nomad_client.yml"
//   }
// }