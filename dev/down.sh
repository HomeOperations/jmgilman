#!/bin/bash

echo "Unlinking root CA..."
rm ~/.mc/certs/CAs/root_ca.crt

echo "Bringing down Docker stack..."
docker-compose down

echo "Removing temporary directories..."
sudo umount nfs
sleep 1
rm -rf nfs
rm -rf tmp

echo "Development environment is down!"