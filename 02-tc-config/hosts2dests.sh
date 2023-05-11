#!/bin/bash

#$1 - PUBLIC IPS
#$2 - VM USERNAME

if [ "$#" -lt 2 ]
then
  echo "Usage: $0 <space-separated-public-ips> <vm-username> "
  exit
fi

DESTS=
for HOST in $1
  do
    DESTS=${DESTS},${2}@${HOST}:/home/${2}
  done
echo ${DESTS#,}


