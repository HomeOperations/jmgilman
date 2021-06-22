path "pki_int/issue/consul" {
    capabilities = ["read", "create", "update"]
}

path "pki_int/issue/nomad" {
    capabilities = ["read", "create", "update"]
}

path "secret/consul/tokens/root" {
    capabilities = ["read", "create", "update"]
}

path "consul/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}