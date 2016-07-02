#! /bin/sh

#Turn off the disks

sudo hdparm -y /dev/disk/by-label/2TBa
sudo hdparm -y /dev/disk/by-label/2TBb
sudo hdparm -y /dev/disk/by-label/3TBa
sudo hdparm -y /dev/disk/by-label/1TBa

