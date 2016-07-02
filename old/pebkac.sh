#!/bin/sh

url="http://www.pebkac.fr/"
cd /home/mickaaa/Documents/pebkac

wget $url --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" -O pebkac
new=$(grep "pebkacContent" pebkac | cut -d'=' -f6 | cut -d'.' -f2 | cut -d'-' -f2 | sed '1d' | head -n 1)
old=$(cat oldPebkac)

if [ $new != $old ]
then
	echo "Il y a de nouveaux pebkacs" > sms
	cat $new > oldPebkac
	./scriptCalendar.sh
fi
