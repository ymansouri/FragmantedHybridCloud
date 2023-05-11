#!/bin/bash

. config
# $1 - consumer broker username @ consumer IP
# $2 - WG endpoint = Donor public IP:WG PORT
# $3 - Wireguard VPN subnet (10.10.10.0/24)
# $4 - Consumer VPN ip (10.10.10.2)
# $5 - Donor public key
if [ "$5" == "" ]
then
  echo "Usage: $0 <VM_USERNAME@CONSUMER_IP> <WIREGUARD_ENDPOINT> <VPN_SUBNET> <VPN_CONSUMER_IP> <DONOR_PUBLIC_KEY> [WG_INTERFACE]"
  exit 1
fi


DONOR_PUBLIC_KEY=$5
echo ${DONOR_PUBLIC_KEY}
# Get the first free wg interface  (Never delete wgN.conf)

if ! [[ "$6" == "" ]]
then
  CONSUMERWG_INTERFACE=$6
else
  # Get the first free wg interface (Never delete wgN.conf)
  CONSUMERWG_INTERFACE=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" ls /etc/wireguard/${MESH_NETWORK_INTERFACE}*.conf | wc -l)
fi


echo consumer $CONSUMERWG_INTERFACE

# Prepare Consumer config
./wireguard/createClientConfig.sh $2 $3 $4 $DONOR_PUBLIC_KEY > "generatedc"${CONSUMERWG_INTERFACE}".conf"

# Upload consumer config
#scp "generated.conf" $1:/tmp/wg${CONSUMERWG_INTERFACE}.conf
scp -i ${SSH_KEY_FILE} "generatedc"${CONSUMERWG_INTERFACE}".conf" $1:/tmp/${MESH_NETWORK_INTERFACE}${CONSUMERWG_INTERFACE}.conf

# Start wireguard on consumer
rm ~/.ssh/known_hosts >/dev/null 2>&1
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} $1 "sudo cp /tmp/${MESH_NETWORK_INTERFACE}${CONSUMERWG_INTERFACE}.conf /etc/wireguard ; wg-quick up ${MESH_NETWORK_INTERFACE}${CONSUMERWG_INTERFACE}"


