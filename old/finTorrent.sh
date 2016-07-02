t="/home/mickaaa/Torrent"
tec="/home/mickaaa/Torrent/Torrent_en_cours"

cd $t
nom=$(ls -tc | head -n 1)
nom=$(basename $nom)
if [ "$nom" = "Torrent_en_cours" ]; then
	nom=$(ls -tc | sed '1d' | head -n 1)
fi
echo "$nom vient de se terminer" > sms
./scriptCalendar.sh



