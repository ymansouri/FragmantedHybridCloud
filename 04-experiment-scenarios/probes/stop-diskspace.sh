#!/bin/bash
# $1 - ID
# $2 - disk device to check
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
shift 1
df >>log
echo grepping $1 disk device >> log
df | grep "$1 " | tr -s " " | cut -f 4 -d " " >> ${RESULTS_FILE}
