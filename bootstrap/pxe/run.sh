#!/bin/bash

set -e

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_lab
ansible-playbook -i "nas.gilman.io," pxe.yml