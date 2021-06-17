#!/bin/bash

if [[ -z $MINIO_ROOT_USER ]]; then
    export MINIO_ROOT_USER=$(lpass show "Lab/Minio" --field username)
fi

if [[ -z $MINIO_ROOT_PASSWORD ]]; then
    export MINIO_ROOT_PASSWORD=$(lpass show "Lab/Minio" --field password)
fi

if [[ -z $VAULT_UNSEAL ]]; then
    export VAULT_UNSEAL=$(lpass show "Lab/Vault" --field unseal)
fi

export NAS_ADDR='192.168.3.10'
export MC_HOST_minio="https://$MINIO_ROOT_USER:$MINIO_ROOT_PASSWORD@minio:9000"
export MC_HOST_miniolocal="https://$MINIO_ROOT_USER:$MINIO_ROOT_PASSWORD@localhost:9000"

echo "Creating temporary directories..."
mkdir nfs
mkdir tmp

echo "Mounting MinIO NFS share..."
sudo mount -o resvport -t nfs "$NAS_ADDR:/volume2/Minio" nfs

echo "Bringing up Docker stack..."
docker-compose up -d

echo "Waiting for stack to finish initializing..."
sleep 10

echo "Unsealing vault..."
docker run \
    --name vault-unseal \
    -v $(pwd)/tmp:/tmp/vol \
    -e VAULT_ADDR=https://vault:8200 \
    -e VAULT_CACERT=./tmp/vol/root_ca.crt \
    -e VAULT_UNSEAL \
    --network dev_default \
    vault /bin/sh -c '/bin/vault operator unseal $VAULT_UNSEAL'
docker container rm vault-unseal

echo "Linking root CA..."
ln -s ./tmp/root_ca.crt ~/.mc/certs/CAs/root_ca.crt

echo "Development environment is up! Please login to vault and then run dev.sh to run a development container"