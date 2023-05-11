#!/bin/bash
#. config 

. config 

if [[ "$4" == "" ]]
then
  echo "Usage: $0 <VPN_IP> <SERVER_IP> <CLIENT_IP> <VM_USERNAME>"
  exit
fi

CONSUMER_VPN_IP=${1}
SERVER_IP=${2}
CLIENT_IP=${3}
VM_USERNAME=${4}

#SERVER_IP=$(cat terraform-donor/donor.ip)
SERVERWG_INTERFACE=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SERVER_IP} sudo ls /etc/wireguard/${MESH_NETWORK_INTERFACE}*.conf | wc -l)
SERVERWG_INTERFACE=$((${SERVERWG_INTERFACE} - 1))

echo ./wireguard/authorizePeer.sh ${VM_USERNAME}@${SERVER_IP} $(./wireguard/get-public-key.sh ${CLIENT_IP}) ${CONSUMER_VPN_IP} ${SERVERWG_INTERFACE}
./wireguard/authorizePeer.sh ${VM_USERNAME}@${SERVER_IP} $(./wireguard/get-public-key.sh ${CLIENT_IP}) ${CONSUMER_VPN_IP} ${SERVERWG_INTERFACE}


#ssh "$1" "sudo wg set wg${DONORWG_INTERFACE} peer $2 allowed-ips $3/32 ; sudo wg-quick down wg${DONORWG_INTERFACE} ; sudo wg-quick up wg${DONORWG_INTERFACE}"
