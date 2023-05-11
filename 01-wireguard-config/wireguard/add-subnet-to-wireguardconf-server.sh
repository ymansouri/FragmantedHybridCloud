#!/bin/bash
#add-subnet-ip.sh  adds subnets to wg0 config  file in order to make connection between two brokers via their private ip

# $1 - subnet address (client_subnet: 10.0.17.6/32) 

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

SERVER_SSH_DEST=${SERVER_DEST%:*}
CLIENT_SSH_DEST=${CLIENT_DEST%:*}


# This adds subnet of consumer/client broker (in openstack) to the donor/server broker (in Azure)
CLIENT_PUBLIC_KEY=$(./get-public-key.sh ${CLIENT_DEST#:@})
echo client_public_key: ${CLIENT_PUBLIC_KEY}


#echo ./add-subnet-ip-donor.sh  "${DONOR_SSH_DEST}" "${DONOR_PUBLIC_KEY}" "${SUBNET_ADDRESSES}"
./add-subnet-ip.sh  "${SERVER_SSH_DEST}" "${CLIENT_PUBLIC_KEY}" "${SUBNET_ADDRESSES}" 
