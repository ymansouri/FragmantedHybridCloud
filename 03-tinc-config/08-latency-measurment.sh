#!/bin/bash 

. config

PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
ALL_DESTINATIONS=$(./hosts2dests.sh "${PUBLIC_IPS}" ${VM_USERNAME})


PRIVATE_IPS=$(cat ${PRIVATE_IPS_FILE})
#echo ${PRIVATE_IPS}


VMS_NUMBER=$(echo ${ALL_DESTINATIONS}|tr ',' '\n'|wc -l)
#echo vm_number: ${VMS_NUMBER}

TINC_IPS=
for i in $(seq ${VMS_NUMBER})
do
     TINC_IP=${TINC_SUBNET%.*}.${i}
     TINC_IPS=${TINC_IPS}" "${TINC_IP}
done
echo ${TINC_IPS}

# We measured ping for 10 times: i.e., ping -c 10 ip_address-- Here we measure latency on both tinc connection and virtual connection (ens3)

#echo -e "\e[44mPING MEASUREMENT ON TINC LAYER\e[0m"
#./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-tinc-private-layers.sh" "\"${TINC_IPS}\" ${IF_PREFIX}"

#echo -e "\e[44mPING MEASUREMENT ON WIREGUARD(MESHLAYER) LAYER\e[0m"
#./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-wireguard-layer.sh" "${MESH_NETWORK_INTERFACE}"

echo -e "\e[44mPING MEASUREMENT ON VIRTUAL LAYER\e[0m"
#./runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-tinc-private-layers.sh" "\"${PRIVATE_IPS}\" ${PRIVATE_NETWORK_INTERFACE}"
./fast-runscriptat.sh ${ALL_DESTINATIONS} ${SSH_KEY_FILE} "measurment/latency-measurement-on-tinc-private-layers.sh" "\"${PRIVATE_IPS}\" ${VPN_NAME}"

sleep 5




