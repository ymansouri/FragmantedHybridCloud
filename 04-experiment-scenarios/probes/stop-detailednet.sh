#!/bin/bash
#$1 - ID
#$2 - interface
#$3 - space-separated IP list
ps uax | grep start >> log
#PROBEID=`ps uax | grep "start-detailednet.*.sh[ ]${1}" | tr -s " " | cut -f 2 -d " "`
PROBEID=`ps uax | grep "/bin/bash \./start-detailednet.*.sh\ ${1}" | tr -s " " | cut -f 2 -d " "`
sudo pkill -P ${PROBEID} -INT
#sudo pkill -f \"${PROBE
