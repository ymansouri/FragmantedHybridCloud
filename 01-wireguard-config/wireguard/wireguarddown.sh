#!/bin/bash

if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <wireguard-interface-prefix>"
  exit
fi


#manually to remove a  network interface
#sudo ip link delete  [network_interface]


WG_INTERFACES_LIST=$(ip a | grep ${1}[0-9]|grep inet| grep ${1}[0-9]| awk '{print $NF}')
for wg_id in  ${WG_INTERFACES_LIST}
do
    sudo wg-quick down ${wg_id}
done
















