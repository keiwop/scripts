#! /bin/sh

#Put the disk in standby after 5 minutes of inactivity

_delay=0
_log_file="/var/log/disks_states.log"

sudo hdparm -B 255 -S ${_delay} /dev/disk/by-label/2TBa
sudo hdparm -B 255 -S ${_delay} /dev/disk/by-label/2TBb
sudo hdparm -B 255 -S ${_delay} /dev/disk/by-label/3TBa
sudo hdparm -B 255 -S ${_delay} /dev/disk/by-label/1TBa

#sudo hdparm -B 255 -S 3 /dev/disk/by-partlabel/40GBa
