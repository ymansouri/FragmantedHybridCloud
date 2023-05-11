#!/bin/bash
# This file prepares WireGaurd configuration for consumer (OpenStack)

# $1 - donor public ip
# $2 - Wireguard VPN subnet
# $3 - consumer IP
# $4 - donor public key file

if [ "$4" == "" ]
then
  echo "Usage: $0 <DONOR_PUBLIC_IP:port> <VPN_SUBNET> <VPN_CONSUMER_IP> <DONOR_PUBLIC_KEY>"
  exit 1
fi

echo "[Interface]"
echo "PostUp = wg set %i private-key /etc/wireguard/private.key"
echo "Address =" $3
echo "SaveConfig = true"

echo "[Peer]"
echo "AllowedIPs =" $2
echo "PersistentKeepalive = 21"
echo "PublicKey =" $4
echo "Endpoint =" $1
