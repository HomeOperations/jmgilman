#!/bin/bash

set -e

LAB_DIR=$(builtin cd "../../"; pwd)

docker build -t control -f $(pwd)/containers/control/Dockerfile .
docker run -it \
    --network kickstart_default \
    -v kickstart_certs-control:/root/certs \
    -v "$LAB_DIR/ansible":/root/ansible \
    -v "$LAB_DIR/configuration":/root/configuration \
    -v "$LAB_DIR/tools":/root/tools \
    -e MC_HOST_minio="https://$MINIO_ROOT_USER:$MINIO_ROOT_PASSWORD@minio:9000" \
    -e CONSUL_HTTP_TOKEN="$CONSUL_MASTER_TOKEN" \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    control