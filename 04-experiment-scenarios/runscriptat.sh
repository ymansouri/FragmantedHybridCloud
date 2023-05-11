#!/bin/bash 

#$1 - ips
#$2 - ssh key
#$3 - scriptname
#$4-... arguments for script

if [ "$#" -lt 2 ]
then
  echo "Usage: $0 <Comma-separated-user@ips:/path> <ssh.key> <script-name> [arguments...]"
  exit
fi

SCRIPTNAME=$3
SCRIPTBASENAME=$(basename ${SCRIPTNAME})
DESTINATIONS=$1
SSH_KEY=$2

shift 3
IFS=","
for DESTINATION in ${DESTINATIONS}
do
  SSH_HOST=${DESTINATION%:*}
  #rm ~/.ssh/known_hosts >/dev/null 2>&1

  echo scp -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SCRIPTNAME} ${DESTINATION}
  scp -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SCRIPTNAME} ${DESTINATION}

  echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_HOST} chmod +x ./${SCRIPTBASENAME}
  ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_HOST} chmod +x ./${SCRIPTBASENAME}

  echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_HOST} ./${SCRIPTBASENAME} $*
  ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_HOST} ./${SCRIPTBASENAME} $*
  sleep 5
done
unset IFS
