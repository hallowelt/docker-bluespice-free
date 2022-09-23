#!/bin/bash

# WIKI_INSTALL_DIR=$1
# WIKI_BACKUP_LIMIT=$2
# DISABLE_PINGBACK=$3
# BS_URL=$4
# BS_LANG=$5
# BS_USER=$6
# BS_PASSWORD=$7

echo WIKI_INSTALL_DIR: ${WIKI_INSTALL_DIR} >>/dev/logs 2>&1
echo WIKI_BACKUP_LIMIT: ${WIKI_BACKUP_LIMIT} >>/dev/logs 2>&1
echo DISABLE_PINGBACK: ${DISABLE_PINGBACK} >>/dev/logs 2>&1
echo BS_LANG: ${BS_LANG} >>/dev/logs 2>&1
echo BS_URL: ${BS_URL} >>/dev/logs 2>&1
echo BS_USER: ${BS_USER} >>/dev/logs 2>&1
echo BS_PASSWORD: ${BS_PASSWORD} >>/dev/logs 2>&1

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
FRESH_INSTALL_SCRIPT=$SCRIPT_DIR/fresh-install.sh
RESTORE_DATA_SCRIPT=$SCRIPT_DIR/restore-wiki-data.sh
DOWNLOAD_WIKI_SCRIPT=$SCRIPT_DIR/download-wiki.sh
START_SERVICES_SCRIPT=$SCRIPT_DIR/start-services.sh
RESTART_SERVICES_SCRIPT=$SCRIPT_DIR/restart-services.sh
CLEANUP_SCRIPT=$SCRIPT_DIR/cleanup.sh

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
        echo "Old installation detected! Moving old installation to /data/www/backups/$date"
        mkdir -p /data/www/backups/
        mv /data/www/bluespice "/data/www/backups/$date"
        python3 $SCRIPT_DIR/backup-wiki-data.py --wiki_backup_limit $WIKI_BACKUP_LIMIT 2>&1 >/dev/logs
        source $DOWNLOAD_WIKI_SCRIPT
        source $RESTORE_DATA_SCRIPT
        chown -Rf mysql:mysql /data/mysql
        rm -Rf /var/lib/mysql >>/dev/logs 2>&1
        ln -s /data/mysql /var/lib/mysql >>/dev/logs 2>&1
        source $START_SERVICES_SCRIPT
        sleep 20
    fi
    source $CLEANUP_SCRIPT
fi
echo "Starting the container"
source $RESTART_SERVICES_SCRIPT
echo "---=== [ READY! ] ===---"
sleep infinity
