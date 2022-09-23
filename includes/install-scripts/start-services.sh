#!/bin/bash

/etc/init.d/mysql start >> /dev/logs 2>&1
/etc/init.d/elasticsearch start  >> /dev/logs 2>&1
/etc/init.d/memcached start >> /dev/logs 2>&1
