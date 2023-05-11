#!/bin/bash 

. config


PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})

PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})
#echo ${PRIVATE_IPS}


#step 3: we add IPs allocated to wg  in each host if wg acts as server on the host (i.e., if IP allocated to wg ends with X.X.X.1).


function set_wg_ips_in_host_file(){
  #echo IN FUNCTION:  ${1}
  while IFS= read -r wg_ip ; 
  do 
      #echo wg_ip: $wg_ip
      if [ "$(echo $wg_ip|cut -f 4 -d '.')" == "1" ]
      then
            echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST} "echo Address = ${wg_ip} | sudo tee -a /etc/tinc/${VPN_NAME}/hosts/${HOST_NAME}"
      fi
  done <<< "$1"
}



IFS=","
WG_SUBNET_PREFIX=$(echo ${WG_SUBNET}| cut -f 1-2 -d '.')
echo ${WG_SUBNET_PREFIX}

for DESTINATION in ${ALL_DESTINATIONS}
do

  SSH_HOST=${DESTINATION%:*}
  rm ~/.ssh/known_hosts >/dev/null 2>&1
  echo ssh_host: ${SSH_HOST}
  HOST_NAME=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST%:*} "cat /etc/hostname" |  sed 's/-/_/g')
  echo host_name: ${HOST_NAME}
  #echo command=$(ip a | grep "${WG_SUBNET_PREFIX}"| sed -e 's/^[[:space:]]*//'| cut -f 2 -d ' '| cut -f 1 -d '/')

  WG_IPS=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST} "ip a | grep ${MESH_NETWORK_INTERFACE} |grep "${WG_SUBNET_PREFIX}"| sed -e 's/^[[:space:]]*//'| cut -f 2 -d ' '| cut -f 1 -d '/'")
  #echo wg_ip: ${WG_IPS}
  set_wg_ips_in_host_file ${WG_IPS}
done
unset IFS










