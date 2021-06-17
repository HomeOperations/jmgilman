#!/bin/bash

echo "Setting up local environment..."
lpass status | grep -q "Not logged in."
if [[ $? -eq 0 ]]
then
    echo "Enter LastPass username:"
    read username
    lpass login "$username"
fi

export VCENTER_SERVER="vcenter.gilman.io"
export VCENTER_ADMIN_NAME="administrator@vsphere.local"
export ESXI_ROOT_NAME="root"

export VCENTER_ROOT_PASS=$(lpass show "Lab/Bootstrap" | grep "vCenter Admin Password: " | sed "s/vCenter Admin Password: //")
export VCENTER_ADMIN_PASS=$(lpass show "Lab/Bootstrap" | grep "vCenter Root Password: " | sed "s/vCenter Root Password: //")
export ESXI_ROOT_PASS=$(lpass show "Lab/Bootstrap" | grep "ESXi Root Password: " | sed "s/ESXi Root Password: //")

export VCENTER_LICENSE=$(lpass show "Lab/Licenses" | grep "Notes: vCenter: " | sed "s/Notes: vCenter: //")
export ESXI_LICENSE=$(lpass show "Lab/Licenses" | grep "ESXi: " | sed "s/ESXi: //")