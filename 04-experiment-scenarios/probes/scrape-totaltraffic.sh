#!/bin/bash
#$1 - ID
PROBEID=$1
LINESCOUNT=`wc -l < ${PROBEID}`

# for local nodes (rpi-laptop and energy server)
if [[ LINESCOUNT -eq 4 ]]
then
  RXBEFORE=`head -n 1 ${PROBEID} | awk '{print $5}'`
  RXAFTER=`head -n 3 ${PROBEID} | tail -n 1 | awk '{print $5}'`
  TXBEFORE=`head -n 2 ${PROBEID} | tail -n 1 | awk '{print $5}'`
  TXAFTER=`tail -n 1 ${PROBEID} | awk '{print $5}'`
# for cloud vms (azure and openstack)
else
  RXBEFORE=`head -n 1 ${PROBEID} | awk '{print $2}' | awk -F':' '{ print $2 }'`
  #echo "befRX:" ${RXBEFORE}
  RXAFTER=`tail -n 1 ${PROBEID}| awk '{print $2}' | awk -F':' '{ print $2 }'`
  #echo "aftRX:" ${RXAFTER}
  TXBEFORE=`head -n 1 ${PROBEID} | awk '{print $6}' | awk -F':' '{ print $2 }'`
  #echo "befTX:" ${TXBEFORE}
  TXAFTER=`tail -n 1 ${PROBEID} | awk '{print $6}' | awk -F':' '{ print $2 }'`
  #echo "befTX:" ${TXAFTER}
fi
echo RX $(( $RXAFTER - $RXBEFORE )) TX $(( $TXAFTER - $TXBEFORE ))
