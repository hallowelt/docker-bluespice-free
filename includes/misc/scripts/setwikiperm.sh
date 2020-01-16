#!/bin/bash
WWW_USER="www-data"
WWW_GROUP="www-data"
BSFILELIST="/tmp/bs_filelist.dat"
BSDIRLIST="/tmp/bs_dirlist.dat"

if [ $# -eq 0 ]; then
	echo "You must enter the path of your MediaWiki installation."
	exit
elif [ ! -d $1 ]; then
	echo "$1 does not exist or is no path."
	exit
fi
PATH=`echo "$1" | sed -e 's#/$##'`

/bin/chmod -Rf 755 $PATH
/bin/chown -Rf root:root $PATH

/usr/bin/find $PATH -type f > $BSFILELIST
/usr/bin/find $PATH -type d > $BSDIRLIST

while IFS= read -r files 
do 
	/bin/chmod -f 644 $files 
done < "$BSFILELIST" &

while IFS= read -r dirs 
do 
	/bin/chmod -f 755 $dirs
done < "$BSDIRLIST" &

paths=(
	"$PATH/cache" \
	"$PATH/images" \
	"$PATH/_sf_archive" \
	"$PATH/_sf_instances" \
	"$PATH/extensions/BlueSpiceFoundation/data" \
	"$PATH/extensions/BlueSpiceFoundation/config" \
	"$PATH/extensions/Widgets/compiled_templates" \
)
for i in "${paths[@]}"; do
	if [ -d $i ]; then
		/bin/chown -R $WWW_USER:$WWW_GROUP $i
	fi
done

/usr/bin/find $PATH/extensions -iname 'create_pygmentize_bundle' -exec /bin/chmod +x {} \;
/usr/bin/find $PATH/extensions -iname 'pygmentize' -exec /bin/chmod +x {} \;
/usr/bin/find $PATH/extensions -name 'lua' -type f -exec /bin/chmod 755 {} \;