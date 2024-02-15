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
BSPATH=`echo "$1" | sed -e 's#/$##'`

/bin/chmod -Rf 755 $BSPATH
/bin/chown -Rf root:root $BSPATH

/usr/bin/find $BSPATH -type f > $BSFILELIST
/usr/bin/find $BSPATH -type d > $BSDIRLIST

while IFS= read -r files 
do 
	if [[ $files == *"pygmentize"* ]]; then
		/bin/chmod +x $files
	else 
	   /bin/chmod -f 644 $files
	fi
done < "$BSFILELIST" &

while IFS= read -r dirs 
do 
	/bin/chmod -f 755 $dirs
done < "$BSDIRLIST" &

paths=(
	"$BSPATH/cache" \
	"$BSPATH/images" \
	"$BSPATH/_sf_archive" \
	"$BSPATH/_sf_instances" \
	"$BSPATH/extensions/BlueSpiceFoundation/data" \
	"$BSPATH/extensions/BlueSpiceFoundation/config" \
	"$BSPATH/extensions/Widgets/compiled_templates" \
)
for i in "${paths[@]}"; do
	if [ -d $i ]; then
		/bin/chown -R $WWW_USER:$WWW_GROUP $i
	fi
done

/usr/bin/find $BSPATH/extensions -iname 'create_pygmentize_bundle' -exec /bin/chmod +x {} \;
/usr/bin/find $BSPATH/extensions -name 'lua' -type f -exec /bin/chmod 755 {} \;
