#!/bin/bash
#$1 - ID
#$2 - network interface
#$* - Space-separated IP list

sudo apt -y install iftop > /dev/null 2>&1

RESULTS_FILE="$1"
INTERFACE="$2"
FILTERCODE=""
shift 2
IPLIST="$*"
for ip in $IPLIST
do
  FILTERCODE="${FILTERCODE}(dst host ${ip}) or (src host ${ip}) or "
done
#remove last 'or' occurrence
FILTERCODE=${FILTERCODE%or }
#echo iftop -B -i ${INTERFACE} -n -t -f "${FILTERCODE}" to ${RESULTS_FILE} >log
#sudo iftop -B -i ${INTERFACE} -n -t -f "${FILTERCODE}" >${RESULTS_FILE}
echo iftop -B -i ${INTERFACE} -n -t -f "port not 22" to ${RESULTS_FILE} >log
sudo iftop -B -i ${INTERFACE} -n -t -f "port not 22">${RESULTS_FILE}
