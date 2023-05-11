#!/bin/bash

# This script creates tinc-up, tinc-down file.


if [ "$#" -lt 3 ]
then
  echo "Usage: $0 <VPN_NAME> <TINC_SUBNET> <HOST_IP>"
  exit
fi

VPN_NAME=$1
TINC_SUBNET=$2
HOST_IP=$3

# Tinc-up
cat << EOTINCUP > /etc/tinc/${VPN_NAME}/tinc-up
#!/bin/sh
ip link set \$INTERFACE up
ip addr add ${HOST_IP}/32 dev \$INTERFACE
ip route add ${TINC_SUBNET} dev \$INTERFACE
EOTINCUP


#Tinc-down
cat << EOTINCDOWN > /etc/tinc/${VPN_NAME}/tinc-down
#!/bin/sh
ip route del ${TINC_SUBNET} dev \$INTERFACE
ip addr del ${HOST_IP}/32 dev \$INTERFACE
ip link set \$INTERFACE down
EOTINCDOWN



















