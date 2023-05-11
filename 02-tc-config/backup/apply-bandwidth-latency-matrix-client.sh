#!/bin/bash
. config

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})
#echo PUBLIC_IP:  ${public_ip_arr[@]}

IFS=,$'\n' read -d '' -r -a private_ip_arr < ${PRIVATE_IPS_FILE}
private_ip_arr=(${private_ip_arr})
#echo PRIVATE_IP: ${private_ip_arr[@]}

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)
#echo ${VM_NUMBER}


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

#rm tc-command-file

# Apply TC rules on each node in PUBLIC_IP_LIST
PUBLIC_IP_INDEX=0
for SOUR_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}`
do
        PUBLIC_IP_INDEX=$(( ${PUBLIC_IP_INDEX} + 1 ))
        PUBLIC_IP=$(echo ${public_ip_arr[@]} | cut -f ${PUBLIC_IP_INDEX} -d" ")
        SOUR_PRIVATE_IP=$(echo ${private_ip_arr[@]} | cut -f ${SOUR_PRIVATE_IP_INDEX} -d" ")

        # Execute TC commands common to all nodes and rules to prevent showing an error that the rule already exists
        ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "rm -f tc-command-file ; sudo tcset ${NETWORK_INTERFACE} --rate 1Mbit/s --delay 1ms --loss 1%  --network 0.0.0.0 --tc-command | head -n 2 >> tc-command-file"
        for DEST_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}` 
        do
                   DEST_PRIVATE_IP=$(echo ${private_ip_arr[@]} | cut -f ${DEST_PRIVATE_IP_INDEX} -d " " )

	           if [[ $SOUR_PRIVATE_IP_INDEX != $DEST_PRIVATE_IP_INDEX  ]]
                   then
                       # cut first two lines that contain the common rules, these are executed one each node only once
                      ssh  -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo tcset ${NETWORK_INTERFACE} --rate $(get_bandwidth ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})Mbit/s  --delay $(get_latency ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})ms --loss $(get_packetloss ${SOUR_PRIVATE_IP_INDEX} ${DEST_PRIVATE_IP_INDEX})%  --network ${DEST_PRIVATE_IP} --tc-command --add |tail -n +3 >> tc-command-file"
                   fi
        done
        echo ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo bash tc-command-file"
        ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo bash tc-command-file"
done

