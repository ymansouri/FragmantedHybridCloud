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
  WG_ID=$(echo $1| cut -f 2 -d ' ')
  LINK_ID=$(echo ${MESH_NETWORK_INTERFACE}${WG_ID})
  #echo  ${NODE_ID} ${LINK_NUMBER}
  # find connection link in the file which ncludes the connection links in mesh network
  while read connection_link_string
  do

      #echo ${connection_link_string}
      #echo "${NODE_ID} ${LINK_NUMBER}"
      if  grep -q "\b${NODE_ID} ${LINK_ID}\b" <<< "${connection_link_string}"
      then

            echo ${connection_link_string}
            break
     fi
  done < ${MESH_NETWORK_CONNECTED_LINKS_FILE}
}

#find_connection_link  "0 10"


function cut_connection_link(){
    #0 wg2 10.33.184.75 10.10.104.1/32 2 wg1 10.33.184.57 10.10.104.2/32
    connection_link_string=$1
    SRC_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 3 -d ' ')
    echo ${SRC_PUBLIC_IP}
    #echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 2 -d ' ')"
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${SRC_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 2 -d ' ')"

   # ssh into des VM and turn down wg 
    DES_PUBLIC_IP=$(echo ${connection_link_string}|cut -f 7 -d ' ')

    #echo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 6 -d ' ')" 
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${DES_PUBLIC_IP} "sudo wg-quick down $(echo ${connection_link_string}| cut -f 6 -d ' ')"

}



# update two files (MESH_NETWORK_CONNECTED_LINK_FILE and MESH_NETWORK_NOCONNECTED_LINK_FILE) in order to have  a list of existing  links and disconnected links in mesh network
function update_existing_connection_link()
{
    connection_link_string=$1
    echo "${connection_link_string}" >> ${MESH_NETWORK_NOCONNECTED_LINKS_FILE}

   # remove  connection_link_string from  MESH_NETWORK_NOCONNECTED_LINK_FILE
   shorted_connection_link_string=$(echo ${connection_link_string}| cut -f 1-2 -d ' ')
   #shorted_connection_link_string=$(find_connection_link  "${connection_link_string}")


   #a=$(echo "${shorted_connection_link_string}" | sed -e 's|\/|\\/|g')
   a=$(echo "${connection_link_string}" | sed -e 's|\/|\\/|g')
   sed -i "/${a}/d" ${MESH_NETWORK_CONNECTED_LINKS_FILE}

}

#update_existing_connection_link "0 10"

#Step_2: remove  connection links in mesh network
CONNECTION_LINKS_FOR_CUT=$1
#echo ${CONNECTION_LINKS_FOR_CUT}

[ -e ${MESH_NETWORK_NOCONNECTED_LINKS_FILE} ]

IFS=','
for connection_link in ${CONNECTION_LINKS_FOR_CUT}
do
   connection_link_trim=$(echo ${connection_link}| sed 's/^ *//g')
   connection_str=$(find_connection_link "${connection_link_trim}")

   if [[ -z ${connection_str} ]]
   then
         echo connection ${connection_link} is not available at  mesh network!
   else


         cut_connection_link "${connection_str}"
         date=`date`
         echo Removing  "${connection_str%%+([[:space:]])}" at $date| xargs
         update_existing_connection_link "${connection_str}"
   fi
done
unset IFS





