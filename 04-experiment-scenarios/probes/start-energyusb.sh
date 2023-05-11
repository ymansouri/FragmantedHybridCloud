#!/bin/bash
# Measures U2 USB energy meter using u2_web application
# Note that only one copy of this probe is possible to be run at the same time.
#$1 - ID

RESULTS_FILE="$1"

sudo ~/rpi-meter/u2_usb | awk 'BEGIN {FS="," ; currents=-1 ; currentw=0; currentreads=1; totalw=0;} { if ($1==currents) { currentw=currentw+$10; currentreads=currentreads+1; } else { totalw=totalw+currentw/currentreads; currentw=$10; currentreads=1 ; currents=$1; } } END { totalw=totalw+currentw/currentreads ; print totalw " J " totalw/3600 " KWh" }' > ${RESULTS_FILE}

#awk '
#BEGIN {FS="," ; currents=-1 ; currentw=0; currentreads=1; totalw=0;}
#{ if ($1==currents) { currentw=currentw+$10; currentreads=currentreads+1; }
#else
#{ totalw=totalw+currentw/currentreads; currentw=$10; currentreads=1 ; currents=$1; } }
#END { totalw=totalw+currentw/currentreads ; print totalw " J " totalw/3600 " KWh" }' 
#> ${RESULTS_FILE}
