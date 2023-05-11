#!/bin/bash 

if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <space-separated-tinc-ips> <tinc-interface>"
  exit
fi

TINC_IPS=$1
NETWORK_INTERFACE=$2
SOURCE_IP=$(ip a | grep ${NETWORK_INTERFACE}| grep inet| cut -f 1 -d '/'|awk '{$1=$1};1'| cut -f 2 -d ' ')
#PRIVATE_NETWORK_SOURCE_IP=$(ip a | grep ${RIVATE_NETWORK_INTERFACE}| grep inet| cut -f 1 -d '/'|awk '{$1=$1};1'| cut -f 2 -d ' ')


for ip in ${TINC_IPS}
do
   #ping $ip  -c 10
   latency=$(ping $ip -q -c 10|grep rtt|cut -f 2 -d '='|cut -f 2 -d '/')
   echo ${SOURCE_IP} "--->" $ip  "---" $latency
done











