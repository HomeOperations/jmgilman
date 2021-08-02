#!/bin/bash

set -e

ADDR="nas.gilman.io"
USER="josh"

echo "Pulling down NAS SSH key..."
echo $NAS_SSH_PRIV_KEY | base64 -d > /tmp/nas_sshkey
echo $NAS_SSH_PUB_KEY | base64 -d > /tmp/nas_sshkey.pub

echo "Copying SSH key to NAS..."
ssh-copy-id -i /tmp/nas_sshkey -f "$USER@$ADDR"

echo "Cleaning up..."
rm /tmp/nas_sshkey
rm /tmp/nas_sshkey.pub