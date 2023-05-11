#!/bin/bash

########################################

# This script shows all tc rules on the mesh network with network interface wg0, wg1, ....

########################################
. config


IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)

for IP in ${public_ip_arr[@]}
do

        echo -e "\e[44mIP: $IP\e[0m"

        a=$(ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP}  "ip a | grep wg | cut -f 2 -d ":"| wc -l")

        TOTALWG=$[${a}/2-1]
        for wg in $(seq 0 1 ${TOTALWG})
        do
               SHOW_COMMAND=$(echo sudo tcshow ${MESH_NETWORK_INTERFACE}${wg})
               ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} "${SHOW_COMMAND}"
        done
done


