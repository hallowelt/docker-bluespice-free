#!/bin/bash

/etc/init.d/elasticsearch restart >>/data/www/wiki.logs 2>&1
/etc/init.d/parsoid restart >>/data/www/wiki.logs 2>&1
/etc/init.d/mysql restart >>/data/www/wiki.logs 2>&1
echo "restarting jetty..." >>/data/www/wiki.logs 2>&1
# /usr/bin/java -Djetty.home=/usr/share/jetty9 -Djetty.base=/usr/share/jetty9 -Djava.io.tmpdir=/tmp -jar /usr/share/jetty9/start.jar jetty.state=/var/lib/jetty9/jetty.state jetty-started.xml &> /dev/stdout

# /etc/init.d/jetty9 start >>/data/www/wiki.logs 2>&1
service jetty9 start >>/data/www/wiki.logs 2>&1
echo "restarted jetty" >>/data/www/wiki.logs 2>&1
/etc/init.d/memcached restart >>/data/www/wiki.logs 2>&1
/etc/init.d/php8.2-fpm restart >>/data/www/wiki.logs 2>&1
/etc/init.d/cron restart >>/data/www/wiki.logs 2>&1
/etc/init.d/nginx restart >>/data/www/wiki.logs 2>&1
