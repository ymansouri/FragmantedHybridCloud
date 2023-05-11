#!/bin/bash

if [ "$#" -lt 1 ]
then
  echo "Usage: $0  <network-interface>"
  exit
fi

# We measure bandwidth for 10 times on WireGuard interface. Auusmed that  server and client ips on wireguard inteface end up with X.X.X.1 and  X.X.X.2, respectively (as we had the same assumptio$

NETWORK_INTERFACE=$1
# Time is in  seconds
IPERF_DURATION=20

echo PING is performing in ${PING_DURATION} seconds


SOURCE_IPS=$(ip a | grep ${NETWORK_INTERFACE}| grep inet| cut -f 1 -d '/'|awk '{$1=$1};1'| cut -f 2 -d ' ')

echo ${SOURCE_IPS}

for wg_ip_src in ${SOURCE_IPS}
do
      if [ "$(echo ${wg_ip_src}|cut -f 4 -d '.')" == "1" ]
      then

              DATE_TIME=$(date +"%m%d%Y""%H%M%S")
              wg_ip_des=$(echo ${wg_ip_src}| sed 's/\.[0-9]*$/.2/')

              echo iperf3 -c ${wg_ip_des} -t ${IPERF_DURATION}
              iperf3 -c ${wg_ip_des} -t ${IPERF_DURATION}>>iperf_${wg_ip_src}_${wg_ip_des}${DATE_TIME}

              echo iperf3 -c ${wg_ip_des} -t ${IPERF_DURATION} -R
              iperf3 -c ${wg_ip_des} -t ${IPERF_DURATION} -R>>iperf_R_${wg_ip_src}_${wg_ip_des}_${DATE_TIME}

       fi

done




