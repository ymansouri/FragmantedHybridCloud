#!/bin/bash 

. config

# This code want to disable several links in mesh network  which was build based on wg connection

#if [ "$#" -lt 1 ]
#then
#  echo "Usage: $0 <space-separated-<wg_ips>"
#  exit
#fi






PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})

#PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})
#echo ${PRIVATE_IPS}

VMS_NUMBER=$(echo ${ALL_DESTINATIONS}|tr ',' '\n'|wc -l)
echo vm_number: ${VMS_NUMBER}







