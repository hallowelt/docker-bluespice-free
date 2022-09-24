#!/bin/bash

/etc/init.d/elasticsearch restart >>/dev/logs 2>&1
/etc/init.d/parsoid restart >>/dev/logs 2>&1
/etc/init.d/mysql restart >>/dev/logs 2>&1
/etc/init.d/jetty9 restart >>/dev/logs 2>&1
/etc/init.d/memcached restart >>/dev/logs 2>&1
/etc/init.d/php7.4-fpm restart >>/dev/logs 2>&1
/etc/init.d/cron restart >>/dev/logs 2>&1
/etc/init.d/nginx restart >>/dev/logs 2>&1
