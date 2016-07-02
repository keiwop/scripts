#! /bin/sh

PATH_DESKTOP="/usr/share/applications"
PATH_ICONS="/_/img/icons/test_icons"
CHANGE_ICONS=true
FILE_ONLY=false

LIST_IMG_USED=""
declare -i COUNT_IMG_USED
COUNT_IMG_USED=0
LIST_IMG_NOT_USED=""
declare -i COUNT_IMG_NOT_USED
COUNT_IMG_NOT_USED=0

function print_usage(){
cat<<EOF
Usage: $0 [--change, --file, --restore]

Change the icons of .desktop launchers.
Your icons must have the same basename as the .desktop for the program to find them.
More options will be present in the future, as a restore function, or the choice to 
select any .desktop to modify.

This script will ask for your sudo password to be able to make the modifications.
EOF
}

function print_help(){
cat<<EOF
This is the list of parameters.
	-h, --help		Show this screen
	-c, --change	Change the icons ( By default )
	-f, --file		Use a single .desktop file
	-r, --restore	Restore the .desktop to original icons
EOF
}

function change_icons(){
	echo "Changing icons"
	
	cd $PATH_ICONS
	for img in *; do
		img_noext="`echo $img | cut -d"." -f1`"
		img_used=false
		cd $PATH_DESKTOP
#		FIXME Message from 2016 me to old me: My god, it's so ugly
		for desktop in *.desktop; do
			desktop_noext="`echo $desktop | cut -d"." -f1`"
			if [ $desktop_noext = $img_noext ]; then
				echo "EQUALS"
				echo "Desktop : $desktop_noext = Img : $img_noext"
				img_path="$PATH_ICONS/$img"
				img_used=true
				sudo su -c "sed -ri 's:^Icon=.*:Icon=$img_path:g' $desktop"
			fi
		done
		if ( $img_used ); then
			LIST_IMG_USED="$LIST_IMG_USED $img"
			COUNT_IMG_USED=$COUNT_IMG_USED+1
		else
			LIST_IMG_NOT_USED="$LIST_IMG_NOT_USED $img"
			COUNT_IMG_NOT_USED=$COUNT_IMG_NOT_USED+1
		fi
	done
	echo
	echo "$COUNT_IMG_USED icons used : "
	echo "$LIST_IMG_USED"
	echo "$COUNT_IMG_NOT_USED icons unused : "
	echo "$LIST_IMG_NOT_USED"	
}

function restore_icons(){
	echo "Restoring icons"
}

if [ $# -eq 0 ]; then
	change_icons
	exit
fi

while [ $# -gt 0 ]; do
	if [ $1 = "--help" ] || [ $1 = "-h" ]; then
		print_help
		exit
	elif [ $1 = "--change" ] || [ $1 = "-c" ]; then
		CHANGE_ICONS=true
	elif [ $1 = "--file" ] || [ $1 = "-f" ]; then
		FILE_ONLY=true
	elif [ $1 = "--restore" ] || [ $1 = "-r" ]; then
		CHANGE_ICONS=false
#	elif [ -f $1 ]; then
#		if [ `echo "$1" | awk -F . '{print $NF}'` = "desktop" ]; then
#			LIST=false
#			LIST_FILE="`readlink -f $1`"
#		else
#			LIST=true
#			LIST_FILE="`readlink -f $1`"
#		fi
#	fi
	shift
done

if ( $CHANGE_ICONS ); then
	change_icons
else
	restore_icons
fi
