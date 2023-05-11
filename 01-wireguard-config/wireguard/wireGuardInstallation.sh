#!/bin/bash

# Adjust /etc/hosts to include the server name
echo 127.0.0.1 `cat /etc/hostname` | tee --append /etc/hosts

# Installing wireGuard
#add-apt-repository -y ppa:wireguard/wireguard
apt-get -y update
#sudo apt-get -y install libmnl-dev libelf-dev linux-headers-$(uname -r) build-essential pkg-config
apt-get -y install wireguard-tools

cd /etc/wireguard
PRIVATEKEY=$(wg genkey)
PUBLICKEY=$(echo $PRIVATEKEY | wg pubkey)
echo $PRIVATEKEY | tee private.key
chmod 600 private.key
echo $PUBLICKEY | tee public.key


# set IP_FORWARDINING to ONE
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf
