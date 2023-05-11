#!/bin/bash

# Adjust /etc/hosts to include the server name
LINE_TO_APPEND="127.0.0.1 `cat /etc/hostname`"
grep "${LINE_TO_APPEND}" /etc/hosts > /dev/null

#step 1: installing iperf3

sudo apt update -y
sudo apt -y install iperf3

