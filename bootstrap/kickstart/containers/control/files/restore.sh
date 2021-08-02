#!/bin/bash

# Save backup
echo "Restoring Consul backup..."
mc cp minio/bootstrap/backup.enc.snap /tmp/backup.enc.snap
(cd tools/consul/backup && poetry install && poetry run python backup.py --operation restore --file /tmp/backup.enc.snap --keyid "alias/Lab")

echo "Done!"