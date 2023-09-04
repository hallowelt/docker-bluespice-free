#!/bin/bash

/etc/init.d/mysql start >>/data/www/wiki.logs 2>&1
/etc/init.d/elasticsearch start >>/data/www/wiki.logs 2>&1
/etc/init.d/memcached start >>/data/www/wiki.logs 2>&1
