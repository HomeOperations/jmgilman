provider "vsphere" {
  vsphere_server = jsondecode(data.consul_keys.vsphere.var.vcenter)["server"]
  user           = data.vault_generic_secret.vsphere_admin.data.username
  password       = data.vault_generic_secret.vsphere_admin.data.password

  allow_unverified_ssl = true
}

provider "cloudflare" { 
  email   = data.vault_generic_secret.cloudflare.data.email
  api_key = data.vault_generic_secret.cloudflare.data.key
}