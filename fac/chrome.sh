#! /bin/sh
#Script to launch google-chrome installed in the $home directory

CHROME=~
PATH=$CHROME/opt/google/chrome:$PATH
LD_LIBRARY_PATH=$CHROME/opt/google/chrome:$LD_LIBRARY_PATH
$CHROME/opt/google/chrome/google-chrome --no-sandbox
