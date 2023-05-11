#!/bin/bash
# Monitors available disk space
# $1 - ID
# $2 - disk device to check
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
#~/tplink-smartplug/tplink_smartplug.py -t 192.168.0.1 -c energy | cut -d ',' -f 3 | tail -n 1 | cut -d ':' -f 2 > ${RESULTS_FILE}
#~/tplink-smartplug/tplink_smartplug.py -t 192.168.0.1 -c energy | tail -n 1| cut -f 8 -d: | cut -f 1 -d, >${RESULTS_FILE}

TOTALENG=0
while true
do

  RESULT=`~/tplink-smartplug/energy.py -t 192.168.0.1 -c energy | tail -n 1`
  echo ${RESULT}
  A=`echo ${RESULT} | cut -f 5 -d: | cut -f 1 -d,`
  echo ${A}
  V=`echo ${RESULT} | cut -f 4 -d: | cut -f 1 -d,`
  echo ${V}
  #testval= `( ${V} * ${A} ) / 1000000 | bc -l `
  #echo $testval
  TOTALENG=$(( ${TOTALENG} + ( ${V} * ${A} ) / 1000000 ))  >> ${RESULTS_FILE}
  echo $TOTALENG
  echo "${TOTALENG}" >> ${RESULTS_FILE}
 
 sleep 1
done

#echo ${TOTALENG}

#$TOTALENG > ${RESULTS_FILE}


# $1 - TP-Link smart command (on, off, energy, ....)
#~/tplink-smartplug/tplink_smartplug.py -t 192.168.0.1 -c ${1}
#df | grep "$1" | tr -s " " | cut -f 4 -d " " > ${RESULTS_FILE}
