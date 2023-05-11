#!/bin/bash

##########################

# Install python3-pip and tcconfig on all nodes

#########################

. config

IFS=,$'\n' read -d '' -r -a ip_arr < ${PUBLIC_IPS_FILE_TCSET}
ip_arr=(${ip_arr})

echo ip_arr: ${ip_arr[@]}

for IP in "${ip_arr[@]}";
do
    ssh -o StrictHostKeyChecking=no -i $SSH_KEY_FILE $VM_USERNAME@${IP} "sudo apt update; sudo apt install python3-pip -y ; sudo pip install tcconfig"
done


# tcconfig verification
#https://tcconfig.readthedocs.io/en/latest/pages/introduction/index.html
#tcset -V
