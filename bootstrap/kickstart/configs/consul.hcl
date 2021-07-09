server = true
bootstrap_expect = 1
retry_join = ["consul"]

datacenter = "gilman-dev"
log_level = "INFO"
ui = true
enable_script_checks = false
disable_remote_exec = true

data_dir = "/consul/data"

ca_file = "/consul/config/certs/ca.crt"
cert_file = "/consul/config/certs/server.crt"
key_file = "/consul/config/certs/server.key"

verify_incoming = false
verify_incoming_rpc = true
verify_outgoing = true
verify_server_hostname = true

acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}

performance {
  raft_multiplier = 1
}

ports {
  http = -1
  https = 8501
}