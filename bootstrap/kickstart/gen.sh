#/bin/bash

# Generate root credentials for Minio
ACCESS_KEY=$(uuidgen)
SECRET_KEY=$(openssl rand -base64 32)

# Generate master Consul token
MASTER_TOKEN=$(uuidgen)

aws ssm put-parameter --name "minio-access-key" --value "$ACCESS_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "minio-secret-key" --value "$SECRET_KEY" --type "SecureString" --tags "Key=lab,Value=default"
aws ssm put-parameter --name "consul-master-token" --value "$MASTER_TOKEN" --type "SecureString" --tags "Key=lab,Value=default"