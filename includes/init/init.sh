#!/bin/bash

if [ -f "/opt/docker/.firstrun" ]; then
    /usr/bin/wget --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HalloWelt-dfd/3.1.1" -O /opt/docker/pkg/BlueSpice-free-3.1.1.zip https://bluespice.com/?ddownload=2737 --progress=bar --show-progress
    rm -Rf /data/www
    unzip /opt/docker/pkg/BlueSpice-free-3.1.1.zip -d /data/www
    mv /data/www/bluespice /data/www/w
    mkdir -p /data/www/bluespice
    mv /data/www/w /data/www/bluespice
    cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
    /etc/init.d/elasticsearch restart
    rm -Rf /data/mysql
    /etc/init.d/mysql stop
    /usr/sbin/mysqld --initialize-insecure
    /etc/init.d/mysql restart
    sleep 5
    if [ -z $bs_lang ]; then
        bs_lang="en"
    fi
    if [ -z $bs_url ]; then
        bs_url="http://localhost";
    fi
    if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
        sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/apache2/sites-available/bluespice-ssl.conf
        sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/apache2/sites-available/bluespice-ssl.conf
        if [ -f "/data/cert/ssl.ca" ]; then
            sed -i "s/{CAFILE}/\/data\/cert\/ssl.ca/g" /etc/apache2/sites-available/bluespice-ssl.conf
        else
            sed -i '/{CAFILE}/d' /etc/apache2/sites-available/bluespice-ssl.conf
        fi
        a2dissite bluespice
        a2ensite bluespice-ssl
    fi
    /usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath="/data/www/bluespice/w" --dbname="bluespice" --dbuser=root --dbpass="" --dbserver="localhost" --lang=$bs_lang --pass="hallowelt" --scriptpath=/w --server="$bs_url" "BlueSpice" "WikiSysop"
    /usr/bin/php /data/www/bluespice/w/maintenance/update.php
    /usr/bin/php /data/www/bluespice/w/maintenance/rebuildall.php
    /usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop WikiSysop hallowelt
    ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/
    cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template /opt/docker/bluespice-data/extensions/BluespiceFoundation/data
    cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template /opt/docker/bluespice-data/extensions/BluespiceFoundation/config
    ln -s /opt/docker/bluespice-data/extensions/BluespiceFoundation/data /data/www/bluespice/w/extensions/BlueSpiceFoundation/data
    ln -s /opt/docker/bluespice-data/extensions/BluespiceFoundation/config /data/www/bluespice/w/extensions/BlueSpiceFoundation/config
    chown -Rf www-data:www-data /opt/docker/bluespice-data
    chown www-data:www-data /data/www/bluespice
    /usr/bin/php /data/www/bluespice/w/maintenance/rebuildLocalisationCache.php
    /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php
    /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php
    /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php
    rm -f /opt/docker/.firstrun
    /opt/docker/setwikiperm.sh /data/www/bluespice/w
fi

/etc/init.d/elasticsearch restart
sleep 5
/etc/init.d/mysql restart
/etc/init.d/jetty9 restart
/etc/init.d/memcached restart
/etc/init.d/php7.2-fpm restart
/etc/init.d/cron restart
/etc/init.d/parsoid start
/etc/init.d/apache2 restart
echo "READY!"
sleep infinity
