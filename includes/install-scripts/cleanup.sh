#!/bin/bash

rm -f /opt/docker/.firstrun
/opt/docker/setwikiperm.sh /data/www/bluespice/w

# Pingback
if [[ $DISABLE_PINGBACK != "yes" ]];
then
    /usr/local/bin/phantomjs --ignore-ssl-errors=true --ssl-protocol=any /opt/docker/pingback.js
fi