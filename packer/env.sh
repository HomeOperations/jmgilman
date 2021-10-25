#!/bin/bash

export VCENTER_USER=$(vault kv get -field=username secret/vsphere/creds)
export VCENTER_PASS=$(vault kv get -field=password secret/vsphere/creds)
export ADMIN_PASS=$(vault kv get -field=password secret/linux/creds)