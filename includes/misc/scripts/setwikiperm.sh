#!/bin/bash

WWW_USER="www-data"
WWW_GROUP="www-data"

WWW_HOME=`eval echo ~$WWW_USER`
WWW_CFG=$WWW_HOME/.config

if [ $# -eq 0 ]; then
	echo "You must enter the path of your MediaWiki installation."
	exit
elif [ ! -d $1 ]; then
	echo "$1 does not exist or is no path."
	exit
fi

PATH=`echo "$1" | sed -e 's#/$##'`

/usr/bin/find $PATH -type d -exec /bin/chmod 755 {} \;
/usr/bin/find $PATH -type f -exec /bin/chmod 644 {} \;

/bin/chown -R root:root $PATH

pathes=(
	"$PATH/cache" \
	"$PATH/images" \
	"$PATH/_sf_archive" \
	"$PATH/_sf_instances" \
	"$PATH/extensions/BlueSpiceFoundation/data" \
	"$PATH/extensions/BlueSpiceFoundation/config" \
	"$PATH/extensions/Widgets/compiled_templates" \
)

for i in "${pathes[@]}"; do
	if [ -d $i ]; then
		/bin/chown -R $WWW_USER:$WWW_GROUP $i
	fi
done

if [ ! -d $WWW_CFG ]; then
	/bin/mkdir $WWW_CFG
fi

/bin/chown -R $WWW_USER:$WWW_GROUP $WWW_CFG

/usr/bin/find $PATH/extensions -iname 'create_pygmentize_bundle' -exec /bin/chmod +x {} \;
/usr/bin/find $PATH/extensions -iname 'pygmentize' -exec /bin/chmod +x {} \;
/usr/bin/find $PATH/extensions -name 'lua' -type f -exec /bin/chmod 755 {} \;