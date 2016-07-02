#! /bin/sh
su
ipaddr=`ip route | grep "rmnet0" |cut -d " " -f12`
route add default gw $ipaddr dev rmnet0
