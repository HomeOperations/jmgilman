data "cloudflare_zones" "gilman" {
  filter {
    name = jsondecode(data.consul_keys.dns.var.dns)["domain"]
  }
}

resource "cloudflare_record" "hashi_nodes" {
  for_each = jsondecode(data.consul_keys.machines.var.hashi)
  zone_id = data.cloudflare_zones.gilman.zones[0].id
  name    = each.key
  value   = each.value.networking.ip
  type    = "A"
}