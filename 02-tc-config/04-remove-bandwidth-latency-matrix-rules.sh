#!/bin/bash

########################################

# This script helps to delete all the tc rules on all node using tcset

########################################

. config

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE_TCSET}
public_ip_arr=(${public_ip_arr})
echo PUBLIC_IP:  ${public_ip_arr[@]}

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)
echo ${VM_NUMBER}

DELETE_COMMAND=$(echo sudo tcdel ${NETWORK_INTERFACE} --all)

for IP in ${public_ip_arr[@]}
do
       echo -e "\e[44mIP: $IP\e[0m"
       ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${DELETE_COMMAND}
done


