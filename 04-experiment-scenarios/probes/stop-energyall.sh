#!/bin/bash
# $1 - ID
# $2 - RAPL domain name (dram, package-0, core, psys...)
# to get list of available domains on a machine, run:
# find /sys/class/powercap/intel-rapl/ -name "name" -exec cat {} \;
#
#
#ID=$(date +"%Y%m%d%H%M%S%N")
RESULTS_FILE=$1
echo $RESULTS_FILE
shift 1
for f in `find /sys/class/powercap/intel-rapl/ -name "name" -print`
do
  NAME=`cat $f`
  echo $NAME
  #if [[ "${NAME}" == "${1}" ]]
  #then
    ENERGY_UJ=`dirname $f`/energy_uj
    VAL=`cat $ENERGY_UJ`
    echo $VAL
    echo ${NAME} $VAL >> ${RESULTS_FILE}
    #echo $VAL >> ${RESULTS_FILE}
    #sed -i '33ianything' >> ${RESULTS_FILE}


    #echo $RESULTS_FILE
   #fi
done
