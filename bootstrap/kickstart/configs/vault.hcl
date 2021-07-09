ui = true
log_level = "Debug"

storage "consul" {
  address = "consul:8501"
  scheme = "https"
  path    = "vault"
  tls_ca_file = "/vault/config/certs/ca.crt"
  tls_cert_file = "/vault/config/certs/consul.crt"
  tls_key_file = "/vault/config/certs/consul.key"
  disable_registration = true
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/certs/server.crt"
  tls_key_file= "/vault/config/certs/server.key"
}