#!/bin/sh
#Script emptying the trash and deleting the cache on the university computers
#Should be launched at login from a bashrc or the bash equivalent of .zlogin

CHROME_LOCK="$HOME/.config/google-chrome/SingletonLock"
CHROME_CONF="$HOME/.config/google-chrome"
FIREFOX="$HOME/.mozilla"
TRASH="$HOME/.local/share/Trash"
CACHE="$HOME/.cache"

echo -e "\e[31m""bash init script""\e[m"

if [ -L $CHROME_LOCK ]; then
	echo "	$CHROME_LOCK"
	rm -fv $CHROME_LOCK
fi

if [ -d $TRASH ]; then
	cd $TRASH
	echo "	$TRASH"
	if [ `ls $TRASH/files/ | wc -l` -eq 0 ]; then
		echo "	Trash is already empty"
	elif [ -d $TRASH/files ]; then
		rm -rvf $TRASH/files/* 
		rm -rvf $TRASH/info/*
		echo "	Trash is now empty"
	fi
fi

if [ -d $CACHE ]; then
	echo "	$CACHE"
	rm -rvf $CACHE/* 2> /dev/null
fi

if [ -d $FIREFOX ]; then
	rm -rvf $FIREFOX
fi

echo -e "\e[31m""init done""\e[m"

cd
