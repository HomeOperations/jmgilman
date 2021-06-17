data "vault_generic_secret" "vsphere_admin" {
  path = "secret/vsphere/accounts/administrator"
}

data "vault_generic_secret" "cloudflare" {
  path = "secret/cloudflare"
}