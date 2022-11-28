#!/bin/bash

echo "Extracting the new BlueSpice"
mkdir -p /data/www
build_file=opt/docker/pkg/$BLUESPICE_DOCKER_FREE_BUILD

if [[ $build_file == *.tar.gz ]]; then
    tar -xf $build_file --directory /data/www >>/dev/logs 2>&1
fi
if [[ $build_file == *.zip ]]; then
    unzip $build_file -d /data/www >>/dev/logs 2>&1
fi
mv /data/www/bluespice /data/www/w # rename bluespice folder to w
mkdir -p /data/www/bluespice
mv /data/www/w /data/www/bluespice
