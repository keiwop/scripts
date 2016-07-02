#! /bin/sh

#Written by Maxime Martin
#Feel free to make what you want from it.
#Licensed under the WTFPL2+

LIST_DIR="/_/etc"
LIST_FILE="$LIST_DIR/hide_apps_list"
WORKING_DIR="/usr/share/applications"
SHOW=false
LIST=true

function print_usage(){
cat<<EOF
Usage: $0 <file> [file_list]

Hide application from launcher in gnome by appending "NoDisplay=true" at the end
of the concerned .desktop filename.
	
You can use a file containing every .desktop filenames you want to hide. 
Use $0 file_list. There is one included on my github (keiwop).
Or you can specify directly a .desktop file.

This script will ask for your sudo password to be able to make the modifications.
EOF
}

function print_help(){
cat<<EOF
This is the list of parameters.
	-h, --help		Show this screen
	-l, --list		Use a list containing all filenames
	-f, --file		Use a single .desktop file
	-m, --hide		Will hide the files given
	-s, --show		Will show the files given
You can use a filename or a list without specifying the --list or --file argument. They're just here if you absolutely want to use them
EOF
}

function show_apps(){
	cd $WORKING_DIR
	echo "Show apps"
	if ($LIST); then
		for i in `cat $LIST_FILE`; do
			if [ -e $i ]; then
				if [ "`cat $i | grep "#NoDisplay"`" = "#NoDisplay=true" ]; then
					echo -ne "$i is already modified\n"
				elif [ "`cat $i | grep "NoDisplay"`" = "NoDisplay=true" ]; then
					sudo su -c "sed -re 's:^NoDisplay=true:#NoDisplay=true:' $i -i"
					echo -ne ">\t$i has been turned visible\n"
				else
					echo -ne ">\t$i has never been modified"
				fi
			else
				echo -ne ">>\t\t$i doesn't exists\n"
			fi
		done
	else
		i="$LIST_FILE"
		if [ -e $i ]; then
			if [ "`cat $i | grep "#NoDisplay"`" = "#NoDisplay=true" ]; then
				echo -ne "$i is already modified\n"
			elif [ "`cat $i | grep "NoDisplay"`" = "NoDisplay=true" ]; then
				sudo su -c "sed -re 's:^NoDisplay=true:#NoDisplay=true:' $i -i "
				echo -ne ">\t$i has been turned visible\n"
			else
				echo -ne ">\t$i has never been modified"
			fi
		else
			echo -ne ">>\t\t$i doesn't exists\n"
		fi
	fi
}

function hide_apps(){
	cd $WORKING_DIR
	if ($LIST); then
		for i in `cat $LIST_FILE`; do
			if [ -e $i ]; then
				if [ "`cat $i | grep "#NoDisplay"`" = "#NoDisplay=true" ]; then
					sudo su -c "sed -re 's:^#NoDisplay=true:NoDisplay=true:' $i -i"
					echo -ne ">\t$i has been turned invisible\n"
				elif [ "`cat $i | grep "NoDisplay" | tail -1`" = "NoDisplay=true" ]; then
					echo -ne "$i is already modified\n"
				else
					if [ -n "`cat $i | grep "Actions="`" ]; then
						declare -i nb_line
						nb_line="`cat $i | grep "Actions=" -n | cut -d":" -f1`"
						nb_line=$nb_line-1
#						echo $nb_line
						sudo su -c "sed -ri $nb_line'i\NoDisplay=true' $i"
					else
						sudo su -c "echo \"NoDisplay=true\" >> $i"
					fi
					echo -ne ">\t$i has been turned invisible\n"
				fi
			else
				echo -ne ">>\t\t$i doesn't exists\n"
			fi
		done
	else
		i="$LIST_FILE"
		if [ -e $i ]; then
			if [ "`cat $i | grep "#NoDisplay"`" = "#NoDisplay=true" ]; then
				sudo su -c "sed -re 's:^#NoDisplay=true:NoDisplay=true:' $i -i"
				echo -ne ">\t$i has been turned invisible\n"
			elif [ "`cat $i | grep "NoDisplay"`" = "NoDisplay=true" ]; then
				echo -ne "$i is already modified\n"
			else
				sudo su -c "echo \"NoDisplay=true\" >> $i"
				echo -ne ">\t$i has been turned invisible\n"
			fi
		else
			echo -ne ">>\t\t$i doesn't exists\n"
		fi
	fi
}

function get_parameters(){
	echo "Get parameters"
}

if [ $# -eq 0 ]; then
	print_usage
	exit
fi

while [ $# -gt 0 ]; do
	if [ $1 = "--help" ] || [ $1 = "-h" ]; then
		print_help
		exit
	elif [ $1 = "--list" ] || [ $1 = "-l" ]; then
		LIST_FILE="`readlink -f $2`"
		LIST=true
	elif [ $1 = "--file" ] || [ $1 = "-f" ]; then
		LIST=false
	elif [ $1 = "--hide" ] || [ $1 = "-m" ]; then
		SHOW=false
	elif [ $1 = "--show" ] || [ $1 = "-s" ]; then
		SHOW=true
	elif [ -f $1 ]; then
		if [ `echo "$1" | awk -F . '{print $NF}'` = "desktop" ]; then
			LIST=false
			LIST_FILE="`readlink -f $1`"
		else
			LIST=true
			LIST_FILE="`readlink -f $1`"
		fi
	fi
	shift
done

if ( $SHOW ); then
	show_apps
else
	hide_apps
fi


