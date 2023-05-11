#!/bin/bash
# $1 - ID
# $2 - battery number
#
#
#ID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
echo $RESULTS_FILE
shift 1
echo battery $(upower -i /org/freedesktop/UPower/devices/battery_BAT${1} | grep energy: | tr -s " " | cut -f 3 -d " ")  >>${RESULTS_FILE}
