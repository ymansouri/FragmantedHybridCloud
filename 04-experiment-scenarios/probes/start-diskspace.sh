#!/bin/bash
# Monitors available disk space
# $1 - ID
# $2 - disk device to check
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
shift 1
df | grep "$1 " | tr -s " " | cut -f 4 -d " " > ${RESULTS_FILE}
