#!/bin/bash

mkdir -p /data/logs/

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
FRESH_INSTALL_SCRIPT=$SCRIPT_DIR/fresh-install.sh
RESTORE_DATA_SCRIPT=$SCRIPT_DIR/restore-wiki-data.sh
DOWNLOAD_WIKI_SCRIPT=$SCRIPT_DIR/download-wiki.sh
START_SERVICES_SCRIPT=$SCRIPT_DIR/start-services.sh
RESTART_SERVICES_SCRIPT=$SCRIPT_DIR/restart-services.sh
CLEANUP_SCRIPT=$SCRIPT_DIR/cleanup.sh

# setup opensearch
if [ ! -f "/opt/opensearch/bin/opensearch" ]; then
	curl -O https://artifacts.opensearch.org/releases/bundle/opensearch/2.11.0/opensearch-2.11.0-linux-x64.tar.gz
	mkdir -p /opt/opensearch
	tar -zxvf opensearch-2.11.0-linux-x64.tar.gz -C /opt/opensearch --strip-components=1
	rm opensearch-2.11.0-linux-x64.tar.gz
	mv /opt/opensearch.yml /opt/opensearch/config/opensearch.yml
	groupadd opensearch
    useradd -m -g opensearch opensearch
    echo 'opensearch:password' | chpasswd
	usermod -aG sudo opensearch
	chown -R opensearch:opensearch /opt/opensearch
	/opt/opensearch/bin/opensearch-plugin install ingest-attachment --batch
	chown -R opensearch:opensearch /opt/opensearch
fi

# start opensearch service
service opensearch restart
echo "WAITING FOR 60 SECONDS BECAUSE OPENSEARCH NEEDS SOME TIME TO REALLY COME UP..."
secs=$((60))
while [ $secs -gt 0 ]; do
	echo -ne "..... $secs\033[0K\r"
	sleep 1
	: $((secs--))
done

date=$(date +%Y%m%d%H%M%S)
if [ -f "/opt/docker/.firstrun" ]; then
    rndpass=$(
        date +%s | sha256sum | base64 | head -c 32
        echo
    )
    # if both mysql folder and localsettings file does not exit then do a fresh install
    if ! [[ -d "/data/mysql" ]] && ! [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
        source $FRESH_INSTALL_SCRIPT
    # else handle reinstall
    else
        echo "Old installation detected! Moving old installation to /data/backups/$date"
        /etc/init.d/memcached start >> /data/logs/wiki.logs 2>&1
        sleep 20
        chown -Rf mysql:mysql /data/mysql
        rm -Rf /var/lib/mysql >>/data/logs/wiki.logs 2>&1
        ln -s /data/mysql /var/lib/mysql >>/data/logs/wiki.logs 2>&1
        /etc/init.d/mysql start >> /data/logs/wiki.logs 2>&1
        mkdir -p /data/backups/
        mv /data/www/bluespice /data/backups/$date
        python3 $SCRIPT_DIR/backup-wiki-data.py $WIKI_BACKUP_LIMIT >>/data/logs/wiki.logs 2>&1
        source $DOWNLOAD_WIKI_SCRIPT
        source $RESTORE_DATA_SCRIPT
    fi
    source $CLEANUP_SCRIPT
fi
echo "Starting the container" >>/data/logs/wiki.logs 2>&1
source $RESTART_SERVICES_SCRIPT
echo "---=== [ READY! ] ===---" >>/data/logs/wiki.logs 2>&1
tail -f /data/logs/wiki.logs
