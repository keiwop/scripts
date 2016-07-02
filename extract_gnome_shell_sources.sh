#! /bin/sh
#Extract the gresource of the gnome-shell compiled library

gs=/usr/lib64/gnome-shell/libgnome-shell.so

out=/_/dev/gnome/gnome-shell/$(date +"%Y%d%m_%H%M%S")_gs
mkdir -p $out

cd $out
mkdir -p ui/components ui/status misc perf extensionPrefs gdm portalHelper

for r in $(gresource list $gs); do
	gresource extract $gs $r > ${r/#\/org\/gnome\/shell/.}
done
