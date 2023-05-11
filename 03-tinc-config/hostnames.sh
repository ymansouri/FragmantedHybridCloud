#!/bin/bash

#$1 - PUBLIC IPS
#$2 - VM USERNAME
. config 

if [ "$#" -lt 2 ]
then
  echo "Usage: $0 <space-separated-public-ips> <vm-username> "
  exit
fi

HOSTNAME=
for HOST in $1
  do
    hostn=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${2}@${HOST} "cat /etc/hostname")
    HOSTNAME=${HOSTNAME},${hostn}
   done
echo ${HOSTNAME#,}


