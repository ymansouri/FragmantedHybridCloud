#!/bin/bash 

. config

# This code want to disable several links in mesh network  which was build based on wg connection. each <node_id link_number> is sperated by comma.

if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <comma-separated-<node_id link_number>"
  exit
fi


# Find the connection link string in  MESH_NETWORK_NOCONNECTED_LINKS_FILE
function find_connection_link()
{
  NODE_ID=$(echo $1| cut -f 1 -d ' ')
  str=$(echo $1| cut -f 2 -d ' ')
  LINK_NUMBER=$(echo ${MESH_NETWORK_INTERFACE}$str)
  #echo  ${NODE_ID} ${LINK_NUMBER}
  # find connection link in the file which ncludes the connection links in mesh network
  while read connection_link_string
  do
      #echo ${connection_link_string}
      #echo "${NODE_ID} ${LINK_NUMBER}"
      if  grep -q "${NODE_ID} ${LINK_NUMBER}" <<< "${connection_link_string}"
      then

            echo ${connection_link_string}
            break
      fi 
  done < ${MESH_NETWORK_NOCONNECTED_LINKS_FILE}   
}


#This function recover (turn up wireguard interface) on a  pair of node connected through connection_link_string
function recover_connection_link(){
    connection_link_string=$1

   # SSH into source VM and turn down wg 
    SRC_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 3 -d ' ')
    echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick up $(echo ${connection_link_string}| cut -f 2 -d ' ')" 
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick up $(echo ${connection_link_string}| cut -f 2 -d ' ')" 

   # ssh into des VM and turn down wg 
    DES_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 7 -d ' ')
    echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick up $(echo ${connection_link_string}| cut -f 6 -d ' ')" 
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick up $(echo ${connection_link_string}| cut -f 6 -d ' ')" 
}


# update two files (MESH_NETWORK_CONNECTED_LINK_FILE and MESH_NETWORK_NOCONNECTED_LINK_FIL) in order to have  a list of existing  links and disconnected links in mesh network
function update_existing_connection_link()
{
   connection_link_string=$1
   # add  connection link string to MESH_NETWORK_CONNECTED_LINK_FILE
   echo ${connection_link_string}>> ${MESH_NETWORK_CONNECTED_LINKS_FILE}

   # remove  connection_link_string from  MESH_NETWORK_NOCONNECTED_LINK_FILE
   shorted_connection_link_string=$(echo ${connection_link_string}| cut -f 1-2 -d ' ')
   sed -i "/${shorted_connection_link_string}/d" ${MESH_NETWORK_NOCONNECTED_LINKS_FILE}
}


#find_connection_link "0 1"
#recover_connection_link "0 wg1 10.33.184.75 10.10.103.1/32 2 wg0 10.33.184.57 10.10.103.2/32"
#update_existing_connection_link "0 wg1 10.33.184.75 10.10.103.1/32 2 wg0 10.33.184.57 10.10.103.2/32"


#Step_1: recover  links in mesh network 

CONNECTION_LINKS_FOR_RECOVER=$1
echo -e "\e[44mRECOVER LINKS IN  MESH NETWORK \e[0m"

IFS=','
for connection_link in ${CONNECTION_LINKS_FOR_RECOVER}
do
   connection_link_trim=$(echo ${connection_link}| sed 's/^ *//g')
   str=$(find_connection_link "${connection_link_trim}")

   echo -e "\e[44mrecover_connection_link "$str"\e[0m"
   
   recover_connection_link "$str"
   update_existing_connection_link "$str"

done
unset IFS












