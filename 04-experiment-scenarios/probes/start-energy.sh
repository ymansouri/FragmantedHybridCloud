#!/bin/bash
# $1 - ID
# $2 - RAPL domain name (dram, package-0, core, psys...)
# to get list of available domains on a machine, run:
# find /sys/class/powercap/intel-rapl/ -name "name" -exec cat {} \;
#
#
#STARTID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
shift 1
for f in `find /sys/class/powercap/intel-rapl/ -name "name" -print`
do
  NAME=`cat $f`
  if [[ "${NAME}" == "${1}" ]]
  then
    ENERGY_UJ=`dirname $f`/energy_uj
    VAL=`cat $ENERGY_UJ`
    echo $NAME $VAL > ${RESULTS_FILE}
  fi
done
