#! /bin/sh
#Log the ouptut of the speedtest program and repeat every 5mn

log_file="/var/log/speedtest.log"
loop_delay="300"

get_current_time(){
	current_time=$(date +"%y-%m-%d %H:%M:%S")
	time_nano=$(date +"%N" | cut -c1-3)
	echo -n "${current_time}.${time_nano}"
}


#	$1 is the time before the execution of the main loop
#	$2 is the time after the execution of the main loop
get_sleep_time(){
	exec_time=$(( $2 - $1 ))
#	TODO exec_time > loop_delay
	sleep_ms=$(( ($loop_delay*1000) - $exec_time ))
	sleep_s=$(( $sleep_ms / 1000 ))
	sleep_ms=$(( $sleep_ms % 1000 ))
#	sleep_time=$(bc <<< "scale=3; $sleep_time / 1000" )
	echo -n "${sleep_s}.${sleep_ms}"
}


while true; do
	pre_exec_time=$(date '+%s%N' | cut -b1-13)
	echo "" | tee -a $log_file
	
	current_time=$(get_current_time)
	echo "${current_time} Starting speedtest" | tee -a $log_file
	speedtest_result=$(speedtest --simple)
#	sleep 11.550
	current_time=$(get_current_time)
	echo "${current_time} Speedtest finished" | tee -a $log_file

	post_exec_time=$(date '+%s%N' | cut -b1-13)
	sleep_time=$(get_sleep_time "$pre_exec_time" "$post_exec_time")
	echo "exec_time: $(( $post_exec_time - $pre_exec_time ))ms" | tee -a $log_file
	echo "sleep_time: ${sleep_time}s" | tee -a $log_file
	
	echo "${speedtest_result}" | tee -a $log_file
	sleep "$sleep_time"
done

