#!/bin/sh

userG="email"
passG=""
objetSms="Ceci est un message de test !"
dateJour=$(date +%d/%m/%Y)
heure=$[$(date +%k) * 100]
minute=$(date +%M)
heureSms=$[$heure + $minute + 2]
google calendar add "$objetSms $dateJour $heureSms" --reminder 1m
