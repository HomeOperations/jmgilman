data "cloudflare_zones" "gilman" {
  filter {
    name = jsondecode(data.consul_keys.dns.var.dns)["domain"]
  }
}

resource "cloudflare_record" "nomad_servers" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["servers"]
  zone_id = data.cloudflare_zones.gilman.zones[0].id
  name    = each.key
  value   = each.value.networking.ip
  type    = "A"
}

resource "cloudflare_record" "nomad_clients" {
  for_each = jsondecode(data.consul_keys.machines.var.nomad)["clients"]
  zone_id = data.cloudflare_zones.gilman.zones[0].id
  name    = each.key
  value   = each.value.networking.ip
  type    = "A"
}