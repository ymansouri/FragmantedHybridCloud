#!/bin/bash

# Adjust /etc/hosts to include the server name
LINE_TO_APPEND="127.0.0.1 `cat /etc/hostname`"
grep "${LINE_TO_APPEND}" /etc/hosts > /dev/null



#step 1: tinc 1.0 installation
#sudo apt update -y
#sudo apt -y install tinc



# Step 1: tinc 1.1  installation  using  Debian package
sudo apt update -y
#dependency
sudo apt-get install libminiupnpc17
#wget http://http.us.debian.org/debian/pool/main/t/tinc/tinc_1.1~pre18-1_amd64.deb
sudo dpkg --install tinc_1.1~pre18-1_amd64.deb



#tinc installation check 
#tinc --version
