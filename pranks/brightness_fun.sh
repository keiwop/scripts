#! /usr/bin/zsh

backlight="/sys/class/backlight/intel_backlight"
brightness="$backlight/brightness"

typeset -i current_brightness=$(cat $backlight/brightness)
typeset -i max_brightness=$(cat $backlight/max_brightness)
typeset -i step_orig=5
typeset -i step=$step_orig
typeset -i count_loop=3
typeset -i sleep_time=0.05


sleep $sleep_time
while [[ $count_loop -gt 0 ]]; do
	for i in $(seq $max_brightness -$step 0); do
		if [[ $i -lt $[$max_brightness/3] ]]; then
			step=$[$step_orig/2]
		else
			step=$step_orig
		fi
#		echo "$i"
		echo "$i" > $brightness
		sleep $sleep_time
	done

	echo "0" > $brightness
	sleep $sleep_time

	for i in $(seq 0 $step $max_brightness); do
		if [[ $i -lt $[$max_brightness/3] ]]; then
			step=$[$step_orig/2]
		else
			step=$step_orig
		fi
#		echo "$i"
		echo "$i" > $brightness
		sleep $sleep_time
	done

	echo "$max_brightness" > $brightness
	sleep $sleep_time
done
