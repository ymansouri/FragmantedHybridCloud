#!/bin/bash

##############################

# This code help to apply latency and bandwidth rules on all nodes using tcconfig

##############################


. config

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE_TCSET}
public_ip_arr=(${public_ip_arr})

IFS=,$'\n' read -d '' -r -a private_ip_arr < ${PRIVATE_IPS_FILE_TCSET}
private_ip_arr=(${private_ip_arr})

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)


#$1: source $2: destination in latency matrix
function get_latency () {
  sed "${1}q;d" ${LATENCY_FILE} | cut -f $2 -d","
}


#$1: source $2: destination in bandwidth matrix
function get_bandwidth () {
 sed "${1}q;d" ${BANDWIDTH_FILE} | cut -f $2 -d","
}


#$1: source $2: destination in packetloss matrix
function get_packetloss () {
 sed "${1}q;d" ${PACKETLOSS_FILE} | cut -f $2 -d","
}


# Apply TC rules on each node in PUBLIC_IP_LIST
PUBLIC_IP_INDEX=0
for SOUR_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}`
do
        PUBLIC_IP_INDEX=$(( ${PUBLIC_IP_INDEX} + 1 ))
        PUBLIC_IP=$(echo ${public_ip_arr[@]} | cut -f ${PUBLIC_IP_INDEX} -d" ")
        SOUR_PRIVATE_IP=$(echo ${private_ip_arr[@]} | cut -f ${SOUR_PRIVATE_IP_INDEX} -d" ")

        ROOT_HANDLE=1602
        #ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo /usr/sbin/tc qdisc add dev ${NETWORK_INTERFACE} root handle ${ROOT_HANDLE}: htb default 1 ; sudo /usr/sbin/tc class add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}: classid ${ROOT_HANDLE}:1 htb rate 32000000.0kbit"
        CMD="sudo /usr/sbin/tc qdisc add dev ${NETWORK_INTERFACE} root handle ${ROOT_HANDLE}: htb default 1 ; sudo /usr/sbin/tc class add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}: classid ${ROOT_HANDLE}:1 htb rate 32000000.0kbit"
        #echo Preliminary work on ${PUBLIC_IP}
        for DEST_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}` 
        do
                   DEST_PRIVATE_IP=$(echo ${private_ip_arr[@]} | cut -f ${DEST_PRIVATE_IP_INDEX} -d " " )
	           if [[ ${SOUR_PRIVATE_IP_INDEX} != ${DEST_PRIVATE_IP_INDEX}  ]]
                   then
                        BANDWIDTH=$(get_bandwidth ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})
                        DELAY=$(get_latency ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})
                        DEST_VM_IP=${DEST_PRIVATE_IP}

                        # cut first two lines that contain the common rules, these are executed one each node only once
                        RULE_INDEX=$(( ${DEST_PRIVATE_IP_INDEX} + 100 ))
                        HANDLE_INDEX=$(( ${DEST_PRIVATE_IP_INDEX} + 1000 ))
                        #echo setting on ${PUBLIC_IP} rule for ${DEST_VM_IP} Rule index ${RULE_INDEX} HAndle ${HANDLE_INDEX}
                        #ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo /usr/sbin/tc class add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}: classid ${ROOT_HANDLE}:${RULE_INDEX} htb rate ${BANDWIDTH}Mbit ceil ${BANDWIDTH}Mbit burst ${BANDWIDTH}Mbit cburst ${BANDWIDTH}Mbit ; sudo /usr/sbin/tc qdisc add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}:${RULE_INDEX} handle ${HANDLE_INDEX}: netem delay ${DELAY}ms ; sudo /usr/sbin/tc filter add dev ${NETWORK_INTERFACE} protocol ip parent ${ROOT_HANDLE}: prio 5 u32 match ip dst ${DEST_VM_IP}/32 match ip src 0.0.0.0/0 flowid ${ROOT_HANDLE}:${RULE_INDEX}"
                        CMD=${CMD}" ; sudo /usr/sbin/tc class add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}: classid ${ROOT_HANDLE}:${RULE_INDEX} htb rate ${BANDWIDTH}Mbit ceil ${BANDWIDTH}Mbit burst ${BANDWIDTH}Mbit cburst ${BANDWIDTH}Mbit ; sudo /usr/sbin/tc qdisc add dev ${NETWORK_INTERFACE} parent ${ROOT_HANDLE}:${RULE_INDEX} handle ${HANDLE_INDEX}: netem delay ${DELAY}ms ; sudo /usr/sbin/tc filter add dev ${NETWORK_INTERFACE} protocol ip parent ${ROOT_HANDLE}: prio 5 u32 match ip dst ${DEST_VM_IP}/32 match ip src 0.0.0.0/0 flowid ${ROOT_HANDLE}:${RULE_INDEX}"
                   fi
        done
        ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "${CMD}" 
done

#######JUST FOR REFERENCE - How to apply rules using tcset##########

#                      ssh  -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} 
#"sudo tcset ${NETWORK_INTERFACE} --rate $(get_bandwidth ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})Mbit/s  
#--delay $(get_latency ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})ms 
#--loss $(get_packetloss ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})%  
#--network ${DEST_PRIVATE_IP} --tc-command --add >> tc-command-file"
