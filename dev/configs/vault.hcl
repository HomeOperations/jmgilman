ui = true

storage "consul" {
  address = "consul:8500"
  path    = "vault"
  tls_skip_verify = 1
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/tmp/vol/vault.crt"
  tls_key_file= "/tmp/vol/vault.key"
}