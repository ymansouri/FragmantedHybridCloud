#!/bin/bash

# $1 - Donor broker username@donor public IP
# $2 - consumer public key
# $3 - consumer VPN IP (10.10.10.2)
# $4 - Wireguard interface number
. config
if [ "$4" == "" ]
then
  echo "Usage: $0 <DONOR_BROKER_USER@DONOR_IP> <CONSUMER_PUBLIC_KEY> <CONSUMER_VPN_IP> <WIREGUARD_INTERFACE_NUMBER>"
  exit 1
fi

DONORWG_INTERFACE=$4
echo  peer: ${DONORWG_INTERFACE}
echo ssh  -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" "sudo wg set ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE} peer "$2" allowed-ips $3/32 ; sudo wg-quick down ${DONORWG_INTERFACE} ; sudo wg-quick up ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}"
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} "$1" "sudo wg set ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE} peer "$2" allowed-ips $3/32 ; sudo wg-quick down ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE} ; sudo wg-quick up ${MESH_NETWORK_INTERFACE}${DONORWG_INTERFACE}"

