#!/bin/bash

# import all env variables
set -a # automatically export all variables
source $SCRIPT_DIR/.env
set +a

echo $BACKUP_LIMIT

date=$(date +%Y%m%d%H%M)

if [ -f "/opt/docker/.firstrun" ]; then
    rndpass=$(date +%s | sha256sum | base64 | head -c 32; echo)
    # if both mysql folder and localsettings file does not exit then do a fresh install
    if ! [[ -d "/data/mysql" ]] && ! [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
        # echo "BlueSpice installation is started. This process can take up to 10 minutes."
        # /etc/init.d/elasticsearch start  >> /dev/logs 2>&1
        # rm -Rf /data/www
        # sleep 2
        # echo "."
        # unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www  >> /dev/logs 2>&1
        # mv /data/www/bluespice /data/www/w >> /dev/logs 2>&1
        # # mv /data/www/luespice /data/www/w >> /dev/logs 2>&1
        # mkdir -p /data/www/bluespice >> /dev/logs 2>&1
        # mv /data/www/w /data/www/bluespice >> /dev/logs 2>&1
        # # cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        
        # rm -Rf /data/mysql >> /dev/logs 2>&1
        # rm -Rf /var/lib/mysql >> /dev/logs 2>&1
        # /usr/bin/mysql_install_db  --force --datadir=/data/mysql >> /dev/logs 2>&1
        # ln -s /data/mysql /var/lib/mysql >> /dev/logs 2>&1
        # /etc/init.d/mysql start >> /dev/logs 2>&1
        # /etc/init.d/memcached start >> /dev/logs 2>&1
        # /usr/bin/mysql -u root -e "CREATE DATABASE bluespice"
        # /usr/bin/mysql -u root -e "CREATE USER 'bluespice'@'localhost' IDENTIFIED BY \"$rndpass\""
        # /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON bluespice.* to 'bluespice'@'localhost'"
        # /usr/bin/mysql -u root -e "FLUSH PRIVILEGES"
        # sleep 5
        # if [ -z $bs_lang ]; then
        #     bs_lang="en"
        # fi
        # if [ -z $bs_url ]; then
        #     bs_url="http://localhost";
        # fi
        # if [ -z $bs_user ]; then
        #     bs_user="WikiSysop";
        # fi
        # if [ -z $bs_password ]; then
        #     bs_password="PleaseChangeMe";
        # fi
        # if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
        #     sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
        #     sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
        #     rm /etc/nginx/sites-enabled/bluespice.conf
        #     ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
        # fi
        # echo ".."
        # /usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath="/data/www/bluespice/w" --dbname="bluespice" --dbuser="bluespice" --dbpass="$rndpass" --dbserver="localhost" --lang="$bs_lang" --pass="$bs_password" --scriptpath=/w --server="$bs_url" "BlueSpice" "$bs_user" >> /dev/logs 2>&1
        # ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/
        # mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data >> /dev/logs 2>&1
        # mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config >> /dev/logs 2>&1
        # cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ >> /dev/logs 2>&1
        # cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >> /dev/logs 2>&1
        # /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick >> /dev/logs 2>&1
        # /usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop "$bs_user" "$bs_password" >> /dev/logs 2>&1 &
        # chown -Rf www-data:www-data /opt/docker/bluespice-data
        # chown www-data:www-data /data/www/bluespice
        # /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >> /dev/logs 2>&1
        # /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >> /dev/logs 2>&1
        # /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >> /dev/logs 2>&1
        # rm -f /opt/docker/.firstrun
        # echo "..."
        # /opt/docker/setwikiperm.sh /data/www/bluespice/w &
        source $FRESH_INSTALL_SCRIPT
    # else handle reinstall
    else
        echo "Old installation detected! Moving old installation to /data/www/$date"
        /etc/init.d/elasticsearch start >> /dev/logs 2>&1
        /etc/init.d/memcached start >> /dev/logs 2>&1
        sleep 20
        chown -Rf mysql:mysql /data/mysql
        rm -Rf /var/lib/mysql >> /dev/logs 2>&1
        ln -s /data/mysql /var/lib/mysql >> /dev/logs 2>&1
        /etc/init.d/mysql start >> /dev/logs 2>&1
        mv /data/www/bluespice "/data/www/$date"
        echo "Extracting the new BlueSpice"
        unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www >> /dev/logs 2>&1
        mv /data/www/bluespice /data/www/w
        mkdir -p /data/www/bluespice
        mv /data/www/w /data/www/bluespice
        # cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        rm -Rf /data/www/bluespice/w/images
        echo "Importing the data from the old installation"
        cp -Rf "/data/www/$date/w/images" /data/www/bluespice/w/images  >> /dev/logs 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data >> /dev/logs 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config >> /dev/logs 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ >> /dev/logs 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ >> /dev/logs 2>&1
        cp -Rf "/data/www/$date/w/extensions/BlueSpiceFoundation/data/*" /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/  >> /dev/logs 2>&1
        cp -Rf "/data/www/$date/w/extensions/BlueSpiceFoundation/config/*" /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/  >> /dev/logs 2>&1
        cp -f "/data/www/$date/w/LocalSettings.php" /data/www/bluespice/w/  >> /dev/logs 2>&1
        ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/  >> /dev/logs 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick  >> /dev/logs 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick  >> /dev/logs 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick  >> /dev/logs 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >> /dev/logs 2>&1
        chown -Rf www-data:www-data /opt/docker/bluespice-data
        chown www-data:www-data /data/www/bluespice
        if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
            sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
            sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
            rm /etc/nginx/sites-enabled/bluespice.conf
            ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
        fi
        rm -f /opt/docker/.firstrun
        /opt/docker/setwikiperm.sh /data/www/bluespice/w
        /etc/init.d/mysql stop >>/dev/logs 2>&1 &
        /etc/init.d/elasticsearch stop >> /dev/logs 2>&1
    fi


     # Pingback
    if [[ $DISABLE_PINGBACK != "yes" ]];
    then
        /usr/local/bin/phantomjs --ignore-ssl-errors=true --ssl-protocol=any /opt/docker/pingback.js
    fi
    
fi
echo "Starting the container"
/etc/init.d/elasticsearch restart >> /dev/logs 2>&1
echo "."
/etc/init.d/parsoid restart >> /dev/logs 2>&1
echo ".."
/etc/init.d/mysql restart >> /dev/logs 2>&1
echo "..."
/etc/init.d/jetty9 restart >> /dev/logs 2>&1
echo "...."
/etc/init.d/memcached restart >> /dev/logs 2>&1
echo "....."
/etc/init.d/php7.4-fpm restart >> /dev/logs 2>&1
echo "......"
/etc/init.d/cron restart >> /dev/logs 2>&1
echo "......."
/etc/init.d/nginx restart >> /dev/logs 2>&1
echo "........"
echo "---=== [ READY! ] ===---"
sleep infinity
