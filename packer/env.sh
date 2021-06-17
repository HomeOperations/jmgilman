#!/bin/bash

echo "Setting up local environment..."
lpass status | grep -q "Not logged in."
if [[ $? -eq 0 ]]
then
    echo "Enter LastPass username:"
    read username
    lpass login "$username"
fi

export VCENTER_USER="administrator@vsphere.local"
export VCENTER_PASS=$(lpass show "Lab/Bootstrap" | grep "vCenter Root Password: " | sed "s/vCenter Root Password: //")
export ADMIN_PASS=$(lpass show "Lab/Bootstrap" | grep "vCenter Root Password: " | sed "s/vCenter Root Password: //")