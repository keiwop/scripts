#!/bin/bash

#TODO

cd /media/Disque\ local/Series/


echo "Randomizator"
echo "	1)Serie"
echo "	2)Movie"
echo "	3)Music"
echo "	4)Book"
echo "	5)Game"
echo

echo "Choice : " | tr -d '\n'
read choice
echo $choice


nbSerie=$[$(ls -l | wc -l) - 1]
echo $nbSerie "series"

nbChosen=$[($RANDOM % $nbSerie)]

nameSerie=$(ls | head -$nbChosen | tail -1)
echo "N°$nbChosen : $nameSerie"
cd $nameSerie

nbEpisode=$(ls -RlF | grep -e avi -e mkv -e mp4 | wc -l)
echo $nbEpisode "episodes"

nbChosen=$[($RANDOM % $nbEpisode)]
echo "n°$nbChosen"

nameEpisode=$(ls -RF | grep -e avi -e mkv -e mp4 | head -$nbChosen  | tail -1)

echo $nameEpisode
vlc $nameEpisode
