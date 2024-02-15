#!/bin/sh

## NOTE: The order in which the services and processes are run and started matters and do not simply change them without knowing what you are doing

set -e

mkdir -p /data/logs/

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SETUP_SERVICES=$SCRIPT_DIR/setup-services.sh
SETUP_NEW_WIKI=$SCRIPT_DIR/setup-new-wiki.sh
BACKUP_WIKI=$SCRIPT_DIR/backup-wiki.sh
RESTORE_WIKI=$SCRIPT_DIR/restore-wiki.sh
START_SERVICES=$SCRIPT_DIR/start-services.sh

# if both mysql folder and localsettings file does not exit then do a fresh install
if ! [[ -d "/data/mysql" ]] && ! [[ -f "/data/www/bluespice/w/LocalSettings.php" ]]; then
    # no previous installation of wiki found, so do a fresh install
    source $SETUP_SERVICES
    source $SETUP_NEW_WIKI
else # else handle reinstall
    if [ -f "/opt/docker/.firstrun" ]; then # check if its a first time created container, the do a reinstall of the wiki (this will also update the wiki in case its a new docker image)
    source $BACKUP_WIKI # backup wiki first
    source $SETUP_SERVICES
    source $SETUP_NEW_WIKI
    source $RESTORE_WIKI # restore the prev data
    fi
    # just restart the services
    source $START_SERVICES
fi


echo "---=== [ READY! ] ===---" >>/data/logs/wiki.logs 2>&1
tail -f /data/logs/wiki.logs