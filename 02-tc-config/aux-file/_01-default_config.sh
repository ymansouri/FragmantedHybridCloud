#!/bin/bash
. config



IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})
echo PUBLIC_IP:  ${public_ip_arr[@]}

IFS=,$'\n' read -d '' -r -a private_ip_arr < ${PRIVATE_IPS_FILE}
private_ip_arr=(${private_ip_arr})
echo PRIVATE_IP: ${private_ip_arr[@]}

VM_NUMBER=$(echo ${public_ip_arr[@]} | wc -w)
echo ${VM_NUMBER}



function get_latency () {
  #echo "in latency func:" $1 $2
  sed "${1}q;d" ${LATENCY_FILE} | cut -f $2 -d","
}

#t=$(get_latency 1 5)
#echo LATENCY: ${t}

function get_bandwidth () {
 #echo "in get bandwith:" $1   $2
 sed "${1}q;d" ${BANDWITH_FILE} | cut -f $2 -d","
}


# Create a IP MATRIX FILE  to simplify bandwidth and latency assignment between each pair of VMs
#for IP  in "${ip_arr[@]}"
#do
#        echo $(cat $PRIVATE_IPS) >> TEMP_IP_MATRIX_FILE.csv
#done


#function get_ip () {
# sed "${1}q;d" ${IP_MATRIX_FILE} | cut -f $2 -d","
#}



# Traverse across private IPS
PUBLIC_IP_INDEX=0

for SOUR_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}`

do
        PUBLIC_IP_INDEX=$(( ${PUBLIC_IP_INDEX} + 1 ))
        PUBLIC_IP=$(echo ${public_ip_arr[@]} | cut -f ${PUBLIC_IP_INDEX} -d" ")
        SOUR_IP=$(echo ${private_ip_arr[@]} | cut -f ${SOUR_PRIVATE_IP_INDEX} -d" ")

        echo public_index: ${PUBLIC_IP_INDEX}
        echo public_ip: ${PUBLIC_IP}
        echo sour_ip: ${SOUR_IP}
        for DEST_PRIVATE_IP_INDEX in `seq 1 1 ${VM_NUMBER}` 
		do
                   echo "INTERNAL FOR"
                  echo index: ${DEST_PRIVATE_IP_INDEX}
                   DEST_IP=$(echo ${private_ip_arr[@]} | cut -f ${DEST_PRIVATE_IP_INDEX} -d " " )
                   echo ${DEST_IP}

                   #DEST_IP=$(echo ${private_ip_arr[@]} | cut -f ${DEST_PRIVATE_IP_INDEX} -d" ")
	           #echo ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP}--rate "$(get_bandwidth $SOUR_IP $DEST_IP)"Mbit/s --delay "$(get_latency $SORC_IP $DEST_IP)"ms --network " "$SOURC_IP $DES_IP" " --add"
	           #echo ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo tcset ${NETWORK_INTERFACE} --rate "$(get_bandwidth $SOUR_IP $DEST_IP)"Mbit/s --delay "$(get_latency $SORC_IP $DEST_IP)"ms --network " "$SOURC_IP $DES_IP" " --add"
	           echo ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${PUBLIC_IP} "sudo tcset ${NETWORK_INTERFACE} --rate " $(get_bandwidth $SOUR_PRIVATE_IP_INDEX $DEST_PRIVATE_IP_INDEX) "Mbit/s --network " $SOUR_IP $DEST_IP " --add"
                   
		done
done

