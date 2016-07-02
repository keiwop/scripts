#! /bin/sh
states=()
old_states=()
state_change_time=()
last_state_duration=()
auto_resize=true
custom_width="80"
output=""
term_width="10"
_log_file="/var/log/arch_desktop.log"

echo -e "\0033\0143"

#TODO dynamix resizing
#TODO CPU & GPU processes
#TODO Network info


create_line(){
#	TODO explain how I pass an array as a parameter
	arg1="$1[@]"
	columns_value=("${!arg1}")
	arg2="$2[@]"
	columns_size=("${!arg2}")
	
	let i=0
	let total_column_size=0
	for column_size in "${columns_size[@]}"; do
		let columns_size[$i]=$term_width*$column_size/100
		let total_column_size=$total_column_size+${columns_size[$i]}
		let i++
	done;
	
	let padding_size=$term_width-$total_column_size
	let i=0
	for column_value in "${columns_value[@]}"; do
		nb_spaces=$(( ${columns_size[$i]} - ${#column_value} - 1 ))
#		If we are at the last column, add some spaces to make all the columns stop at the same place with auto_resizing
		if [[ $i -eq $(( ${#columns_value[@]} - 1 )) ]]; then
			nb_spaces=$(( $nb_spaces + $padding_size))
		fi
		
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
#	TODO Bug if time > 24h
	time_format="%-S"
	if [[ $1 -ge 60 ]]; then
		time_format="%-M:%S"
	fi
	if [[ $1 -ge 3600 ]]; then
		time_format="%-H:%M:%S"
	fi

	if [[ $1 -eq 0 ]]; then
		time_formatted="Ø"
	else
		time_formatted=$(date -u -d @$1 +$time_format)
#		echo -e "time: $time_formatted"
	fi
	
	printf "${time_formatted}"
}


format_size(){
#	TODO format size in KiB instead of KB
	size=$1
	size_formatted=""
	
	if [[ $2 = "M" ]]; then
		size=$(( $size * 1000 ))
	fi
	
	size_GB=$(( $size / 1000000 ))
	size=$(( $size % 1000000 ))
	size_MB=$(( $size / 1000 ))
	size=$(( $size % 1000 ))
	
	if [[ $size_GB -gt 0 ]]; then
		size_formatted="${size_GB}.${size_MB}G"
	elif [[ $size_MB -gt 0 ]]; then
		rest=$(( $size / 100 ))
		size_formatted="${size_MB}.${rest}M"
	else
		size_formatted="${size}K"
	fi
	
	printf "$size_formatted"
}


get_machine_info_readonly(){
	readonly machine_hostname=$(hostname)
	readonly machine_update=$(uptime -s)
	machine_memory=($(free --kilo | grep "Mem" | cut -d":" -f2))
	machine_swap=($(free --kilo | grep "Swap" | cut -d":" -f2))
	readonly total_memory=$(format_size ${machine_memory[0]})
	readonly total_swap=$(format_size ${machine_swap[0]})
	
	readonly cpu_name=$(lscpu | grep -oP "Model name:.* \Ki[0-9]-[0-9]+[a-zA-Z]*")
	readonly cpu_threads=$(lscpu | grep -oP "On-line.*:.*\K[0-9]+-[0-9]+")
	readonly cpu_max_freq=$(lscpu | grep -oP "CPU max MHz: *\K[0-9]+")
	
#	TODO recognize other type of GPU
	gpu=$(nvidia-smi -q)
	readonly gpu_name=$(echo "$gpu" | grep -oP "Product Name.*: \K.*")
	readonly gpu_driver=$(echo "$gpu" | grep -oP "Driver Version.*: \K.*")
	readonly gpu_total_memory=$(format_size $(echo "$gpu" | grep -A3 "FB Memory" | grep -oP "Total.*: \K[0-9]+") "M")
	readonly gpu_power_limit=$(echo "$gpu" | grep -A3 "Power Readings" | grep -oP "Power Limit.*: \K[0-9]+")
}


#	$1 is the device, ie: "/dev/sda"
get_device_label(){
	device_label=$(lsblk $1 -o label | tail -n+2 | grep -oP -m1 "\K.+")
	if ! [[ -n $device_label ]]; then
		device_label="none"
	fi
	
	if [[ $device_label = "ARCH_EFI" ]]; then
		device_label="arch"
	elif [[ $device_label = "Recovery" ]]; then
		device_label="windows"
	fi
	retval="$device_label"
}


#	$1 is the device, ie: "/dev/sda"
get_device_state(){
	sudo hdparm -C $1 | grep -q "active"
	if [[ $? -eq 0 ]]; then
		device_state="active"
	else
		device_state="standby"
	fi
	retval="$device_state"
}


#	$1 is the device, ie: "/dev/sda"
#	$2 is the device number, ie: "/dev/sda" -> 0
#	$3 is the device label, ie: "/dev/sda" -> "arch"
check_device_state_change(){
	if [[ ${states[$2]} != ${old_states[$2]} ]]; then
		if [[ -n ${state_change_time[$2]} ]]; then
#			If the state changed, then we calculate the last state duration
			last_state_duration[$2]=$(($(date "+%s") - ${state_change_time[$2]}))
#			TODO rework logging
			printf "%8s, %8s, %12s, %24s, %22s\n" \
				$1 $3 ${states[$2]} "`date +\"%s+%N\"`" "`date +\"%y-%m-%d %H:%M:%S\"`" >> $_log_file
		fi
		state_change_time[$2]=$(date +"%s")
	fi
}


#	$1 is the device, ie: "/dev/sda"
#	$2 is the device number, ie: "/dev/sda" -> 0
get_state_duration(){
#	TODO Calculate the duration from the log
	state_duration=$(($(date +"%s") - ${state_change_time[$2]}))
	if ! [[ -n ${last_state_duration[$2]} ]]; then
		last_state_duration[$2]="0"
	fi
	retval="$state_duration"
}


#	$1 is the time before the execution of the main loop
#	$2 is the time after the execution of the main loop
get_sleep_time(){
	exec_time=$(( $2 - $1 ))
	if [[ $exec_time -le 1000 ]]; then
		sleep_time=$(( 1000 - $exec_time ))
	else
		sleep_time=1000
	fi
	sleep_time=$(bc <<< "scale=3; $sleep_time / 1000" )
	printf "0${sleep_time}"
}


# 	No parameters, but it uses the global variable $custom_width to set the width of the app
# 	$custom_width can have the value "max" or any number
# 	if $custom_width is between 1-100 and $auto_resize is enabled, the app's width will be 1-100% of the terminal size
get_terminal_width(){
	if [[ $custom_width = "max" ]]; then
		echo "$(tput cols)"
	elif ( $auto_resize ) && [[ $custom_width -le 100 ]]; then
		let app_width=$(tput cols)*$custom_width/100
		echo "$app_width"
	else
		echo "$custom_width"
	fi
}


get_cpu_processes(){
#	echo -e "${cpu_processes_sort_cpu}\n"
#	cpu_processes_sort_cpu=$(ps --sort=-pcpu -Ao pid,tty,pcpu,pmem,comm | head -n 4)
#	cpu_processes_sort_mem=$(ps --sort=-pmem -Ao pid,tty,pcpu,pmem,comm | head -n 4)
#	TODO top takes a shitload of time to execute, try to find something better
	cpu_processes_sort_cpu=$(top -b -n1 -o %CPU)
	cpu_processes_sort_mem=$(top -b -n1 -o %MEM)
	nb_processes=4
	
	
	cpu_processes_columns_name=("pid" "user" "cpu" "mem" "cmd" "pid" "user" "cpu" "mem" "cmd")
	cpu_processes_columns_width=(8 10 8 8 16 8 10 8 8 16)
	cpu_processes_columns=$(printf "\e[1;40m$(create_line cpu_processes_columns_name cpu_processes_columns_width)\e[0m\n")
	printf "${cpu_processes_columns}\n"
	
	for i in $(seq 1 $nb_processes); do
		processes_cpu=($(echo "${cpu_processes_sort_cpu}" | head -n+$(( $i + 14 )) | tail -n1))
		processes_mem=($(echo "${cpu_processes_sort_mem}" | head -n+$(( $i + 14 )) | tail -n1))
		cpu_processes_data=("${processes_cpu[0]}" "${processes_cpu[1]}" "${processes_cpu[6]}" "${processes_cpu[7]}" "${processes_cpu[10]}" "${processes_mem[0]}" "${processes_mem[1]}" "${processes_mem[6]}" "${processes_mem[7]}" "${processes_mem[10]}")
		cpu_processes_line=$(printf "\e[1;36m$(create_line cpu_processes_data cpu_processes_columns_width)\e[0m\n")
		printf "${cpu_processes_line}\n"
	done
}


get_gpu_processes(){
#	TODO sort processes by mem usage
	gpu_processes=$(nvidia-smi -q -d PIDS)
	gpu_pids=($(echo -e "$gpu_processes" | grep -oP "Process ID.*: \K[0-9]+" | tr "\n" " "))
	gpu_allocs=($(echo -e "$gpu_processes" | grep -oP ".*Memory.*: \K[0-9]+" | tr "\n" " "))
	gpu_commands=($(echo -e "$gpu_processes" | grep -oP "Name.*: \K/[a-zA-Z0-9/_.-]+" | tr "\n" " "))
	nb_processes=2
	
	gpu_processes_columns_name=("pid" "mem" "cmd" "pid" "mem" "cmd")
	gpu_processes_columns_width=(8 10 32 8 10 32)
	gpu_processes_columns=$(printf "\e[1;42m$(create_line gpu_processes_columns_name gpu_processes_columns_width)\e[0m\n")
	printf "${gpu_processes_columns}\n"
	
	for i in $(seq 0 $(( $nb_processes - 1 ))); do
#		printf "CMD: ${gpu_commands[$i]}\n"
		if [[ -n ${gpu_pids[$i]} ]]; then
			pid_1="${gpu_pids[$i]}"
			alloc_1="${gpu_allocs[$i]} MiB"
			cmd_1="$(basename ${gpu_commands[$i]})"
		fi
		
		if [[ -n ${gpu_commands[$(( $i + $nb_processes ))]} ]]; then
			pid_2="${gpu_pids[$(( $i + $nb_processes ))]}"
			alloc_2="${gpu_allocs[$(( $i + $nb_processes ))]} MiB"
			cmd_2="$(basename ${gpu_commands[$(( $i + $nb_processes ))]})"
		fi		
		
		gpu_processes_data=("$pid_1" "$alloc_1" "$cmd_1" "$pid_2" "$alloc_2" "$cmd_2")
		gpu_processes_line=$(printf "\e[1;36m$(create_line gpu_processes_data gpu_processes_columns_width)\e[0m\n")
		printf "${gpu_processes_line}\n"
	done
}


get_machine_info(){
	machine_uptime=$(uptime -p | cut -d" " -f2-)
	machine_memory=($(free --kilo | grep "Mem" | cut -d":" -f2))
	machine_swap=($(free --kilo | grep "Swap" | cut -d":" -f2))
	used_memory=$(format_size ${machine_memory[1]})
	used_swap=$(format_size ${machine_swap[1]})
	
	machine_columns_name=("machine" "mem" "swap" "uptime")
	machine_columns_width=(20 24 24 32)
	machine_data=("$machine_hostname" "(${used_memory} / ${total_memory})" "(${used_swap} / ${total_swap})" "${machine_uptime}")

	machine_columns=$(printf "\e[1;41m$(create_line machine_columns_name machine_columns_width)\e[0m\n")
	machine_line=$(printf "\e[1;36m$(create_line machine_data machine_columns_width)\e[0m\n")
	retval="${machine_columns}\n${machine_line}"
}


get_cpu_info(){
	cpu_load=$(cat /proc/loadavg)
	cpu_freq=$(lscpu | grep -oP "CPU MHz: *\K[0-9]+")
	cpu_temp=$(( $(cat "/sys/class/thermal/thermal_zone0/temp") / 1000 ))
	cpu_fan=$(sensors | grep -oP "^fan3: *\K[0-9]+")
	
	cpu_columns_name=("CPU" "threads" "load" "temp" "fan" "freq")
	cpu_columns_width=(20 10 32 10 8 20)
	cpu_data=("$cpu_name" "$cpu_threads" "${cpu_load}" "${cpu_temp}°C" "${cpu_fan} RPM" "(${cpu_freq}MHz / ${cpu_max_freq}MHz)")

	cpu_columns=$(printf "\e[1;43m$(create_line cpu_columns_name cpu_columns_width)\e[0m\n")
	cpu_line=$(printf "\e[1;36m$(create_line cpu_data cpu_columns_width)\e[0m\n")
	cpu_processes=$(get_cpu_processes)
	retval="${cpu_columns}\n${cpu_line}\n${cpu_processes}"
}


get_gpu_info(){
#	TODO Calculate gpu fan in RPM
	gpu=$(nvidia-smi -q)
	gpu_temp=$(echo "$gpu" | grep -oP "GPU Current Temp.*: \K[0-9]+")
	gpu_fan=$(echo "$gpu" | grep -oP "Fan Speed.*: \K[0-9]+")
	gpu_used_memory=$(format_size $(echo "$gpu" | grep -A3 "FB Memory" | grep -oP "Used.*: \K[0-9]+") "M")
	gpu_load=$(echo "$gpu" | grep -A4 "Utilization" | grep -oP "Gpu.*: \K[0-9]+")
	gpu_power_draw=$(echo "$gpu" | grep -oP "Power Draw.*: \K[0-9.]+")

	gpu_columns_name=("GPU" "driver" "load" "mem" "temp" "fan" "power")
	gpu_columns_width=(20 12 10 20 10 8 20)
	gpu_data=("$gpu_name" "$gpu_driver" "${gpu_load}" "(${gpu_used_memory} / ${gpu_total_memory})" "${gpu_temp}°C" "${gpu_fan}" "(${gpu_power_draw}W / ${gpu_power_limit}W)")

#	TODO bug with percentage
	gpu_columns=$(printf "\e[1;44m$(create_line gpu_columns_name gpu_columns_width)\e[0m\n")
	gpu_line=$(printf "\e[1;36m$(create_line gpu_data gpu_columns_width)\e[0m\n")
	gpu_processes=$(get_gpu_processes)
	retval="${gpu_columns}\n${gpu_line}\n${gpu_processes}"
}


get_disk_info(){
	disk_columns_name=("n°" "device" "label" "state" "state duration" "last duration" "read" "write")
	disk_columns_width=(4 14 14 12 16 16 12 12)
	result=$(printf "\e[1;46m$(create_line disk_columns_name disk_columns_width)\e[0m\n")
	device_nb=0
	device_label="none"
	
	for device in /dev/sd*; do
	#	Ignore the devices containing a digit in the name.
		echo "$device"  | grep -q "[0-9]"
		if [[ $? -ne 0 ]]; then

#			Getting the device label
			get_device_label "$device"
			device_label=$retval

#			Getting the device state: active or standby
			get_device_state "$device"
			device_state=$retval
			states[$device_nb]="$device_state"

#			Checking if the state of the device has changed
			check_device_state_change "$device" "$device_nb" "$device_label"
			old_states[$device_nb]="$device_state"
			
#			Calculating the duration of the current state
			get_state_duration "$device" "$device_nb"
			state_duration=$retval
#			printf "duration: $state_duration"
			
#			Getting the device IO stats
			array_iostat=($(iostat -dk $device | tail -n+4 | head -n1))
			device_read="${array_iostat[4]}"
			device_write="${array_iostat[5]}"
			
#			Format the times and the sizes to output
			sd_format=$(format_time ${state_duration})
			lsd_format=$(format_time ${last_state_duration[$device_nb]})
			read_format=$(format_size ${device_read})
			write_format=$(format_size ${device_write})

#			Printing the result to the output and going to the next device			
			device_data=($device_nb $device $device_label $device_state $sd_format $lsd_format $read_format $write_format)
			device_line=$(printf "\e[1;36m$(create_line device_data disk_columns_width)\e[0m\n")
			result="${result}\n${device_line}"
			
			device_nb=$(($device_nb + 1))
		fi
	done
	retval=$result
}


get_machine_info_readonly
while true; do
	pre_exec_time=$(date '+%s%N' | cut -b1-13)
	
	term_width=$(get_terminal_width)
	
	output=""
	get_machine_info
	output="${output}${retval}\n"
	get_cpu_info
	output="${output}${retval}\n"
	get_gpu_info
	output="${output}${retval}\n"
	get_disk_info
	output="${output}${retval}\n"
	
#	Print a beautiful clock at the end of the first line
#	term_width=$(tput cols)
#	current_time=$(date +"%y-%m-%d %H:%M:%S")
#	current_time_format=$(printf "\e[1;37;45m${current_time}\e[0m")
#	first_line=$(echo -e "$output" | head -n1)
##	TODO delete that ugly +11 hack because the line is colored so I don't have the real size
#	blank_size=$(( $term_width - ${#first_line} - ${#current_time} + 11))
#	new_first_line=$(printf "${first_line}%${blank_size}s%${#current_time}s" "" "${current_time_format}")
#	
#	output=$(echo -e "$output" | sed "1s/.*/${new_first_line}/")
	

#	Send ^[c character to clean the screen
	echo -e "\0033\0143"
	
#	Print all the data on stdout
	echo -e "$output"
#	printf "first line: ${#first_line}\n"
#	printf "blank_size: ${blank_size}\n"
#	printf "time: ${#current_time_format}\n"
	
#	Calculate the execution time of the loop and sleep for (1 second - $exec_time)
	post_exec_time=$(date '+%s%N' | cut -b1-13)
	sleep_time=$(get_sleep_time "$pre_exec_time" "$post_exec_time")
	printf "exec_time: 0.$(( $post_exec_time - $pre_exec_time ))ms\n"
	printf "sleep_time: ${sleep_time}ms\n"
	sleep $sleep_time
done


