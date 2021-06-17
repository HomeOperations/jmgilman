data "consul_keys" "consul" {
  key {
    name = "config"
    path = "consul/config"
  }
}

data "consul_keys" "nomad" {
  key {
    name = "config"
    path = "nomad/config"
  }
}

data "consul_keys" "machines" {
  key {
    name = "nomad"
    path = "machines/nomad"
  }
}

data "consul_keys" "dns" {
  key {
    name = "dns"
    path = "network/dns"
  }
}

data "consul_keys" "vsphere" {
  key {
    name = "vcenter"
    path = "vsphere/vcenter"
  }
}