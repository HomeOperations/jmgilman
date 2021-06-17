#!/bin/bash

docker run \
    --name vault-unseal \
    -v $(pwd)/tmp:/tmp/vol \
    -e VAULT_ADDR=https://vault:8200 \
    -e VAULT_CACERT=./tmp/vol/root_ca.crt \
    -e VAULT_UNSEAL \
    --network kickstart_default \
    vault /bin/sh -c '/bin/vault operator unseal $VAULT_UNSEAL'
docker container rm vault-unseal