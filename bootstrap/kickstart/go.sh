#!/bin/bash

LAB_DIR=$(builtin cd "../../"; pwd)

export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_SKIP_VERIFY=1
export VAULT_TOKEN=$(cat ~/.vault-token)

# Check if Vault is initialized
if [[ $(vault status -format=json | jq -r .initialized) == "true" ]]; then
    if [[ $(vault status -format=json | jq -r .sealed) == "true" ]]; then
        echo "Unsealing Vault..."
        KEY=$(aws ssm get-parameters --name "vault-unseal-key" --with-decryption | jq -r .Parameters[0].Value)
        vault operator unseal "$KEY" > /dev/null
    fi

    # Check if token is valid
    vault token lookup > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Logging in..."
        export VAULT_TOKEN=$(vault login -method=oidc -format=json role=admin | jq -r .auth.client_token)
    fi
fi

docker build -t control -f $(pwd)/containers/control/Dockerfile .
docker run -it \
    --network kickstart_default \
    --expose 8250 \
    --rm \
    --privileged \
    -p 8250:8250 \
    -v kickstart_certs-control:/root/certs \
    -v "$LAB_DIR/ansible":/root/ansible \
    -v "$LAB_DIR/configuration":/root/configuration \
    -v "$LAB_DIR/packer":/root/packer \
    -v "$LAB_DIR/tools":/root/tools \
    -e MC_HOST_minio="https://$MINIO_ROOT_USER:$MINIO_ROOT_PASSWORD@minio:9000" \
    -e CONSUL_HTTP_TOKEN="$CONSUL_MASTER_TOKEN" \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    -e VAULT_TOKEN \
    control $1