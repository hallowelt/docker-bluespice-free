#!/bin/bash

/etc/init.d/mysql restart >>/data/logs/wiki.logs 2>&1
echo "restarting jetty..." >>/data/logs/wiki.logs 2>&1
# /usr/bin/java -Djetty.home=/usr/share/jetty9 -Djetty.base=/usr/share/jetty9 -Djava.io.tmpdir=/tmp -jar /usr/share/jetty9/start.jar jetty.state=/var/lib/jetty9/jetty.state jetty-started.xml &> /dev/stdout

# /etc/init.d/jetty9 start >>/data/logs/wiki.logs 2>&1
service jetty9 start >>/data/logs/wiki.logs 2>&1
echo "restarted jetty" >>/data/logs/wiki.logs 2>&1
/etc/init.d/memcached restart >>/data/logs/wiki.logs 2>&1
/etc/init.d/php8.2-fpm restart >>/data/logs/wiki.logs 2>&1
/etc/init.d/cron restart >>/data/logs/wiki.logs 2>&1

# update nginx settings for bluespice.conf
sed -i "s/listen [0-9]\+;/listen $HTTP_PORT;/g" /etc/nginx/sites-available/bluespice.conf
sed -i "s/return 301 http:\/\/\$host\/wiki\$request_uri;/return 301 http:\/\/\$host:$HTTP_PORT\/wiki\$request_uri;/g" /etc/nginx/sites-available/bluespice.conf

# update nginx settings for bluespice-ssl.conf
sed -i "s/listen [0-9]\+;/listen $HTTP_PORT;/g" /etc/nginx/sites-available/bluespice-ssl.conf
sed -i "s/listen [0-9]\+ ssl http2;/listen $HTTPS_PORT ssl http2;/g" /etc/nginx/sites-available/bluespice-ssl.conf
sed -i "s/return 301 http:\/\/\$host\/wiki\$request_uri;/return 301 http:\/\/\$host:$HTTPS_PORT\/wiki\$request_uri;/g" /etc/nginx/sites-available/bluespice-ssl.conf

/etc/init.d/nginx restart >>/data/logs/wiki.logs 2>&1
