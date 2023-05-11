#!/bin/bash
#$1 - ID
PROBEID=`ps uax | grep "start.*.sh[ ]${1}" | tr -s " " | cut -f 2 -d " "`
pkill -P ${PROBEID} -INT

