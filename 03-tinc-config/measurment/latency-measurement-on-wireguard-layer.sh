#!/bin/bash 

if [ "$#" -lt 1 ]
then
  echo "Usage: $0  <network-interface>"
  exit
fi

# We measure ping for 10 times on WireGuard interface. Auusmed that  server and client ips on wireguard inteface end up with X.X.X.1 and  X.X.X.2, respectively (as we had the same assumption in 01-wireguard-config/02-mesh-network-creation) 

NETWORK_INTERFACE=$1
# Time is in  seconds
PING_DURATION=10

echo PING is performing in ${PING_DURATION} seconds


SOURCE_IPS=$(ip a | grep ${NETWORK_INTERFACE}| grep inet| cut -f 1 -d '/'|awk '{$1=$1};1'| cut -f 2 -d ' ')

for wg_ip_src in ${SOURCE_IPS}
do
      if [ "$(echo ${wg_ip_src}|cut -f 4 -d '.')" == "1" ]
      then
            wg_ip_des=$(echo ${wg_ip_src}| sed 's/\.[0-9]*$/.2/')
            latency=$(ping ${wg_ip_des} -q -w ${PING_DURATION}|grep rtt|cut -f 2 -d '='|cut -f 2 -d '/')
            echo ${wg_ip_src} "--->" ${wg_ip_des}  "---" $latency

     else
            wg_ip_des=$(echo ${wg_ip_src}| sed 's/\.[0-9]*$/.1/')
            latency=$(ping ${wg_ip_des} -q -w ${PING_DURATION}|grep rtt|cut -f 2 -d '='|cut -f 2 -d '/')
            echo ${wg_ip_src} "--->" ${wg_ip_des}  "---" $latency
     fi
done











