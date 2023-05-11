#!/bin/bash 

. config

PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})

PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})

echo -e "\e[44mINSTALLING IPERF3 ON ALL NODES\e[0m"



VMS_NUMBER=$(echo ${ALL_DESTINATIONS}|tr ',' '\n'|wc -l)
TINC_IPS=
for i in $(seq ${VMS_NUMBER})
do 
     TINC_IP=${TINC_SUBNET%.*}.${i}
     TINC_IPS=${TINC_IPS}" "${TINC_IP}
done


# start iperf3 on server side
function start_iperf_on_server_side (){
#$1:server_address:ubuntu@10.33.184.X:/home/ubuntu
IFS=,
for server_add in ${1}
do
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${server_add%:*}  "iperf3 -s -D"
done
unset IFS
}

#stop iperf3 on server side 
function stop_iperf_on_server_side (){
#$1:server_address:ubuntu@10.33.184.X:/home/ubuntu
IFS=,
for server_add in ${1}
do
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${server_add%:*}  "pkill iperf3"
done
unset IFS
}


# We measure bandwidth  for 10 seconds: i.e., iperf3 ip_address -t 10 --- Here we measure latency on both tinc connection and virtual connection (ens3)
echo -e "\e[44mBANDWIDTH MEASUREMENT ON VIRTUAL LAYER\e[0m"
for ip in ${PUBLIC_IPS}
do
       echo ip: ${ip}
       SERVER_IPS=$(echo "${PUBLIC_IPS}" |sed "s/${ip}//")
       ALL_SERVERS=$(./hosts2dests.sh "${SERVER_IPS}" ${VM_USERNAME})

       ALL_DESTINATIONS=$(./hosts2dests.sh "${ip}" ${VM_USERNAME})

       #echo client_ip: ${ip}
       #echo ALL_SERVERS: ${ALL_SERVERS}

        start_iperf_on_server_side ${ALL_SERVERS}


        echo -e "\e[44mBANDWIDTH MEASUREMENT ON PRIVATE LAYER\e[0m"
        ./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/bandwidth-measurement-on-tinc-private-layers.sh" ${ip} "\"${ALL_SERVERS}\" "

        stop_iperf_on_server_side ${ALL_SERVERS}
done



