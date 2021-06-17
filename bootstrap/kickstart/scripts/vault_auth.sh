#!/bin/bash

# See: https://learn.hashicorp.com/tutorials/vault/oidc-auth?in=vault/auth-methods

export AUTH0_DOMAIN="gilmanlab.us.auth0.com"
export AUTH0_CLIENT_ID=$(lpass show "Lab/Vault_Auth0" --field ID)
export AUTH0_CLIENT_SECRET=$(lpass show "Lab/Vault_Auth0" --field Secret)
export VAULT_TOKEN=$(lpass show "Lab/Vault" --field token)

# Enable OIDC backend
vault auth enable oidc

# Configure OIDC with API auth details from Auth0
vault write auth/oidc/config \
         oidc_discovery_url="https://$AUTH0_DOMAIN/" \
         oidc_client_id="$AUTH0_CLIENT_ID" \
         oidc_client_secret="$AUTH0_CLIENT_SECRET" \
         default_role="default"

# Creates default role which uses the factory default policy provided by Vault
vault write auth/oidc/role/default \
      bound_audiences="$AUTH0_CLIENT_ID" \
      allowed_redirect_uris="https://localhost:8200/ui/vault/auth/oidc/oidc/callback" \
      allowed_redirect_uris="http://localhost:8250/oidc/callback" \
      user_claim="sub" \
      policies="default"

# Creates an admin role that recieves group information from the 'https://vault.gilman.io/roles' key
vault write auth/oidc/role/admin \
         bound_audiences="$AUTH0_CLIENT_ID" \
         allowed_redirect_uris="https://localhost:8200/ui/vault/auth/oidc/oidc/callback" \
         allowed_redirect_uris="http://localhost:8250/oidc/callback" \
         user_claim="sub" \
         policies="default" \
         groups_claim="https://vault.gilman.io/roles" \
         token_max_ttl=12h0m0s

# Create an admin group that maps to the admin policy (located at configs/admin_policy.hcl)
vault write identity/group name="admin" type="external" \
         policies="admin" \
         metadata=responsibility="Vault administrator"

# Create a group alias that links the OIDC mount to the admin group
GROUP_ID=$(vault read -field=id identity/group/name/admin)
OIDC_AUTH_ACCESSOR=$(vault auth list -format=json  | jq -r '."oidc/".accessor')
vault write identity/group-alias name="admin" \
         mount_accessor="$OIDC_AUTH_ACCESSOR" \
         canonical_id="$GROUP_ID"