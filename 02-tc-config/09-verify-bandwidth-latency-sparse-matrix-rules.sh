#!/bin/bash

########################

# This code will verify the incoming and outgoing rules on all the interfaces.

#######################



. config
if [[ $# < 2 ]]
then
  echo Usage $0 bandwidths.csv latencies.csv
  exit
fi

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE_TCSET}
public_ip_arr=(${public_ip_arr})
echo PUBLIC_IP:  ${public_ip_arr[@]}

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)
echo ${VM_NUMBER}


#SHOW_COMMAND=$(echo sudo tcshow ${NETWORK_INTERFACE})

echo ${SHOW_COMMAND}


function get_mesh_network_interface ()
{
   IP=$1
   WG_NAME=$(ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} "ip a| grep wg| grep inet|xargs -l |cut -f 5 -d ' ' ")
   echo ${WG_NAME}
}



echo "===========================" Latencies

cat ${1}
for IP in ${public_ip_arr[@]}
do
   t=""
   mesh_network_interfaces=$(get_mesh_network_interface  ${IP})
   for inter in ${mesh_network_interfaces}
   do
      SHOW_COMMAND=$(echo sudo tcshow $inter)

      t=$t" "$(ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${SHOW_COMMAND} | jq -c '.'${inter}'.outgoing | del(.[]|."filter_id")|.[].delay')

   done
   echo $t|sed 's/null/0/g'|sed 's/ms//g'
done


echo "========================" Bandwidths
cat ${2}
for IP in ${public_ip_arr[@]}
do
   t=""
   mesh_network_interfaces=$(get_mesh_network_interface  ${IP})
   for inter in ${mesh_network_interfaces}
   do
      SHOW_COMMAND=$(echo sudo tcshow $inter)

      t=$t" "$(ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${SHOW_COMMAND} | jq -c '.'${inter}'.outgoing | del(.[]|."filter_id")|.[].rate')

   done
   echo $t|sed 's/null/0/g'|sed 's/Mbps//g'
done




