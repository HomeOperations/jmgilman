data "consul_keys" "bootstrap" {
  key {
    name = "hostname"
    path = "bootstrap/hostname"
  }
}

data "consul_keys" "consul" {
  key {
    name = "config"
    path = "consul/config"
  }
  key {
    name = "acl"
    path = "consul/acl"
  }
}

data "consul_keys" "dns" {
  key {
    name = "dns"
    path = "network/dns"
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
    name = "hashi"
    path = "machines/hashi"
  }
  key {
    name = "worker"
    path = "machines/worker"
  }
}

data "consul_keys" "vsphere" {
  key {
    name = "vcenter"
    path = "vsphere/vcenter"
  }
}