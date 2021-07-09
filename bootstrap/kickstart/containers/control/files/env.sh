#!/bin/bash

# Confgure Consul
export CONSUL_HTTP_ADDR="consul:8501"
export CONSUL_HTTP_SSL="true"
export CONSUL_CACERT="/root/certs/ca.crt"
export CONSUL_CLIENT_CERT="/root/certs/consul.crt"
export CONSUL_CLIENT_KEY="/root/certs/consul.key"
export ANSIBLE_CONSUL_VALIDATE_CERTS="/root/certs/ca.crt"

# Configure Vault
export VAULT_ADDR="https://vault:8200"
export VAULT_CACERT="/root/certs/ca.crt"
export VAULT_OIDC_ADDR="http://vault:8250"

# Copy CA cert to Minio local directory
mkdir -p /root/.mc/certs/CAs
cp /root/certs/ca.crt /root/.mc/certs/CAs

# Make the system trust CA
cp /root/certs/ca.crt /usr/local/share/ca-certificates/ca.crt
update-ca-certificates > /dev/null

# Configure Poetry
source /root/.poetry/env

# Run CMD
exec "$@"