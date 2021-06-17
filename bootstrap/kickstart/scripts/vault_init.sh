#!/bin/bash

OUTPUT=$(docker run \
    --name vault-init \
    -v $(pwd)/tmp:/tmp/vol \
    -e VAULT_ADDR=https://vault:8200 \
    -e VAULT_CACERT=./tmp/vol/root_ca.crt \
    --network kickstart_default \
    vault operator init -key-shares 1 -key-threshold 1)

UNSEAL_KEY=$(echo $OUTPUT | sed -E 's/^Unseal Key 1:(.*) Initial.*/\1/g')
TOKEN=$(echo $OUTPUT | sed -E 's/.*Initial Root Token: (.*) Vault initialized.*/\1/g')

echo $UNSEAL_KEY | lpass edit --sync now --non-interactive --field unseal Lab/Vault
echo $TOKEN | lpass edit --sync now --non-interactive --field token Lab/Vault

docker container rm vault-init