#!/bin/bash 

if [ "$#" -lt 2 ]
then
  echo "Usage: $0 <client-ip> <comma-separated-username@server_ip:/home_address> "
  exit
fi
# We measure bandwidth for 10 seconds
CLIENT_IP=$1
SERVER_ADDS=$2

echo client_ip:${CLIENT_IP}
echo server_add:${SERVER_ADDS}
# Time is in  seconds
IPERF_DURATION=20
echo IPERF3 is performing in ${IPERF_DURATION} seconds

for server_add in ${SERVER_ADDS}
do
     #SSH_HOST=${server_add%:*}
     IP_HOST=$(echo ${server_add%:*}| cut -f 2 -d '@')
     echo iperf3 -c ${IP_HOST} -t ${IPERF_DURATION}
     DATE_TIME=$(date +"%m%d%Y""%H%M%S")
     iperf3 -c ${IP_HOST} -t ${IPERF_DURATION}>>iperf_${CLIENT_IP}_${IP_HOST}_${DATE_TIME}

     echo iperf3 -c ${IP_HOST} -t ${IPERF_DURATION} -R
     iperf3 -c ${IP_HOST} -t ${IPERF_DURATION} -R>>iperf_R_${CLIENT_IP}_${IP_HOST}_${DATE_TIME}
done











