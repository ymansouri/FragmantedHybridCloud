#!/bin/bash


if [ "$#" -lt 2 ]
then
  echo "Usage: $0 <VPN_NAME> <ALL_HOST_NAMES>"
  exit
fi


#echo server_name: $1


VPN_NAME=$1



# extract hostname/VMname : we replcae '-' with '_' in vms hostmane because tinc does not accept '-'.
HOST_NAME=$(cat /etc/hostname | sed 's/-/_/g')


while true
do
  shift 1
  if ! [[ "${1}" == "" ]]
  then
     #echo "LocalDiscovery = yes" >>/etc/tinc/${VPN_NAME}/tinc.conf
     hostname=$(echo ${1}| sed 's/-/_/g')
     sudo tinc  -n ${VPN_NAME} add LocalDiscovery yes
     sudo tinc  -n ${VPN_NAME} add DirectOnly yes
     if  [ "$hostname" != "${HOST_NAME}" ]
     then
          sudo tinc -n ${VPN_NAME} add ConnectTo ${hostname}
     fi
  else
    break
  fi
done
