#!/bin/bash

#cd /media/Disque\ local/Series/
cd /home/mickaaa/tmp/

nb=$[$(ls -l | grep ' ' | wc -l) - 1]
echo $nb
i=1

while [ $i -le $nb ]
	do 	
	
	name=$(ls | head -$i | tail -1)
	echo "n°$i $name"
	
	nameNoSpace=$(echo $name | tr " " "_")
	echo "n°$i $nameNoSpace"
	
	mkdir $nameNoSpace
	touch a\ m/a
	
	#mv $name $nameNoSpace
	i=$[ i + 1 ]
done
