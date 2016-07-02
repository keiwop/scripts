#! /bin/sh
states=()
old_states=()
state_change_time=()
last_state_duration=()
#time_state_duration=""
#time_last_state_duration=""
#column_names="n° device label state state_duration last_duration read write"
#columns_size=(2 12 12 8 16 16 12 12)
#columns_name=("n°" "device" "label" "state" "state_duration" "last_duration" "read" "write")
#header_column_format="%2s %12s %12s %8s %16s %16s %12s %12s\n"
#device_column_format="%2s %12s %12s %8s %16s %16s %12s %12s\n"
#output=$(mktemp)
#output="/dev/stdout"
output=""
_log_file="/var/log/disks_states.log"
#_formatting="%2d %12s %12s %12s %12s %12s\n"
echo -e "\0033\0143"


#add_column(){
#	columns

#}

columns_name=("n°" "device" "label" "state" "state duration" "last duration" "read" "write")
columns_width=(3 12 12 9 16 16 12 12)
device_data=()


create_line(){
	arg1="$1[@]"
	columns_value=("${!arg1}")
	arg2="$2[@]"
	columns_size=("${!arg2}")
	
	let i=0
	for column_value in "${columns_value[@]}"; do
		nb_spaces=$(( ${columns_size[$i]} - ${#column_value} ))
		
		spaces_before=$(( $nb_spaces / 2 ))
		spaces_after=$spaces_before
		if [[ $(( $nb_spaces % 2 )) -eq 1 ]]; then
			let spaces_before++
		fi
		
		printf "%${spaces_before}s%${#column_value}s%${spaces_after}s|" "" "${column_value}" ""
		let i++
	done
#	printf "\n"
}


format_time(){
	time_format="%-S"
	if [[ $1 -ge 60 ]]; then
		time_format="%-M:%S"
	fi
	if [[ $1 -ge 3600 ]]; then
		time_format="%-H:%M:%S"
	fi

	time_formatted=$(date -u -d @$1 +$time_format)
	if [[ $1 -eq 0 ]]; then
		time_formatted="Ø"
	fi
	
	printf "${time_formatted}"
}


format_size(){
#	TODO format size in KiB instead of KB
	size=$1
	size_formatted=""
	
	size_GB=$(( $size / 1000000 ))
	size=$(( $size % 1000000 ))
	size_MB=$(( $size / 1000 ))
	size=$(( $size % 1000 ))
#	printf "GB: $size_GB\n"
#	printf "MB: $size_MB\n"
#	printf "KB: $size\n"
	
	if [[ $size_GB -gt 0 ]]; then
		size_formatted="${size_GB}.${size_MB}G"
	elif [[ $size_MB -gt 0 ]]; then
		rest=$(( $size / 100 ))
		size_formatted="${size_MB}.${rest}M"
	else
		size_formatted="${size}K"
	fi
	
	printf "$size_formatted"
#	if [[ $1 -ge 1000 ]]; then
#		size=$(( $1 / 1000 ))
#		rest=$(( $1 / 1000 ))
#	fi
#	if
	
	
}


while true; do
	term_width=$(tput cols)
#	TODO test if enough place for displaying time
	header_data=$(create_line columns_name columns_width)
	header_data_format="\e[1;46m${header_data}\e[0m"
	current_time=$(date +"%y-%m-%d %H:%M:%S")
	current_time_format="\e[1;37;45m${current_time}\e[0m"
	blank_size=$(( $term_width - ${#header_data} - ${#current_time} ))

	header=$(printf "${header_data_format}%${blank_size}s%${#current_time}s" "" "${current_time_format}")
	output="$header"
	
	device_nb=0
	device_state="none"
	
	
	for device in /dev/sd*; do
	#	Ignore the devices containing a digit in the name.
		echo "$device"  | grep -q "[0-9]"
		if [[ $? -ne 0 ]]; then


#			Getting the device label
			device_label=""
			for _label in /dev/disk/by-label/*; do
				readlink -f $_label | grep -q $device
				if [[ $? -eq 0 ]]; then
					if ! [[ -n $device_label ]]; then
						device_label=`basename $_label`
						if [[ $device_label = "ARCH_EFI" ]]; then
							device_label="arch"
						elif [[ $device_label = "Recovery" ]]; then
							device_label="windows"
						fi
#						echo "label: $device_label"
					fi
				fi
			done


#			Getting the device state: active or standby
			sudo hdparm -C $device | grep -q "active"
			if [[ $? -eq 0 ]]; then
				device_state="active"
			else
				device_state="standby"
			fi
			states[$device_nb]=$device_state


#			Checking if the state of the device has changed
			if [[ ${states[$device_nb]} != ${old_states[$device_nb]} ]]; then
				if [[ -n ${state_change_time[$device_nb]} ]]; then
#					If the state changed, then we calculate the last state duration
					last_state_duration[$device_nb]=$(($(date "+%s") - ${state_change_time[$device_nb]}))
					printf "%8s, %8s, %12s, %24s, %22s\n" \
						$device $device_label ${states[$device_nb]} "`date +\"%s+%N\"`" "`date +\"%y-%m-%d %H:%M:%S\"`" >> $_log_file
				fi
				state_change_time[$device_nb]=$(date +"%s")
			fi
			old_states[$device_nb]=$device_state
			
			
#			Calculating the duration of the current state
			state_duration=$(($(date +"%s") - ${state_change_time[$device_nb]}))
			if ! [[ -n ${last_state_duration[$device_nb]} ]]; then
				last_state_duration[$device_nb]="0"
			fi
			
			
#			Getting the device IO stats
			array_iostat=($(iostat -dk $device | grep `basename $device`))
			device_read="${array_iostat[4]}"
			device_write="${array_iostat[5]}"
			
			
#			Printing the result to the output and going to the next device
			sd_format=$(format_time ${state_duration})
			lsd_format=$(format_time ${last_state_duration[$device_nb]})
			read_format=$(format_size ${device_read})
			write_format=$(format_size ${device_write})
#			format_size $device_read
			
			device_data=($device_nb $device $device_label $device_state $sd_format $lsd_format $read_format $write_format)
			device_info=$(create_line device_data columns_width)
			device_info_format="\e[1;36m${device_info}\e[0m"
			output="$output\n$device_info_format"
			device_nb=$(($device_nb + 1))
		fi
	done

#	Sending ^[c character to clean the screen
	echo -e "\0033\0143"
#	clear
	echo -e "$output"
	sleep 1

done

