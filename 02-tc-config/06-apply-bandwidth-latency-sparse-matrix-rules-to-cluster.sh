#!/bin/bash

##################################

# This code will apply the latency and bandwidth values on all the interfaces according to sparse matrix using tcconfig.

#################################

. config


IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})

IFS=,$'\n' read -d '' -r -a private_ip_arr < ${PRIVATE_IPS_FILE}
private_ip_arr=(${private_ip_arr})

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)


#$1: source index in latency matrix  $2: destination index in latency matrix
function get_latency () {
  sed "${1}q;d" ${ASYM_MESH_LATENCY_FILE} | cut -f $2 -d","
}


#$1: source index in bandwidth matrix  $2: destination index bandwidth matrix
function get_bandwidth () {
 sed "${1}q;d" ${ASYM_MESH_BANDWIDTH_FILE} | cut -f $2 -d","
}


for VM_SRC in `seq 1 1 ${VM_NUMBER}`
do

        APPLIED_RULES_WG_CONNECTIONS=0
        for VM_DEST in `seq 1 1 ${VM_NUMBER}` 
        do
                 echo Index: ${VM_SRC} ${VM_DEST}

                   PUBLIC_IP_ON_VM_SRC=$(echo ${public_ip_arr[@]} | cut -f ${VM_SRC} -d " ")
                   echo public_ip:  ${PUBLIC_IP_ON_VM_SRC}
                   CURRENT_CONNECTIONS_NUMBER=0
                   if [[ $VM_SRC != $VM_DEST  ]]
                   then

                       CURRENT_CONNECTIONS_NUMBER=$(get_bandwidth ${VM_SRC} ${VM_DEST} | wc -w)
                       LATENCY_VALUES=$(get_latency ${VM_SRC} ${VM_DEST})
                       BANDWIDTH_VALUES=$(get_bandwidth ${VM_SRC} ${VM_DEST})
                       WG_INDEX_ON_COL=1

                      for ((wg_connect_index=${APPLIED_RULES_WG_CONNECTIONS}; wg_connect_index<$[${CURRENT_CONNECTIONS_NUMBER}+${APPLIED_RULES_WG_CONNECTIONS}]; wg_connect_index++))
                      do 
                                  LATENCY_VALUE=$(echo ${LATENCY_VALUES} | cut -f  ${WG_INDEX_ON_COL} -d " ")
                                  BANDWIDTH_VALUE=$(echo ${BANDWIDTH_VALUES} | cut -f ${WG_INDEX_ON_COL} -d " ")
                                  echo $field " " ${BANDWIDTH_VALUE}
                                  echo ssh  -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP_ON_VM_SRC} "sudo tcset ${MESH_NETWORK_INTERFACE}${wg_connect_index} --rate ${BANDWIDTH_VALUE}Mbit/s --delay ${LATENCY_VALUE}ms"
                                  ssh  -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP_ON_VM_SRC} "sudo tcset ${MESH_NETWORK_INTERFACE}${wg_connect_index} --rate ${BANDWIDTH_VALUE}Mbit/s --delay ${LATENCY_VALUE}ms"
                                  WG_INDEX_ON_COL=$[${WG_INDEX_ON_COL}+1]
                       done
                      APPLIED_RULES_WG_CONNECTIONS=$[${CURRENT_CONNECTIONS_NUMBER}+${APPLIED_RULES_WG_CONNECTIONS}]


                   fi
        done
done





