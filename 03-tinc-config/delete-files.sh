#!/bin/bash 


. config 






IFS=,$'\n' read -d '' -r -a ip_arr < ${PUBLIC_IPS_FILE}
ip_arr=(${ip_arr})

echo ip_arr: ${ip_arr[@]}

for IP in "${ip_arr[@]}";
do
    ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${IP} "rm iperf*"
done







