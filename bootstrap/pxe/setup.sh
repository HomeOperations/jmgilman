#!/bin/bash

set -e

ADDR="nas.gilman.io"
USER="josh"
HTTP_ADDR="https://ipxe.gilman.io/images"

echo "Starting bootstrap process for PXE..."

# Create ARM images via Vagrant
echo "Generating ARM images..."
(cd ../raspi && vagrant up)
(cd ../raspi && vagrant destroy -f)

# Get NAS SSH credentials
echo "Pulling down NAS SSH credentials..."
echo $NAS_SSH_PRIV_KEY | base64 -d > ~/.ssh/nas_sshkey
echo $NAS_SSH_PUB_KEY | base64 -d > ~/.ssh/nas_sshkey.pub
chmod 0600 ~/.ssh/nas_sshkey

# Copy images
echo "Copying ARM images to NAS..."
scp -i ~/.ssh/nas_sshkey ../raspi/output-tinker/image "$USER@$ADDR:/volume1/pxe/images/tinker.img"

echo "Please download the Tinkerbell image and flash it to the RPI:"
echo "$HTTP_ADDR/tinker.img"
read -p "Press enter to continue"

echo "Pulling down RPI SSH credentials..."
echo $RPI_SSH_PRIV_KEY | base64 -d > ~/.ssh/rpi_sshkey
echo $RPI_SSH_PUB_KEY | base64 -d > ~/.ssh/rpi_sshkey.pub
chmod 0600 ~/.ssh/rpi_sshkey

echo "Setting up Tinkerbell..."
DOMAIN=$(yq eval '.dns.domain' ../../configuration/import/network.yml)
ANSIBLE_HOST_KEY_CHECKING=0 ansible-playbook -i "tinker.$DOMAIN," -e "ansible_ssh_private_key_file=~/.ssh/rpi_sshkey ansible_user=admin" setup.yml

# Cleanup
# echo "Cleaning up..."
# rm -rf ../raspi/output-tinker
# rm -rf ../raspi/packer_cache
# rm -rf ../raspi/.vagrant

# rm ~/.ssh/nas_sshkey
# rm ~/.ssh/nas_sshkey.pub
# rm ~/.ssh/rpi_sshkey
# rm ~/.ssh/rpi_sshkey.pub