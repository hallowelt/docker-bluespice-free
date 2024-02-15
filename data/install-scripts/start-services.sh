#!/bin/bash

# Force restarting opensearch service
echo "Restarting opensearch service"
pkill -0 -u opensearch > /dev/null 2>&1 && pkill -u opensearch > /dev/null 2>&1
su -s /bin/bash -c "/opt/opensearch/bin/opensearch &" opensearch # start opensearch
sleep 5

# Start php-fpm service
echo "Starting php-fpm"
php-fpm --daemonize

# Start mysql service
echo "Starting mysqld service"
/etc/init.d/mysql start >>/data/logs/wiki.logs 2>&1
sleep 5

# Start memcached service
/etc/init.d/memcached start >>/data/logs/wiki.logs 2>&1

# Start jetty9 service
service jetty9 start >>/data/logs/wiki.logs 2>&1

# Run bluspice scripts 
echo "Starting bluspice"
php /var/www/html/w/maintenance/update.php --quick >>/dev/stdout
php /var/www/html/w/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick >>/dev/stdout
php /var/www/html/w/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick >>/dev/stdout
php /var/www/html/w/maintenance/runJobs.php --memory-limit=max --maxjobs=50 >>/dev/stdout

# Todo
/etc/init.d/cron start >>/data/logs/wiki.logs 2>&1

# Finally run the docker container with the nginx process
service nginx start
