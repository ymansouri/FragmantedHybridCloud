#!/bin/bash

. config
# $1 - DONOR broker username@DONOR IP
# $2 - Wireguard port (51280)
# $3 - Wireguard server VPN IP
# $4 - CONSUMER public ip (10.10.10.2)

if [ "$5" == "" ]
then
  echo "Usage: $0 <DONOR_BROKER_USERNAME@DONOR_IP> <WIREGUARD_PORT> <SERVER_VPN_IP> <CLIENT_VPN_IP> <CONSUMER_PUBLIC_KEY> [WG_INTERFACE]"
  exit 1
fi

if ! [[ "$6" == "" ]]
then
  DONORWG_INTERFACE=$6
else
  # Get the first free wg interface (Never delete wgN.conf)
  DONORWG_INTERFACE=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" sudo ls /etc/wireguard/${MESH_NETWORK_INTERFACE}*.conf | wc -l)
fi

echo donor $DONORWG_INTERFACE

# Prepare Donor config
./wireguard/createServerConfig.sh $2 $3 $4 $5 > "generateds"$DONORWG_INTERFACE".conf"

# Upload Donor Config
scp -i ${SSH_KEY_FILE} "generateds"$DONORWG_INTERFACE".conf" $1:/tmp/${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}.conf

# remove Donor config "generateds*.conf" from the worker node 
rm generated*.conf

# Start wireguard on donor
rm ~/.ssh/known_hosts >/dev/null 2>&1

echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" "sudo cp /tmp/${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}.conf /etc/wireguard/ ; wg-quick up ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}"
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" "sudo cp /tmp/${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}.conf /etc/wireguard/ ; wg-quick up ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}"

