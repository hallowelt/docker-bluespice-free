#!/bin/bash

# Setup bluespice wiki

echo "Setting up bluspice for the first time"
mkdir -p /data/www
build_file=/opt/docker/pkg/BlueSpice-free.tar.bz2
tar -xf $build_file --directory /data/www >>/data/logs/wiki.logs 2>&1
mv /data/www/bluespice /data/www/w # rename bluespice folder to w
mkdir -p /data/www/bluespice
mv /data/www/w /data/www/bluespice
rm -xf $build_file
ln -sf /opt/099-Custom.php /data/www/bluespice/w/settings.d/099-Custom.php

if [ -z $BS_DB_PASSWORD ]; then
    BS_DB_PASSWORD="ThisIsDBPassword"
fi
if [ -z $BS_LANG ]; then
    BS_LANG="en"
fi
if [ -z $BS_URL ]; then
    BS_URL="http://127.0.0.1"
fi
if [ -z $BS_USER ]; then
    BS_USER="WikiSysop"
fi
if [ -z $BS_PASSWORD ]; then
    BS_PASSWORD="PleaseChangeMe"
fi
if [ -z $BS_NAME ]; then
    BS_NAME="Bluespice"
fi

/usr/bin/mysql -u root -e "CREATE DATABASE bluespice"
/usr/bin/mysql -u root -e "CREATE USER 'bluespice'@'localhost' IDENTIFIED BY \"$BS_DB_PASSWORD\""
/usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON bluespice.* to 'bluespice'@'localhost'"
/usr/bin/mysql -u root -e "FLUSH PRIVILEGES"
sleep 5

if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
    sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
    sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
    rm -f /etc/nginx/sites-enabled/bluespice.conf
    ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
fi
echo ".."
ln -s /opt/099-Custom.php /data/www/bluespice/w/settings.d/099-Custom.php 

if [[ $BS_URL = https* ]]; then
    BS_PORT=$HTTPS_PORT
else
    BS_PORT=$HTTP_PORT
fi

/usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath=/data/www/bluespice/w --dbname=bluespice --dbuser=bluespice --dbpass=${BS_DB_PASSWORD} --dbserver=127.0.0.1 --lang=${BS_LANG} --pass=${BS_PASSWORD} --scriptpath=/w --server=${BS_URL}:${BS_PORT} "${BS_NAME}" $BS_USER >>/data/logs/wiki.logs 2>&1

echo "copying bluespice foundation data and config folders..." >>/data/logs/wiki.logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data >>/data/logs/wiki.logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config >>/data/logs/wiki.logs 2>&1
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >>/data/logs/wiki.logs 2>&1
echo "copied bluespice foundation data and config folders" >>/data/logs/wiki.logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick >>/data/logs/wiki.logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop "$BS_USER" "$BS_PASSWORD" >>/data/logs/wiki.logs 2>&1
chown -Rf www-data:www-data /opt/099-Custom.php
chown www-data:www-data /data/www/bluespice
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >>/data/logs/wiki.logs 2>&1
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >>/data/logs/wiki.logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >>/data/logs/wiki.logs 2>&1

# Setup file permissions
/opt/docker/setwikiperm.sh /data/www/bluespice/w
