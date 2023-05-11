#!/bin/bash

#######################

# Stop tinc on all VMs/nodes.

#######################

. config

PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})


ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})
echo ${ALL_DESTINATIONS}


# Step 1: Start tinc on all nodes using the specified network interface for tinc.

IFS=","
for DESTINATION in ${ALL_DESTINATIONS}
do
  SSH_HOST=${DESTINATION%:*}
  rm ~/.ssh/known_hosts >/dev/null 2>&1

  ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST}  "sudo tinc -n ${VPN_NAME} stop"
done
unset IFS



































