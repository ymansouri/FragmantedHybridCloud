#!/bin/bash

##################################

# This script show all tc rules on a cluster of VMs with network interface of ens3

#################################
. config


IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE_TCSET}
public_ip_arr=(${public_ip_arr})
echo PUBLIC_IP:  ${public_ip_arr[@]}

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)
echo ${VM_NUMBER}

SHOW_COMMAND=$(echo sudo tcshow ${NETWORK_INTERFACE})

for IP in ${public_ip_arr[@]}
do
  echo -e "\e[44mIP: $IP\e[0m"
  ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${SHOW_COMMAND} | jq -c '.ens3.outgoing | del(.[]|."filter_id")'
done


