#!/bin/bash
# $1 - ID
# $2 - disk device to check
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1

#~/tplink-smartplug/tplink_smartplug.py -t 192.168.0.1 -c energy | cut -d ',' -f 3 | tail -n 1 | cut -d ':' -f 2 >> ${RESULTS_FILE}
#~/tplink-smartplug/tplink_smartplug.py -t 192.168.0.1 -c energy | tail -n 1| cut -f 8 -d: | cut -f 1 -d, >> ${RESULTS_FILE}


ps uax | grep start >> log
PROBEID=`ps uax | grep "/bin/bash \./start-smartplug.sh\ ${1}" | tr -s " " | cut -f 2 -d " "`
#sudo pkill -P ${PROBEID} -INT
sudo kill  ${PROBEID} 








