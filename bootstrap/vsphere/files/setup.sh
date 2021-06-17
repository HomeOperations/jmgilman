#!/bin/bash
set -e

# Set default connection details to vCenter
export VMWARE_HOST="$VCENTER_SERVER"
export VMWARE_USER="$VCENTER_ADMIN_NAME"
export VMWARE_PASSWORD="$VCENTER_ADMIN_PASS"
export VMWARE_VALIDATE_CERTS=false

echo "Starting setup script..."

echo "Configuring ESXi hosts..."
ansible-playbook configure_esxi.yml

echo "Installing vCenter..."
ansible-playbook install_vcenter.yml

echo "Performing initial configuration of vCenter..."
ansible-playbook configure_base.yml

echo "Configuring iSCSI storage..."
ansible-playbook configure_iscsi.yml

echo "Migrating vCenter to cluster..."
ansible-playbook migrate_vcenter.yml

echo "Configuring networking..."
ansible-playbook configure_network.yml

echo "Configuring cluster..."
ansible-playbook configure_cluster.yml

echo "Configuring misc settings..."
ansible-playbook configure_misc.yml

echo "Done!"