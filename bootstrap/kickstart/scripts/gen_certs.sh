#!/bin/bash

step certificate create \
    --insecure \
    --no-password \
    --profile root-ca \
    "GLab Temp" /tmp/vol/root_ca.crt /tmp/vol/root_ca.key

step certificate create \
    --bundle \
    --insecure \
    --no-password \
    --profile leaf \
    --not-after 8760h \
    --ca /tmp/vol/root_ca.crt \
    --ca-key /tmp/vol/root_ca.key \
    --san localhost \
    --san minio \
    vault /tmp/vol/minio.crt /tmp/vol/minio.key

step certificate create \
    --bundle \
    --insecure \
    --no-password \
    --profile leaf \
    --not-after 8760h \
    --ca /tmp/vol/root_ca.crt \
    --ca-key /tmp/vol/root_ca.key \
    --san localhost \
    --san vault \
    vault /tmp/vol/vault.crt /tmp/vol/vault.key