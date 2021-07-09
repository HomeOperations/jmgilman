#!/bin/bash

# Load configuration
echo "Loading configuration data..."
(cd configuration && poetry install && poetry run python load.py)

# Bootstrap Vault
echo "Initializing Vault..."
ansible-playbook ansible/vault_bootstrap.yml --tags "init"

echo "Bootstrapping Vault..."
export VAULT_TOKEN=$(aws ssm get-parameters --name "vault-root-token" --with-decryption | jq -r .Parameters[0].Value)
ansible-playbook ansible/vault_bootstrap.yml

# Save backup
echo "Backing up Consul..."
(cd tools/consul/backup && poetry install && poetry run python backup.py --operation backup --file /tmp/backup.enc.snap --keyid "alias/Lab")
mc mb minio/bootstrap
mc cp /tmp/backup.enc.snap minio/bootstrap/backup.enc.snap

echo "Done!"