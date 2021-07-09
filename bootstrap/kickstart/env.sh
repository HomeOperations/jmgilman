#!/bin/bash

# AWS credentials
export AWS_ACCESS_KEY_ID="$(lpass show --field=id Lab/AWS)"
export AWS_SECRET_ACCESS_KEY="$(lpass show --field=key Lab/AWS)"
export AWS_DEFAULT_REGION=us-west-2

# Minio root credentials
export MINIO_ROOT_USER=$(aws ssm get-parameters --name "minio-access-key" --with-decryption | jq -r .Parameters[0].Value)
export MINIO_ROOT_PASSWORD=$(aws ssm get-parameters --name "minio-secret-key" --with-decryption | jq -r .Parameters[0].Value)

# Consul master token and encryption key
export CONSUL_MASTER_TOKEN=$(aws ssm get-parameters --name "consul-master-token" --with-decryption | jq -r .Parameters[0].Value)
export CONSUL_ENC_KEY=$(consul keygen)