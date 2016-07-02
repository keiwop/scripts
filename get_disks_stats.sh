#! /bin/sh

disk="/dev/sda"

orig_iostat=$(iostat -d $disk)
echo -e "iostat:\n$orig_iostat"

set -- $(iostat -d $disk | grep `basename $disk`)
echo -e "array:\n$2"
