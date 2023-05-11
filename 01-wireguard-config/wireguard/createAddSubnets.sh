#!/bin/bash

. config

echo Running $0
# $1 - CLIENT_SUBNET (10.10.17.5/32) -- single VM IP because we have one VM in subnet
# $2 - SERVER_SUBNET (10.10.17.6/32)

if [ "$2" == "" ]
then
     echo "Usage: $0 <SERVER_SUBNET> <CLIENT_SUBNET>"
     exit 1
fi


SERVER_SUBNET=$1
CLIENT_SUBNET=$2


echo  Adding client subnet address to server's wg0.conf.
./add-subnet-to-wireguardconf.sh ${SERVER_SUBNET} ${CLIENT_SUBNET}


