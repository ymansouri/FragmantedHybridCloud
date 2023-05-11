#!/bin/bash 

. config


if [[ "$1" == "" ]]
then
  echo Usage: $0 "<RESULTS_FOLDER>"
  exit
fi

LATENCY_RES=$1


PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})


PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})
#echo ${PRIVATE_IPS}


VMS_NUMBER=$(echo ${ALL_DESTINATIONS}|tr ',' '\n'|wc -l)
#echo vm_number: ${VMS_NUMBER}

TINC_IPS=
for i in $(seq ${VMS_NUMBER})
do
     TINC_IP=${TINC_SUBNET%.*}.${i}
     TINC_IPS=${TINC_IPS}" "${TINC_IP}
done
echo ${TINC_IPS}


#./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-tinc-private-layers.sh" "\"${PRIVATE_IPS}\" ${PRIVATE_NETWORK_INTERFACE}"
./fast-runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-tinc-private-layers.sh" "\"${PRIVATE_IPS}\" ${VPN_NAME}" "${LATENCY_RES}"

sleep 5




