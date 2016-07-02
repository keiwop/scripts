#! /bin/sh
if [[ $# -gt 0 ]]; then
	espeak -v fr-fr "$1"
else
	gnome-terminal hide-menubar --full-screen --zoom=2 -e sl
	eject -T
fi
