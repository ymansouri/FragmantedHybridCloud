#!/bin/bash
# $1 - ID
# $2* - rest of arguments
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
shift 1
ifconfig $1 | grep "bytes" | tr -s " " >> ${RESULTS_FILE}
