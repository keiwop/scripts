#!/bin/sh
pathGAME="/afs/deptinfo-st.univ-fcomte.fr/public/.OpenArena/"
GAME="openarena-0.8.8.zip"
baseGAME="`basename $GAME .zip`"
execGAME="openarena.i386"

if [ ! -e /tmp/$GAME ]; then
	echo "Copying openarena to /tmp"
	rsync --progress -h $pathGAME$GAME /tmp/$GAME
else
	echo "$GAME already present in /tmp"
fi

if [ ! -e /tmp/$baseGAME ]; then
	echo "Unzipping the game"
	unzip /tmp/$GAME -d /tmp/
fi

xgamma -gamma 1.7

ls /tmp/
/tmp/$baseGAME/$execGAME
