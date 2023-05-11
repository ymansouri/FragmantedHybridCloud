#!/bin/bash 

. config


# This code want to disable several links in mesh network  which was built based on wg connection. Each <node_id link_number> is sperated by comma.
#inout format example:  <0 4, 1 3>: This input format indicates taht  node 0 with wg4 and node 1 with wg3 will be disconned from mesh network.
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <comma-separated-<node_id link_number>"
  exit
fi



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
  done < ${MESH_NETWORK_CONNECTED_LINKS_FILE}
}


function cut_connection_link(){
    #0 wg2 10.33.184.75 10.10.104.1/32 2 wg1 10.33.184.57 10.10.104.2/32
    connection_link_string=$1
    SRC_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 3 -d ' ')
    SRC_WG=$(echo ${connection_link_string}|cut -f 2 -d ' ')

    #reterive  latency and bandwidth on the link from source node side
    SRC_LATN=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo tcshow  ${SRC_WG}| grep delay|cut -f 2 -d ':'|sed 's/\"//g'|sed 's/.$//'")
    SRC_BAND=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo tcshow  ${SRC_WG}| grep rate|cut -f 2 -d ':'|sed 's/\"//g'|sed 's/.$//'")
   # SSH into source VM and turn down wg
    #echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 2 -d ' ')"
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 2 -d ' ')"

   # ssh into des VM and turn down wg 
    DES_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 7 -d ' ')
    DES_WG=$(echo ${connection_link_string}|cut -f 6 -d ' ')
    DES_BAND=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo tcshow  ${DES_WG}| grep rate|cut -f 2 -d ':'|sed 's/\"//g'|sed 's/.$//'")

    #echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 6 -d ' ')" 
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 6 -d ' ')"
    echo "${SRC_LATN} ${SRC_BAND} ${DES_BAND}"

}



# update two files (MESH_NETWORK_CONNECTED_LINK_FILE and MESH_NETWORK_NOCONNECTED_LINK_FILE) in order to have  a list of existing  links and disconnected links in mesh network
function update_existing_connection_link()
{
    connection_link_string=$1
    connection_link_late_band=$2
   # add  connection link string to MESH_NETWORK_CONNECTED_LINK_FILE
    echo "${connection_link_string} ${connection_link_late_band}">> ${MESH_NETWORK_NOCONNECTED_LINKS_FILE}

   # remove  connection_link_string from  MESH_NETWORK_NOCONNECTED_LINK_FILE
   shorted_connection_link_string=$(echo ${connection_link_string}| cut -f 1-2 -d ' ')
   sed -i "/${shorted_connection_link_string}/d" ${MESH_NETWORK_CONNECTED_LINKS_FILE}
}





#Step_2: remove  connection links in mesh network
CONNECTION_LINKS_FOR_CUT=$1
echo -e "\e[44mDESPLAY MESH NETWORK FOR ${VMS_NUMBER} VMS\e[0m"
[ -e ${MESH_NETWORK_NOCONNECTED_LINKS_FILE} ]

IFS=','
for connection_link in ${CONNECTION_LINKS_FOR_CUT}
do
   connection_link_trim=$(echo ${connection_link}| sed 's/^ *//g')
   connection_str=$(find_connection_link "${connection_link_trim}")
   echo -e "\e[44mcut_connection_link "${connection_str}"\e[0m"

   if [[ -z ${connection_str} ]]
   then
         echo connection ${connection_link} is not available at  mesh network!
   else
         connection_str_late_band=$(cut_connection_link "${connection_str}")
         #update_existing_connection_link "${connection_str}" "${connection_str_late_band}"
         update_existing_connection_link "${connection_str}"

   fi
done
unset IFS












