#!/bin/bash

/etc/init.d/elasticsearch restart >>/dev/logs 2>&1
/etc/init.d/parsoid restart >>/dev/logs 2>&1
/etc/init.d/mysql restart >>/dev/logs 2>&1
echo "restarting jetty..."
/usr/bin/java -Djetty.home=/usr/share/jetty9 -Djetty.base=/usr/share/jetty9 -Djava.io.tmpdir=/tmp -jar /usr/share/jetty9/start.jar jetty.state=/var/lib/jetty9/jetty.state jetty-started.xml &> /dev/stdout
echo "restarted jetty"
# /etc/init.d/jetty9 restart >>/dev/logs 2>&1
/etc/init.d/memcached restart >>/dev/logs 2>&1
/etc/init.d/php7.4-fpm restart >>/dev/logs 2>&1
/etc/init.d/cron restart >>/dev/logs 2>&1
/etc/init.d/nginx restart >>/dev/logs 2>&1
