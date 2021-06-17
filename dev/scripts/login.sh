#!/bin/bash

export VAULT_ADDR='https://localhost:8200'
export VAULT_CACERT=./tmp/root_ca.crt
export VAULT_OIDC_ADDR=http://127.0.0.1:8250
export VAULT_TOKEN=$(vault login -token-only -method=oidc role=admin)