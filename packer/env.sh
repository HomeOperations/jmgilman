#!/bin/bash

export VCENTER_USER=$(vault kv get -field=username secret/vsphere/accounts/administrator)
export VCENTER_PASS=$(vault kv get -field=password secret/vsphere/accounts/administrator)
export ADMIN_PASS=$(vault kv get -field=password secret/linux/accounts/admin)