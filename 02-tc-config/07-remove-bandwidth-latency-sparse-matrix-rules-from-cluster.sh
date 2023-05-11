#!/bin/bash

#########################################

# This code will remove the latency and bandwidth values on all the interfaces according to sparse matrix using tcconfig.

#########################################

. config


IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)


for IP in ${public_ip_arr[@]}
do
        echo -e "\e[44mIP: $IP\e[0m"
        a=$(ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP}  "ip a | grep ${MESH_NETWORK_INTERFACE} | cut -f 2 -d ":"| wc -l")

        TOTALWG=$[${a}/2-1]
        for wg in $(seq 0 1 ${TOTALWG})
        do
               DELETE_COMMAND=$(echo sudo tcdel ${MESH_NETWORK_INTERFACE}${wg} --all)
               ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} "${DELETE_COMMAND}"
        done
done

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
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

