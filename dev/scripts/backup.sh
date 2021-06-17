#!/bin/bash

consul snapshot save /tmp/latest.snap
mc cp /tmp/latest.snap minio/consul/backups/latest.snap