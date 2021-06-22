#!/usr/bin/env bash
export VAULT_ADDR="${vault_addr}"
export VAULT_SKIP_VERIFY=1
export CONSUL_HTTP_ADDR="${consul_addr}"

unset CONSUL_CACERT
unset CONSUL_CLIENT_CERT
unset CONSUL_CLIENT_KEY

ansible-playbook /opt/ansible/bootstrap.yml
#rm -rf /opt/ansible