#!/bin/bash

# Vault
export VAULT_ADDR=https://vault:8200
export VAULT_CACERT=/root/.mc/certs/CAs/root_ca.crt
export VAULT_OIDC_ADDR=http://vault:8250

# Trust Vault CA
vault read -field=certificate pki/cert/ca > test2.crt

# Update CA certificatea
update-ca-certificates > /dev/null

# Minio
export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key secret/minio/accounts/admin)
export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_key secret/minio/accounts/admin)
export AWS_SSE_CUSTOMER_KEY=$(vault read -field backup transit/backup/minio | base64 -d | jq --raw-output .policy.keys[].key)
export MC_HOST_minio="https://$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY@minio:9000"

# Packer
export VCENTER_USER=$(vault kv get -field=username secret/vsphere/accounts/administrator)
export VCENTER_PASS=$(vault kv get -field=password secret/vsphere/accounts/administrator)
export ADMIN_PASS=$(vault kv get -field=password secret/linux/accounts/admin)

# Consul
export CONSUL_HTTP_ADDR=consul:8500

# Ansible
export VMWARE_USERNAME=$(vault kv get -field=username secret/vsphere/accounts/administrator)
export VMWARE_PASSWORD=$(vault kv get -field=password secret/vsphere/accounts/administrator)
export VMWARE_SERVER=$(consul kv get vsphere/vcenter | jq --raw-output .server)
export VMWARE_VALIDATE_CERTS="no"

# Generate and sign SSH keypair
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -q -N ""
vssh --only-sign > /dev/null
tee -a ~/.ssh/config > /dev/null << END
Host *
    User admin
    Port 22
    HashKnownHosts yes
    ServerAliveInterval 30
    ServerAliveCountMax 4
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_rsa
END

# Start in lab dir
cd lab

# Run CMD
exec "$@"