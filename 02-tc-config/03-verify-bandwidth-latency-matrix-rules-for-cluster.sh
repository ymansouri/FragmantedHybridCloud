#!/bin/bash

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


SHOW_COMMAND=$(echo sudo tcshow ${NETWORK_INTERFACE})
echo Bandwidths
for IP in ${public_ip_arr[@]}
do
  ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${SHOW_COMMAND} | jq -c '.ens3.outgoing | del(.[]|."filter_id")' | sed 's/\"//g' | sed 's/,/ /g' | sed 's/dst-network=//g' | sed 's#/32  protocol=ip# #g' | sed 's/}//g' | sed 's/{//g' | sed 's/://g' | sed 's/rate//g' | sed 's/delay//g' | sed 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//g' | sed 's/[0-9]*ms//g' | sed 's/Mbps/,/g'
done
cat ${1}

echo Latenicies
for IP in ${public_ip_arr[@]}
do
  ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ${VM_USERNAME}@${IP} ${SHOW_COMMAND} | jq -c '.ens3.outgoing | del(.[]|."filter_id")' | sed 's/\"//g' | sed 's/,/ /g' | sed 's/dst-network=//g' | sed 's#/32  protocol=ip# #g' | sed 's/}//g' | sed 's/{//g' | sed 's/://g' | sed 's/rate//g' | sed 's/delay//g' | sed 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//g' | sed 's/[0-9]*Mbps//g' | sed 's/ms/,/g'
done
cat ${2}

