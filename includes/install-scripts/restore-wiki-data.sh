#!/bin/bash

rm -Rf /data/www/bluespice/w/images
echo "Importing the data from the old installation"
cp -Rf /data/www/backups/$date/w/images /data/www/bluespice/w/images >>/dev/logs 2>&1

echo "copying bluespice foundation data and config folders..." >>/dev/logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data >>/dev/logs 2>&1
mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config >>/dev/logs 2>&1
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ >>/dev/logs 2>&1
cp -r /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >>/dev/logs 2>&1
cp -r /data/www/backups/$date/w/extensions/BlueSpiceFoundation/config/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ >>/dev/logs 2>&1
cp -r /data/www/backups/$date/w/extensions/BlueSpiceFoundation/data/. /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >>/dev/logs 2>&1
echo "copied bluespice foundation data and config folders" >>/dev/logs 2>&1

cp -f /data/www/backups/$date/w/LocalSettings.php /data/www/bluespice/w/ >>/dev/logs 2>&1
ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/ >>/dev/logs 2>&1

# restore local settings from old wiki
echo "copying local settings from old wiki" >>/dev/logs 2>&1
cp -f data/www/backups/$date/w/settings.d/*.local.php /data/www/bluespice/w/settings.d/ >>/dev/logs 2>&1
echo "copied local settings from old wiki" >>/dev/logs 2>&1

/usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >>/dev/logs 2>&1
/usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >>/dev/logs 2>&1
chown -Rf www-data:www-data /opt/docker/bluespice-data
chown www-data:www-data /data/www/bluespice
if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
    sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
    sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
    rm /etc/nginx/sites-enabled/bluespice.conf
    ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
fi
