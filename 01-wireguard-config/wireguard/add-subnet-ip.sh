#!/bin/bash
# This adds the subnet address to wg0.conf in  the broker. This subnets includs shared network in 
#Openstak (added to the azure broker) and shared network in azure (added to the openstackbroker) 

# $1 - user@ip, ubuntu for OpenStack or azureuser for Azure
# $2 - peer public key to find in wg show output
# $3 - allowed subnet IP, allow this new subnet into allowed-ips in wg

. config 

if [ "$3" == "" ]
then
  echo "Usage: $0 <USER_NAME@BROKER_PUBLIC_IP> <PEER_PUBLIC_KEY> <ALLOWED_SUBNET_IP>"
  exit 1
fi

BROKER_ssh_DEST="$1"
PEER_PUBLIC_KEY="$2"
ALLOWED_SUBNET="$3"

rm ~/.ssh/known_hosts >/dev/null 2>&1

IP_LIST=$(ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE} "${BROKER_ssh_DEST}" sudo wg show wg0 allowed-ips | grep "${PEER_PUBLIC_KEY}" | cut -f 2)
echo ip_list: ${IP_LIST}
if echo "$IP_LIST" | grep -q "${ALLOWED_SUBNET}"; then
  echo "Subnet already allowed."
else
  echo "Adding subnet ${ALLOWED_SUBNET}"
  NEW_IP_LIST=$(echo "${IP_LIST} ${ALLOWED_SUBNET}" | sed 's/ /, /g')
  echo "New allowed subnets list: ${NEW_IP_LIST}"
  echo ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE}  "${BROKER_ssh_DEST}" sudo wg set wg0 peer "${PEER_PUBLIC_KEY}" allowed-ips "\"$NEW_IP_LIST\""
  ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE} "${BROKER_ssh_DEST}" sudo wg set wg0 peer "${PEER_PUBLIC_KEY}" allowed-ips "\"$NEW_IP_LIST\""
  ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE} "${BROKER_ssh_DEST}" sudo wg-quick save wg0
#  ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE} "${BROKER_ssh_DEST}" sudo wg-quick down wg0
#  ssh  -o StrictHostKeyChecking=no -i ${ssh_KEY_FILE} "${BROKER_ssh_DEST}" sudo wg-quick up wg0
fi





