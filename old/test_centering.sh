#! /bin/sh

D="12"    # input string
BS=10     # buffer size
L=$(((BS-${#D})/2))
[ $L -lt 0 ] && L=0
printf "start %${L}s%s%${L}s end\n" "" $D ""
