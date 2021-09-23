#!/bin/sh

# Generate random root certificate password
PASS=$(openssl rand -base64 32)

# Generate root certificate
echo $PASS | step certificate create -f \
                --profile root-ca \
                --password-file /dev/stdin \
                --not-after 768h \
                "$CN" root_ca.crt root_ca.key

# Generate consul certificates
echo $PASS | step certificate create -f \
                --bundle \
                --insecure \
                --no-password \
                --profile leaf \
                --not-after 768h \
                --ca root_ca.crt \
                --ca-key root_ca.key \
                --ca-password-file /dev/stdin \
                --san localhost \
                --san consul \
                --san server.gilman-dev.consul \
                consul.gilman-dev.consul /ca/consul/server.crt /ca/consul/server.key

echo $PASS | step certificate create -f \
                --bundle \
                --insecure \
                --no-password \
                --profile leaf \
                --not-after 768h \
                --ca root_ca.crt \
                --ca-key root_ca.key \
                --ca-password-file /dev/stdin \
                --san localhost \
                control.gilman-dev.consul /ca/control/consul.crt /ca/control/consul.key

echo $PASS | step certificate create -f \
                --bundle \
                --insecure \
                --no-password \
                --profile leaf \
                --not-after 768h \
                --ca root_ca.crt \
                --ca-key root_ca.key \
                --ca-password-file /dev/stdin \
                --san localhost \
                vault.gilman-dev.consul /ca/vault/consul.crt /ca/vault/consul.key

# Generate minio certificate
echo $PASS | step certificate create -f \
                --bundle \
                --insecure \
                --no-password \
                --profile leaf \
                --not-after 768h \
                --ca root_ca.crt \
                --ca-key root_ca.key \
                --ca-password-file /dev/stdin \
                minio /ca/minio/public.crt /ca/minio/private.key

# Generate vault certificate
echo $PASS | step certificate create -f \
                --bundle \
                --insecure \
                --no-password \
                --profile leaf \
                --not-after 768h \
                --ca root_ca.crt \
                --ca-key root_ca.key \
                --ca-password-file /dev/stdin \
                vault /ca/vault/server.crt /ca/vault/server.key

# Convert control Consul key to PKCS#8
step crypto key format -f --no-password --insecure --pem --pkcs8 --out /ca/control/consul.key /ca/control/consul.key

# Copy CA public certificate
cp root_ca.crt /ca/consul/ca.crt
cp root_ca.crt /ca/control/ca.crt
cp root_ca.crt /ca/minio/ca.crt
cp root_ca.crt /ca/vault/ca.crt

# Cleanup
unset PASS
rm root_ca.key
