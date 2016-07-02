#!/bin/sh
#All the tools to see the size of a partition are not present or blocked ?
#You can now fill it with a shitload of 1M files to see the remaining storage

i=0
while [ $i -lt 500 ]; do
	dd if=/dev/zero of=test.$i bs=1M count=1
	i=$[ $i + 1 ]
done
