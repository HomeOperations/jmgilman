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
export VAULT_OIDC_ADDR="http://0.0.0.0:8250"

# Copy CA cert to Minio local directory
mkdir -p /root/.mc/certs/CAs
cp /root/certs/ca.crt /root/.mc/certs/CAs

# Make the system trust CA
cp /root/certs/ca.crt /usr/local/share/ca-certificates/ca.crt
update-ca-certificates > /dev/null

# Configure Poetry
source /root/.poetry/env

# Setup NAS SSH credentials
mkdir -p ~/.ssh
chmod 0744 ~/.ssh
echo "$(aws ssm get-parameters --name "nas-priv-key" --with-decryption | jq -r .Parameters[0].Value | base64 -d)" > ~/.ssh/id_nas
echo "$(aws ssm get-parameters --name "nas-pub-key" --with-decryption | jq -r .Parameters[0].Value | base64 -d)" > ~/.ssh/id_nas.pub
chmod 0600 ~/.ssh/id_nas

# Disable Ansible SSH host key checking
export ANSIBLE_HOST_KEY_CHECKING=0

# Check if Vault is initialized
if [[ $(vault status -format=json | jq -r .initialized) == "true" ]]; then
    if [[ $(vault status -format=json | jq -r .sealed) == "true" ]]; then
        echo "Unsealing Vault..."
        KEY=$(aws ssm get-parameters --name "vault-unseal-key" --with-decryption | jq -r .Parameters[0].Value)
        vault operator unseal "$KEY" > /dev/null
    fi
fi

# Run
if [ -z $1 ]; then
    echo "Usage: $0 [bootstrap|raspi|restore|shell]"
    exit
fi

if [ ${1} == "shell" ]; then
    /bin/bash
elif [[ -f "$1.sh" ]]; then
    /bin/bash "$1.sh"
else
    echo "Invalid operation: $1"
fi