#!/bin/bash

/etc/init.d/mysql start >>/data/logs/wiki.logs 2>&1
/etc/init.d/memcached start >>/data/logs/wiki.logs 2>&1
