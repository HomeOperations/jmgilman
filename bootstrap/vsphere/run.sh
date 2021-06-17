#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please supply the path to the vCenter installation ISO file"
    exit
fi

docker container rm vsphere_setup
docker build -t vsphere_setup .
docker run -i \
    --name vsphere_setup \
    --mount type=bind,source="$1",target=/opt/setup/iso \
    --env VCENTER_SERVER \
    --env VCENTER_ROOT_PASS \
    --env VCENTER_ADMIN_NAME \
    --env VCENTER_ADMIN_PASS \
    --env ESXI_ROOT_NAME \
    --env ESXI_ROOT_PASS \
    --env VCENTER_LICENSE \
    --env ESXI_LICENSE \
    vsphere_setup