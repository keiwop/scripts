#!/bin/sh
CACHE_DIR=/afs/deptinfo-st.univ-fcomte.fr/users/mmartin6/.cache

if [ -d $CACHE_DIR ]; then
	rm -rf $CACHE_DIR/* 
fi

