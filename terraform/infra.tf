locals {
  hashi_server_names = keys(jsondecode(data.consul_keys.machines.var.hashi))
}

resource "vault_policy" "hashi_nodes" {
  for_each = jsondecode(data.consul_keys.machines.var.hashi)
  name = each.key

  policy = <<EOT
path "pki_int/issue/consul" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/nomad" {
  capabilities = ["create", "update"]
}
path "consul/creds/${each.key}" {
  capabilities = ["read"]
}
EOT
}

resource "vault_approle_auth_backend_role" "hashi_nodes" {
  for_each = jsondecode(data.consul_keys.machines.var.hashi)
  backend        = data.vault_auth_backend.approle.path
  role_name      = each.key
  token_policies = [each.key]
}

module "hashi_nodes" {
  for_each = jsondecode(data.consul_keys.machines.var.hashi)
  source             = "./modules/machine"
  datacenter         = jsondecode(data.consul_keys.vsphere.var.vcenter)["datacenter"]
  datastore          = jsondecode(data.consul_keys.vsphere.var.vcenter)["iscsi"]["name"]
  resource_pool_name = "${jsondecode(data.consul_keys.vsphere.var.vcenter)["cluster"]["name"]}/Resources"
  template_name      = "UBHashi"
  vm_name            = each.key
  dns = [jsondecode(data.consul_keys.dns.var.dns)["server"]]
  domains = [jsondecode(data.consul_keys.dns.var.dns)["domain"]]
  nics = [each.value.networking]
  custom_attributes = {"${vsphere_custom_attribute.consul_policies.id}" = jsonencode(each.value.consul.roles)}
  script = templatefile("templates/bootstrap.sh", {
    consul_addr = "${data.consul_keys.bootstrap.var.hostname}.${jsondecode(data.consul_keys.dns.var.dns).domain}:8500"
    vault_addr = "https://${data.consul_keys.bootstrap.var.hostname}.${jsondecode(data.consul_keys.dns.var.dns).domain}:8200"
  })
  tags = {
    "Consul" = "Server"
    "Nomad" = "Server"
    "Vault" = "Server"
  }
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "hashi_nodes_anti_affinity_rule" {
  name                = "hashi_nodes"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = values(module.hashi_nodes)[*].uuid[0]
}

resource "null_resource" "hashi_nodes_provisioner" {
  depends_on = [
    module.hashi_nodes,
  ]
  provisioner "local-exec" {
    command = "python3 scripts/bootstrap.py \"${base64encode(jsonencode(local.hashi_server_names))}\""
  }
}