#!/bin/sh

## NOTE: The order in which the services and processes are run and started matters and do not simply change them without knowing what you are doing

set -e

MARKER_FILE="/var/container_initialized"
BS_DB_PASSWORD="ThisIsDBPassword"
BS_LANG="en"
BS_URL="http://127.0.0.1"
BS_USER="WikiSysop"
BS_PASSWORD="PleaseChangeMe"
BS_NAME="Bluespice"
BS_PORT="80"

# Run specific parts only on the first run
if [ ! -f $MARKER_FILE ]; then

    # Setup opensearch
    echo "Setting up opensearch"
    tar xjf opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2
    mv opensearch /opt/opensearch
    rm opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2
    adduser -D -g -H opensearch
    chown -R opensearch:opensearch /opt/opensearch
    # su -s /bin/bash -c "/opt/opensearch/bin/opensearch &" opensearch

    # Setup jetty server
    echo "Setting up jetty server"
    mv jetty-runner-9.4.43.v20210629.jar /opt/jetty9-runner.jar

    # Setup BShtml2PDF 
    echo "Setting up BShtml2PDF "
    mv BShtml2PDF.war /opt/BShtml2PDF.war

    # Setup phantomjs
    echo "Setting up phantomjs"
    tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
    mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
    rm -rf phantomjs-2.1.1-linux-x86_64 phantomjs-2.1.1-linux-x86_64.tar.bz2

    # Setup composer
    echo "Setting up composer"
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer

    # Setup mysql
    echo "Setting up mysql"
    if [ ! -d "/run/mysqld" ]; then
        mkdir -p /run/mysqld
    fi

    if [ -d /data/mysql ]; then
        echo "MySQL directory already present, skipping creation"
    else
        echo "MySQL data directory not found, creating initial DBs"
        mysql_install_db --user=root > /dev/null
        tfile=`mktemp`
        if [ ! -f "$tfile" ]; then
            return 1
        fi
        cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
CREATE USER 'bluespice'@'localhost' IDENTIFIED BY '$BS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON bluespice.* TO 'bluespice'@'localhost' IDENTIFIED BY '$BS_DB_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
        /usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
    fi
fi

# Restarting opensearch service
echo "Restarting opensearch service"
pkill -0 -u opensearch > /dev/null 2>&1 && pkill -u opensearch > /dev/null 2>&1
su -s /bin/bash -c "/opt/opensearch/bin/opensearch &" opensearch # start opensearch
sleep 5

# Start php-fpm service
echo "Starting php-fpm"
php-fpm --daemonize

# Start mysql service
echo "Starting mysqld service"
sh -c '(/usr/bin/mysqld --user=root) &' # run as a background process
sleep 5

# Setup bluspice (opensearch and mysqld services should be up and running below the following block of code)
if [ ! -f $MARKER_FILE ]; then
    # Setup bluspice for the first
    echo "Setting up bluspice for the first time"
    tar xjf build-free-4.4.x.tar.bz2
    mv build-free-4.4.x /var/www/html/w
    rm build-free-4.4.x.tar.bz2
    ln -sf /opt/099-Custom.php /var/www/html/w/settings.d/099-Custom.php
    php /var/www/html/w/maintenance/install.php --confpath=/var/www/html/w --dbname=bluespice --dbuser=bluespice --dbpass=${BS_DB_PASSWORD} --dbserver=localhost --lang=${BS_LANG} --pass=${BS_PASSWORD} --scriptpath=/w --server=${BS_URL}:${BS_PORT} "${BS_NAME}" $BS_USER >>/dev/stdout
    mkdir -p /var/www/html/w/extensions/BlueSpiceFoundation/data >>/dev/stdout
    mkdir -p /var/www/html/w/extensions/BlueSpiceFoundation/config >>/dev/stdout
    cp -r /var/www/html/w/extensions/BlueSpiceFoundation/data.template/. /var/www/html/w/extensions/BlueSpiceFoundation/data/ >>/dev/stdout
    php /var/www/html/w/maintenance/createAndPromote.php --force --sysop "$BS_USER" "$BS_PASSWORD" >>/dev/stdout
    chown -R www-data:www-data /var/www/html/w/    

    # Create a marker file to indicate that the container has been initialized
    touch $MARKER_FILE
fi

# Starting bluspice
echo "Starting bluspice"
php /var/www/html/w/maintenance/update.php --quick >>/dev/stdout
php /var/www/html/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >>/dev/stdout
php /var/www/html/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >>/dev/stdout
php /var/www/html/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >>/dev/stdout

# Finally run the docker container with the nginx process
echo "Ready to visit bluespice"
exec nginx -g 'daemon off;' # Start the container with nginx process
