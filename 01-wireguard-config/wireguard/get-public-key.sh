#!/bin/bash

. config

if [[ "$1" == "" ]]
then
  echo "Usage: $0 <HOST_IP>"
  exit
fi
rm ~/.ssh/known_hosts >/dev/null 2>&1
SSH_HOST=${VM_USERNAME}@$1

ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_HOST}  "sudo cat /etc/wireguard/public.key"



