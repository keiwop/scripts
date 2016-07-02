#!/bin/sh
#Deodex the files from a decompiled apk

rm -R out;
rm classes.dex

if [ $1 == "app/" ] || [ $1 == "app" ] ; then
	echo "$1"
	nb=$(cd app/ ; ls -l --hide=*.apk | wc -l)
	
elif [ $1 == "framework/" ] || [ $1 == "framework" ] ; then
	
	cd framework/
	#echo "$1"
	nb=$(ls -l --hide=*.jar --hide=*.apk | wc -l)
	echo $nb
	i=1

	while [ $i -le $nb ]
	do   
		rm -R out;
		rm classes.dex;
		name=$(ls | grep .jar | head -$i | tail -1)
		name=$(basename $name .jar)
		echo "$name"
	
		baksmali -a 14 -x $name.odex
		smali out -o classes.dex;

		jar -uf $name.jar classes.dex;
		
		i=$[ i + 1 ]
	done
fi

