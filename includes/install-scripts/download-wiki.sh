#!/bin/bash

echo "Extracting the new BlueSpice"
mkdir -p /data/www
tar -xf /opt/docker/pkg/BlueSpice-free.tar.gz --directory /data/www >>/dev/logs 2>&1
mv /data/www/bluespice /data/www/w # rename bluespice folder to w
mkdir -p /data/www/bluespice
mv /data/www/w /data/www/bluespice
