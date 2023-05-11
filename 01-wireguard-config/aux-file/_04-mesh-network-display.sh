#!/bin/bash 

. config

# This code want to disable several links in mesh network  which was build based on wg connection

if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <space-separated-<wg_ips>"
  exit
fi

WG_IPS=$1

#wg_connection_record includes <public_ip1, public_ip2, wg_ip1_on_node1, wg_ip2_on_node2>: This record is reterived from file 02-tc-config/default_files/ mesh_network_wg_ips.csv
function get_wg_connection_record ()
{

  wg_ip=$1
  while read wg_record
  do
     if grep -q "$wg_ip" <<< "$wg_record"; then
        result=$(echo ${wg_record}|cut -f 2,3,8,9  -d ' ')
     fi
   done < ${MESH_NETWORK_MATRIX_IPS_FILE}
  echo $result
}

function get_wg_interface()
{
   wg_ip_1=$1
   wg_ip_2=$2
   public_ip_1=$3
   public_ip_2=$4

   # TINC IP for client side, which should NOT run iperf -c ip
   rm ~/.ssh/known_hosts >/dev/null 2>&1
   WG_INTERFACE_1=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${public_ip_1} "ip a| grep 10.10.102.1| cut -f 1 -d '/'|sed -e 's/^[[:space:]]*//'| cut -f 2 -d ' ' ")
   echo ${WG_INTERFACE_1}


}
get_wg_connection_record "10.10.102.1"



exit




#PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
#ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})

#PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})
#echo ${PRIVATE_IPS}

#VMS_NUMBER=$(echo ${ALL_DESTINATIONS}|tr ',' '\n'|wc -l)
#echo vm_number: ${VMS_NUMBER}


for wgip in ${WG_IPS}
do
   WG_RECORD=$(get_wg_connection_record "$wgip")

   #IP_HOST=$(echo ${WG_RECORD}| cut -f 1 -d ' ')
   #echo ${SSH_HOST}
   #ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@{IP_HOST}  "sudo wg-quick down ; sudo systemctl daemon-reload;sudo systemctl enable tinc@${VPN_NAME}"

done


exit


ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST}  "sudo systemctl unmask tinc; sudo systemctl daemon-reload;sudo systemctl enable tinc@${VPN_NAME}"


#
TINC_IPS=
for i in $(seq ${VMS_NUMBER})
do 
     TINC_IP=${TINC_SUBNET%.*}.${i}
     TINC_IPS=${TINC_IPS}" "${TINC_IP}
done
echo ${TINC_IPS}

# We measured ping for 10 times: i.e., ping -c 10 ip_address-- Here we measure latency on both tinc connection and virtual connection (ens3)
./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "tinc/tinc-ping.sh" "\"${TINC_IPS}\""
./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "tinc/tinc-ping.sh" "\"${PRIVATE_IPS}\""





