#!/bin/bash

if [ -f "/opt/docker/.firstrun" ]; then
    echo "BLUESPICE IS PREPARING..."
    if ! [[ -d "/data/mysql" ]] && ! [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
        rm -Rf /data/www
        unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www > /dev/null 2>&1
        mv /data/www/bluespice /data/www/w
        mkdir -p /data/www/bluespice
        mv /data/www/w /data/www/bluespice
        cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        /etc/init.d/elasticsearch start > /dev/null 2>&1 &
        rm -Rf /data/mysql
        /usr/sbin/mysqld --initialize-insecure > /dev/null 2>&1
        /etc/init.d/mysql start > /dev/null 2>&1
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
            sed -i "s/http:/https:/g" /usr/local/parsoid/localsettings.js
            if [ -f "/data/cert/ssl.ca" ]; then
                sed -i "s/{CAFILE}/\/data\/cert\/ssl.ca/g" /etc/apache2/sites-available/bluespice-ssl.conf
            else
                sed -i '/{CAFILE}/d' /etc/apache2/sites-available/bluespice-ssl.conf
            fi
            a2dissite bluespice > /dev/null 2>&1
            a2ensite bluespice-ssl > /dev/null 2>&1
        fi
        /usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath="/data/www/bluespice/w" --dbname="bluespice" --dbuser=root --dbpass="" --dbserver="localhost" --lang=$bs_lang --pass="hallowelt" --scriptpath=/w --server="$bs_url" "BlueSpice" "WikiSysop"  > /dev/null 2>&1
        ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/
        mkdir /opt/docker/bluespice-data/extensions/BluespiceFoundation/data
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template /opt/docker/bluespice-data/extensions/BluespiceFoundation/config
        ln -s /opt/docker/bluespice-data/extensions/BluespiceFoundation/data /data/www/bluespice/w/extensions/BlueSpiceFoundation/data
        ln -s /opt/docker/bluespice-data/extensions/BluespiceFoundation/config /data/www/bluespice/w/extensions/BlueSpiceFoundation/config
        /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/rebuildall.php --quick  > /dev/null 2>&1 &
        /usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop WikiSysop hallowelt  > /dev/null 2>&1
        chown -Rf www-data:www-data /opt/docker/bluespice-data
        chown www-data:www-data /data/www/bluespice
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php  > /dev/null 2>&1
        rm -f /opt/docker/.firstrun
        /opt/docker/setwikiperm.sh /data/www/bluespice/w
        /etc/init.d/mysql stop > /dev/null 2>&1 &
        /etc/init.d/elasticsearch stop > /dev/null 2>&1
    else
        /etc/init.d/elasticsearch start > /dev/null 2>&1 &
        chown -Rf mysql:mysql /data/mysql
        /etc/init.d/mysql start > /dev/null 2>&1
        mv /data/www/bluespice /data/www/bs_old
        unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www > /dev/null 2>&1
        mv /data/www/bluespice /data/www/w
        mkdir -p /data/www/bluespice
        mv /data/www/w /data/www/bluespice
        cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        rm -Rf /data/www/bluespice/w/images
        cp -Rf /data/www/bs_old/w/images /data/www/bluespice/w/images  > /dev/null 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data  > /dev/null 2>&1
        cp -Rf /data/www/bs_old/w/extensions/BlueSpiceFoundation/data/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/  > /dev/null 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template /data/www/bluespice/w/extensions/BlueSpiceFoundation/config  > /dev/null 2>&1
        cp -Rf /data/www/bs_old/w/extensions/BlueSpiceFoundation/config/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/  > /dev/null 2>&1
        cp -f /data/www/bs_old/w/LocalSettings.php /data/www/bluespice/w/  > /dev/null 2>&1
        ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/rebuildall.php --quick  > /dev/null 2>&1 &
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php  > /dev/null 2>&1
        rm -f /opt/docker/.firstrun
        /opt/docker/setwikiperm.sh /data/www/bluespice/w
        /etc/init.d/mysql stop > /dev/null 2>&1 &
        /etc/init.d/elasticsearch stop > /dev/null 2>&1
    fi

    
    # Pingback
    if [[ $DISABLE_PINGBACK != "yes" ]];
    then
        /usr/local/bin/phantomjs --ssl-protocol=any /opt/docker/pingback.js
    fi
fi
echo "STARTING SERVICES..."
/etc/init.d/elasticsearch start > /dev/null 2>&1
sleep 3
/etc/init.d/parsoid start > /dev/null 2>&1
/etc/init.d/mysql start > /dev/null 2>&1
/etc/init.d/jetty9 start > /dev/null 2>&1
/etc/init.d/memcached start > /dev/null 2>&1
/etc/init.d/php7.2-fpm start > /dev/null 2>&1
/etc/init.d/cron start > /dev/null 2>&1
/etc/init.d/apache2 start > /dev/null 2>&1
echo "READY!"
sleep infinity
