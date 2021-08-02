#!/bin/bash

# AWS credentials
export AWS_ACCESS_KEY_ID="$(lpass show --field=id Lab/AWS)"
export AWS_SECRET_ACCESS_KEY="$(lpass show --field=key Lab/AWS)"
export AWS_DEFAULT_REGION=us-west-2

# Cloudflare credentails
export CLOUDFLARE_EMAIL="$(lpass show --field=id Lab/Cloudflare)"
export CLOUDFLARE_TOKEN="$(lpass show --field=key Lab/Cloudflare)"

# Minio root credentials
export MINIO_ROOT_USER=$(aws ssm get-parameters --name "minio-access-key" --with-decryption | jq -r .Parameters[0].Value)
export MINIO_ROOT_PASSWORD=$(aws ssm get-parameters --name "minio-secret-key" --with-decryption | jq -r .Parameters[0].Value)

# Consul master token and encryption key
export CONSUL_MASTER_TOKEN=$(aws ssm get-parameters --name "consul-master-token" --with-decryption | jq -r .Parameters[0].Value)
export CONSUL_ENC_KEY=$(consul keygen)

# Linux admin password
export LINUX_ADMIN_PASS=$(aws ssm get-parameters --name "linux-admin-pass" --with-decryption | jq -r .Parameters[0].Value)

# RPI SSH credentials
export RPI_SSH_PRIV_KEY=$(aws ssm get-parameters --name "rpi-priv-key" --with-decryption | jq -r .Parameters[0].Value)
export RPI_SSH_PUB_KEY=$(aws ssm get-parameters --name "rpi-pub-key" --with-decryption | jq -r .Parameters[0].Value)

# NAS SSH credentials
export NAS_SSH_PRIV_KEY=$(aws ssm get-parameters --name "nas-priv-key" --with-decryption | jq -r .Parameters[0].Value)
export NAS_SSH_PUB_KEY=$(aws ssm get-parameters --name "nas-pub-key" --with-decryption | jq -r .Parameters[0].Value)