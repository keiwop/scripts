#!/bin/sh
cd /home/mickaaa/Documents/magestik
email="email@gmail.com"
pass="nope"

curl --cookie-jar cookie --data "appid={APP_ID}&login_email="$email"&login_password="$pass"&login=1" http://magestik.fr/api/connect.php?appid=06f97eff6798a9a79c9d02f7a681a31d --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" > a

token=$(grep "token" a | cut -d= -f8 | cut -d\" -f1)

wget --load-cookies=cookie --save-cookies=cookie --keep-session-cookies "http://game.magestik.fr/login/_auth.php?user=63&token="$token"" -O _auth
wget --load-cookies=cookie --save-cookies=cookie --keep-session-cookies "http://game.magestik.fr/login/index.php" -O index

lien=$(grep "token" index | cut -d\" -f2)
time=$(date +%s)

wget --load-cookies=cookie --save-cookies=cookie --keep-session-cookies "$lien" -O vueG

#joueur=$(grep "flight" vueG | cut -d">" -f13 | cut -d" " -f4)
#coord=$(grep "flight" vueG | cut -d">" -f16 | cut -d"<" -f1)
#motif=$(grep "flight" vueG | cut -d">" -f18 | cut -d"<" -f1)

grep "flight" vueG > testFile
if [ -s testFile ]; then
	rm testFile
	grep "\battack" vueG > testFile
	if [ -s testFile ]; then
		message="Attaque"
		echo "$message" > sms
		./scriptCalendar.sh
	fi

fi



