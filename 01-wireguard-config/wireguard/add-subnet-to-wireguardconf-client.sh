#!/bin/bash
#add-subnet-ip.sh  adds subnets to wg0 config  file in order to make connection between two brokers via their private ip


#$3 - subnet_address (server_subnet: 10.0.17.5/32)
 
. config 

if [ "$1" == "" ]
then
  echo "Usage: $0 <SUBNET_ADDRESSES>"
  exit 1
fi

SUBNET_ADDRESSES=$1



PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
echo $PUBLIC_IPS
ALL_DESTINATIONS=$(hosts2dests "${PUBLIC_IPS}" ${VM_USERNAME})
SERVER_DEST=$(echo ${ALL_DESTINATIONS}| cut -f 1 -d ',')
CLIENT_DEST=$(echo ${ALL_DESTINATIONS}| cut -f 2 -d ',')

SERVER_ssh_DEST=${SERVER_DEST%:*}
CLIENT_ssh_DEST=${CLIENT_DEST%:*}






#1 - Add an Azure subnet into openstack broker
# This addds subnet of donor/server broker (in Azure) to wg0 in consumer/client broker (in openstack)

SERVER_PUBLIC_KEY=$(./get-public-key.sh ${SERVER_DEST#:@})

echo server_key: ${SERVER_PUBLIC_KEY}
#echo subnet address: ${SUBNET_ADDRESSES}
./add-subnet-ip.sh "${CLIENT_ssh_DEST}" "${SERVER_PUBLIC_KEY}" "${SUBNET_ADDRESSES}"

