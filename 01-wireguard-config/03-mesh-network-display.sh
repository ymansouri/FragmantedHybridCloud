#!/bin/bash 

##############################################

# This code will display several links in mesh network  which was build based on wg connection
# Please find the file named as (mesh_network_connected_links.csv) in 02-tc-config/default-files folder.

##############################################
. config



PUBLIC_IPS=$(cat ${PUBLIC_IPS_FILE})
VMS_NUMBER=$(echo ${PUBLIC_IPS}|wc -w)

# get connection links(ip and connection number(e.g., wg0)) from each node==> 
function get_connection_links()
{
     public_ip=$1
     rm ~/.ssh/known_hosts >/dev/null 2>&1
     WG_CONNECTIONS=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${public_ip} "ip a| grep ${MESH_NETWORK_INTERFACE}| grep inet| sed -e 's/^[[:space:]]*//'| cut -f 2,5 -d ' ' ")
     echo ${WG_CONNECTIONS}
}

# get the id of node ==> id is incremental number
function get_node_id()
{
  public_ip=$1
  NODE_ID=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${public_ip} "cat /etc/hostname|cut -f 6 -d '-' ")
  echo ${NODE_ID}
}

# get the corrosponding link in the destination node for each link in the source node 
function get_paired_connection_links()
{
   public_ip=$1
   wg_ip=$2
   REST_PUBLIC_IPS=$(echo "${PUBLIC_IPS}" |sed "s/${public_ip}//")   
   #wg_ip_subnet=$(echo ${wg_ip}|cut -f 1 -d '/'| cut -f 1-3 -d '.')
   wg_ip_subnet=$(echo ${wg_ip::-5})

   PAIRED_COONECTION_LINK=
   for ip in ${REST_PUBLIC_IPS}
   do

        ALL_WG_CONNECTIONS=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${VM_USERNAME}@${ip} "ip a| grep wg| grep inet |  sed -e 's/^[[:space:]]*//'| cut -f 2,5 -d ' ' ") 
        len=$(echo ${ALL_WG_CONNECTIONS}| wc -w)
        #echo $ip "  " ${ALL_WG_CONNECTIONS} " " $len

        for i in $(seq 1 2 $len)
        do
            connection_address=$(echo ${ALL_WG_CONNECTIONS}|cut -f $i -d ' ')
            link_number=$(echo ${ALL_WG_CONNECTIONS}|cut -f $(($i+1)) -d ' ')
            #echo str: $link_number

            if grep -q "${wg_ip_subnet}" <<< "${connection_address}"
            then
                  PARIED_CONNECTION_LINK=$(echo ${PARIED_CONNECTION_LINKS}" "$ip " " ${connection_address} " " ${link_number})
                  break
            fi
         done
     done
    echo ${PARIED_CONNECTION_LINK}
}

#create file  to record mesh network structure
echo -e "\e[44mDESPLAY MESH NETWORK FOR ${VMS_NUMBER} VMS\e[0m"
[ -e ${MESH_NETWORK_CONNECTED_LINKS_FILE} ] && rm  ${MESH_NETWORK_CONNECTED_LINKS_FILE}
echo "src_node_id" "src_link_num" "src_pub_ip" "src_mesh_ip"  "des_node_id" "des_link_num" "des_pub_ip" "des_mesh_ip">>${MESH_NETWORK_CONNECTED_LINKS_FILE}

for ip in ${PUBLIC_IPS}
do
    WG_CONNECTIONS_IN_SRC=$(get_connection_links $ip)
    #echo $ip "  " ${WG_CONNECTIONS_IN_SRC} 
    len=$(echo ${WG_CONNECTIONS_IN_SRC}| wc -w)

    for i in $(seq 1 2 $len)
    do
        connection_address=$(echo ${WG_CONNECTIONS_IN_SRC}|cut -f $i -d ' ')
        link_number=$(echo ${WG_CONNECTIONS_IN_SRC}|cut -f $(($i+1)) -d ' ')

        if [ "$(echo ${connection_address}|cut -f 1 -d '/'|cut -f 4 -d '.')" == "1" ]
        then
              #echo get_paired_connection_links $ip ${connection_address} 
              PAIRED_CONNECTION_LINKS=$(get_paired_connection_links $ip ${connection_address})
              src_node_id=$(get_node_id $ip)
              src_link_num=${link_number}
              src_pub_ip=$ip
              src_mesh_ip=$(echo ${connection_address}|cut -f 2 -d ' ')
              des_node_id=$(get_node_id $(echo ${PAIRED_CONNECTION_LINKS}|cut -f 1 -d ' '))
              des_link_num=$(echo ${PAIRED_CONNECTION_LINKS}|cut -f 3 -d ' ')
              des_pub_ip=$(echo ${PAIRED_CONNECTION_LINKS}|cut -f 1 -d ' ')
              des_mesh_ip=$(echo ${PAIRED_CONNECTION_LINKS}|cut -f 2 -d ' ')
              echo ${src_node_id}  ${src_link_num} ${src_pub_ip}  ${src_mesh_ip}  ${des_node_id}  ${des_link_num} ${des_pub_ip}  ${des_mesh_ip} >>${MESH_NETWORK_CONNECTED_LINKS_FILE}

        fi
    done

done

