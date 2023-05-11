#!/bin/bash
# This file prepares WireGaurd configuration for donor (Microsoft Azure)


# $1 - Wireguard port (51280)
# $2 - Donor/server VPN ip (10.10.10.1)
# $3 - CONSUMER/CLIENt VPN ip (10.10.10.2)
# $4 - CONSUMER/CLIENT public key 

if [ "$4" == "" ]
then
     echo "Usage: $0 <WIREGRAD_PORT> <SERVER_VPN_IP> <CLIENT_VPN_IP> <CLIENT_PUBLIC_KEY>"
     exit 1
fi

echo "[Interface]"
echo "Address =" $2
echo "SaveConfig = true"
echo "ListenPort =" $1
echo "PostUp = wg set %i private-key /etc/wireguard/private.key"
#echo "PostUp = wg set %i private-key /home/azureuser/private.key"

echo "[Peer]"
echo "AllowedIPs =" $3
echo "PublicKey =" $4

