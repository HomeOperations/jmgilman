#!/bin/bash

set -e

ENTRIES=$(yq eval -j ../../configuration/import/machines.yml | jq -r '[[. | to_entries[] | .value | to_entries[] | .key], [. | to_entries[] | .value[].networking.ip]] | transpose | map({ (.[0]): (.[1])}) | add')
ansible-playbook -e "entries='$(echo $ENTRIES | base64)'" setup.yml