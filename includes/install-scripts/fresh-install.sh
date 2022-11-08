#!/bin/bash

echo "BlueSpice installation is started. This process can take up to 10 minutes."
rm -Rf /data/www
sleep 2
echo "."
source $DOWNLOAD_WIKI_SCRIPT
# setup mysql
rm -Rf /data/mysql >>/dev/logs 2>&1
rm -Rf /var/lib/mysql >>/dev/logs 2>&1
/usr/bin/mysql_install_db --force --datadir=/data/mysql >>/dev/logs 2>&1
ln -s /data/mysql /var/lib/mysql >>/dev/logs 2>&1
source $START_SERVICES_SCRIPT


if [ -z $BS_DB_PASSWORD ]; then
    BS_DB_PASSWORD="PleaseChangeMe"
fi
if [ -z $BS_LANGUAGE ]; then
    BS_LANGUAGE="en"
fi
if [ -z $BS_URL ]; then
    BS_URL="http://localhost"
fi
if [ -z $BS_USER ]; then
    BS_USER="WikiSysop"
fi
if [ -z $BS_SYSOP_PASSWORD ]; then
    BS_SYSOP_PASSWORD="PleaseChangeMe"
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
    rm /etc/nginx/sites-enabled/bluespice.conf
    ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
fi
echo ".."
ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/

if [[ $BS_URL = https* ]]; then
    BS_PORT=$HTTPS_PORT
else
    BS_PORT=$HTTP_PORT
fi

/usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath=/data/www/bluespice/w --dbname=bluespice --dbuser=bluespice --dbpass=${BS_DB_PASSWORD} --dbserver=127.0.0.1 --lang=${BS_LANGUAGE} --pass=${BS_SYSOP_PASSWORD} --scriptpath=/w --server=${BS_URL}:${BS_PORT} "${BS_NAME}" $BS_USER >>/dev/logs 2>&1

echo "copying bluespice foundation data and config folders..." >>/dev/logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data >>/dev/logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config >>/dev/logs 2>&1
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ >>/dev/logs 2>&1
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >>/dev/logs 2>&1
echo "copied bluespice foundation data and config folders" >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop "$BS_USER" "$BS_SYSOP_PASSWORD" >>/dev/logs 2>&1 &
chown -Rf www-data:www-data /opt/docker/bluespice-data
chown www-data:www-data /data/www/bluespice
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >>/dev/logs 2>&1
