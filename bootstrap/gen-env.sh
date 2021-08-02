#/bin/bash

# Generate root credentials for Minio
ACCESS_KEY=$(uuidgen)
SECRET_KEY=$(openssl rand -base64 32)

# Generate master Consul token
MASTER_TOKEN=$(uuidgen)

# Generate Linux admin password
LINUX_ADMIN_PASS=$(openssl rand -base64 16)

# Generate RPI SSH credentials
ssh-keygen -t ed25519 -f /tmp/rpi_sshkey -q -N ""
RPI_SSH_PRIV_KEY=$(base64 /tmp/rpi_sshkey)
RPI_SSH_PUB_KEY=$(base64 /tmp/rpi_sshkey.pub)

# Generate NAS SSH credentials
ssh-keygen -t ed25519 -f /tmp/nas_sshkey -q -N ""
NAS_SSH_PRIV_KEY=$(base64 /tmp/nas_sshkey)
NAS_SSH_PUB_KEY=$(base64 /tmp/nas_sshkey.pub)

# Remove prior entries
aws ssm delete-parameter --name "minio-access-key"
aws ssm delete-parameter --name "minio-secret-key"
aws ssm delete-parameter --name "consul-master-token"
aws ssm delete-parameter --name "linux-admin-pass"
aws ssm delete-parameter --name "rpi-priv-key"
aws ssm delete-parameter --name "rpi-pub-key"
aws ssm delete-parameter --name "nas-priv-key"
aws ssm delete-parameter --name "nas-pub-key"

# Create new entries
aws ssm put-parameter --name "minio-access-key" --value "$ACCESS_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "minio-secret-key" --value "$SECRET_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "consul-master-token" --value "$MASTER_TOKEN" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "linux-admin-pass" --value "$LINUX_ADMIN_PASS" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "rpi-priv-key" --value "$RPI_SSH_PRIV_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "rpi-pub-key" --value "$RPI_SSH_PUB_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "nas-priv-key" --value "$NAS_SSH_PRIV_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "nas-pub-key" --value "$NAS_SSH_PUB_KEY" --type "SecureString" --tags "Key=lab,Value=default"

# Cleanup
rm /tmp/rpi_sshkey
rm /tmp/rpi_sshkey.pub
rm /tmp/nas_sshkey
rm /tmp/nas_sshkey.pub