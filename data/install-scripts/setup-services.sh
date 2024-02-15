#!/bin/bash

# Setup mysql
echo "Setting up mysql"
rm -Rf /data/mysql >>/data/logs/wiki.logs 2>&1
rm -Rf /var/lib/mysql >>/data/logs/wiki.logs 2>&1
/usr/bin/mysql_install_db --force --datadir=/data/mysql >>/data/logs/wiki.logs 2>&1
ln -s /data/mysql /var/lib/mysql >>/data/logs/wiki.logs 2>&1

# Setup opensearch
echo "Setting up opensearch"
tar xjf opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2
mv opensearch /opt/opensearch
rm opensearch-min-no-jdk-with-plugin-2.11.1.tar.bz2
adduser -D -g -H opensearch
chown -R opensearch:opensearch /opt/opensearch

# Setup jetty server and BShtml2PDF
echo "Setting up jetty server"
mv /opt/docker/jetty-runner-9.4.43.v20210629.jar /opt/jetty9-runner.jar
echo "JAVA_OPTIONS=\"\-Xms512m -Xmx1024m -Djetty.home=127.0.0.1\"" >> /etc/default/jetty9;
chown -Rf www-data:www-data /run/php
echo "Setting up BShtml2PDF "
mv /opt/docker/BShtml2PDF.war /opt/BShtml2PDF.war
chown jetty:adm /opt/BShtml2PDF.war

# Setup phantomjs
echo "Setting up phantomjs"
tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
rm -rf phantomjs-2.1.1-linux-x86_64 phantomjs-2.1.1-linux-x86_64.tar.bz2

# Setup composer
echo "Setting up composer"
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Setup pingback
if [[ "$DISABLE_PINGBACK" != "yes" ]]; then
    /usr/local/bin/phantomjs --ignore-ssl-errors=true --ssl-protocol=any /opt/docker/pingback.js
fi

# Setup nginx
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/bluespice.conf /etc/nginx/sites-enabled/
chmod +x /etc/init.d/opensearch
# update nginx settings for bluespice.conf
sed -i "s/listen [0-9]\+;/listen $HTTP_PORT;/g" /etc/nginx/sites-available/bluespice.conf
sed -i "s/return 301 http:\/\/\$host\/wiki\$request_uri;/return 301 http:\/\/\$host:$HTTP_PORT\/wiki\$request_uri;/g" /etc/nginx/sites-available/bluespice.conf
# update nginx settings for bluespice-ssl.conf
sed -i "s/listen [0-9]\+;/listen $HTTP_PORT;/g" /etc/nginx/sites-available/bluespice-ssl.conf
sed -i "s/listen [0-9]\+ ssl http2;/listen $HTTPS_PORT ssl http2;/g" /etc/nginx/sites-available/bluespice-ssl.conf
sed -i "s/return 301 http:\/\/\$host\/wiki\$request_uri;/return 301 http:\/\/\$host:$HTTP_PORT\/wiki\$request_uri;/g" /etc/nginx/sites-available/bluespice-ssl.conf
