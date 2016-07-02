#! /bin/sh
#Just a snippet of code to format some columns nicely

column_names=("n°" "device" "label" "state" "state duration" "last duration" "read" "write")
column_sizes=(2 12 12 8 16 16 12 12)
device_data=()

create_line(){
	arg1="$1[@]"
	column_values=("${!arg1}")
	
	let i=0
	for column_value in "${column_values[@]}"; do
		nb_spaces=$(( ${column_sizes[$i]} - ${#column_value} ))
		
		spaces_before=$(( $nb_spaces / 2 ))
		spaces_after=$spaces_before
		if [[ $(( $nb_spaces % 2 )) -eq 1 ]]; then
			let spaces_before++
		fi
		
		printf "%${spaces_before}s%${#column_value}s%${spaces_after}s|" "" "${column_value}" ""
		let i++
	done
	printf "\n"
}

create_line column_names

#0123456789AB - 12
#______@_____ - 6 - 1 - 5
#_____@@_____ - 5 - 2 - 5
#_____@@@____ - 5 - 3 - 4
#____@@@@____ - 4 - 4 - 4
