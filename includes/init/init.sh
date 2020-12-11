#!/bin/bash

if [ -f "/opt/docker/.firstrun" ]; then
    rndpass=$(date +%s | sha256sum | base64 | head -c 32; echo)
    echo "BlueSpice preparing itself..."
    if ! [[ -d "/data/mysql" ]] && ! [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
        /etc/init.d/elasticsearch start  > /dev/null 2>&1 &
        rm -Rf /data/www
        echo "Extracting BlueSpice..."
        unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www  > /dev/null 2>&1
        mv /data/www/bluespice /data/www/w
        mkdir -p /data/www/bluespice
        mv /data/www/w /data/www/bluespice
        cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        rm -Rf /data/mysql > /dev/null 2>&1
        rm -Rf /var/lib/mysql > /dev/null 2>&1
        echo "Preparing database..."
        /usr/sbin/mysqld --initialize-insecure  > /dev/null 2>&1
        ln -s /data/mysql /var/lib/mysql > /dev/null 2>&1
        /etc/init.d/mysql start  > /dev/null 2>&1
        /usr/bin/mysql -u root -e "CREATE DATABASE bluespice"
        /usr/bin/mysql -u root -e "CREATE USER 'bluespice'@'localhost' IDENTIFIED BY \"$rndpass\""
        /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON bluespice.* to 'bluespice'@'localhost'"
        /usr/bin/mysql -u root -e "FLUSH PRIVILEGES"
        sleep 5
        if [ -z $bs_lang ]; then
            bs_lang="en"
        fi
        if [ -z $bs_url ]; then
            bs_url="http://localhost";
        fi
        if [ -z $bs_user ]; then
            bs_user="WikiSysop";
        fi
        if [ -z $bs_password ]; then
            bs_password="PleaseChangeMe";
        fi
        if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
            sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
            sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
            sed -i "s/http:/https:/g" /usr/local/parsoid/localsettings.js
            rm /etc/nginx/sites-enabled/bluespice.conf
            ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
        fi
        echo "Installing BlueSpice..."
        /usr/bin/php /data/www/bluespice/w/maintenance/install.php --confpath="/data/www/bluespice/w" --dbname="bluespice" --dbuser="bluespice" --dbpass="$rndpass" --dbserver="localhost" --lang="$bs_lang" --pass="$bs_password" --scriptpath=/w --server="$bs_url" "BlueSpice" "$bs_user" > /dev/null 2>&1
        ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data > /dev/null 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config > /dev/null 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ > /dev/null 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ > /dev/null 2>&1
        echo "Executing maintenance scripts..."
        /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/rebuildall.php --quick > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/createAndPromote.php --force --sysop "$bs_user" "$bs_password" > /dev/null 2>&1
        chown -Rf www-data:www-data /opt/docker/bluespice-data
        chown www-data:www-data /data/www/bluespice
        echo "Creating search index..."
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php  > /dev/null 2>&1 &
        rm -f /opt/docker/.firstrun
        echo "Setting permissions..."
        /opt/docker/setwikiperm.sh /data/www/bluespice/w
        /etc/init.d/mysql stop > /dev/null 2>&1 &
        /etc/init.d/elasticsearch stop > /dev/null 2>&1
    else
        /etc/init.d/elasticsearch start > /dev/null 2>&1 &
        echo "Waiting for elasticsearch..."
        sleep 20
        chown -Rf mysql:mysql /data/mysql
        rm -Rf /var/lib/mysql > /dev/null 2>&1
        ln -s /data/mysql /var/lib/mysql > /dev/null 2>&1
        /etc/init.d/mysql start > /dev/null 2>&1
        echo "Old installation detected! Moving old installation to /data/www/bs_old..."
        mv /data/www/bluespice /data/www/bs_old
        echo "Extracting new BlueSpice..."
        unzip /opt/docker/pkg/BlueSpice-free.zip -d /data/www > /dev/null 2>&1
        mv /data/www/bluespice /data/www/w
        mkdir -p /data/www/bluespice
        mv /data/www/w /data/www/bluespice
        cp /data/www/bluespice/w/extensions/BlueSpiceUEModulePDF/webservices/BShtml2PDF.war /var/lib/jetty9/webapps/
        rm -Rf /data/www/bluespice/w/images
        echo "Importing data from the old installation..."
        cp -Rf /data/www/bs_old/w/images /data/www/bluespice/w/images  > /dev/null 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/data > /dev/null 2>&1
        mkdir -p /data/www/bluespice/w/extensions/BlueSpiceFoundation/config > /dev/null 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/config.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/ > /dev/null 2>&1
        cp -Rf /data/www/bluespice/w/extensions/BlueSpiceFoundation/data.template/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/ > /dev/null 2>&1
        cp -Rf /data/www/bs_old/w/extensions/BlueSpiceFoundation/data/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/data/  > /dev/null 2>&1
        cp -Rf /data/www/bs_old/w/extensions/BlueSpiceFoundation/config/* /data/www/bluespice/w/extensions/BlueSpiceFoundation/config/  > /dev/null 2>&1
        cp -f /data/www/bs_old/w/LocalSettings.php /data/www/bluespice/w/  > /dev/null 2>&1
        ln -s /opt/docker/bluespice-data/settings.d/* /data/www/bluespice/w/settings.d/  > /dev/null 2>&1
        echo "Executing maintenance scripts..."
        /usr/bin/php /data/www/bluespice/w/maintenance/update.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/rebuildall.php --quick  > /dev/null 2>&1 &
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick  > /dev/null 2>&1
        /usr/bin/php /data/www/bluespice/w/maintenance/runJobs.php  > /dev/null 2>&1 &
        chown -Rf www-data:www-data /opt/docker/bluespice-data
        chown www-data:www-data /data/www/bluespice
        if [ -f "/data/cert/ssl.cert" ] && [ -f "/data/cert/ssl.key" ]; then
            sed -i "s/{CERTFILE}/\/data\/cert\/ssl.cert/g" /etc/nginx/sites-available/bluespice-ssl.conf
            sed -i "s/{KEYFILE}/\/data\/cert\/ssl.key/g" /etc/nginx/sites-available/bluespice-ssl.conf
            sed -i "s/http:/https:/g" /usr/local/parsoid/localsettings.js
            rm /etc/nginx/sites-enabled/bluespice.conf
            ln -s /etc/nginx/sites-available/bluespice-ssl.conf /etc/nginx/sites-enabled/
        fi
        rm -f /opt/docker/.firstrun
        echo "Setting permissions..."
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
echo "System services are starting..."
/etc/init.d/elasticsearch start > /dev/null 2>&1
/etc/init.d/parsoid start > /dev/null 2>&1
/etc/init.d/mysql start > /dev/null 2>&1
/etc/init.d/jetty9 start > /dev/null 2>&1
/etc/init.d/memcached start > /dev/null 2>&1
/etc/init.d/php7.2-fpm start > /dev/null 2>&1
/etc/init.d/cron start > /dev/null 2>&1
/etc/init.d/nginx start > /dev/null 2>&1
echo "READY!"
sleep infinity
