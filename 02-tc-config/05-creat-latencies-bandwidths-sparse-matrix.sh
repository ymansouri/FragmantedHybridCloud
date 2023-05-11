#!/bin/bash

##############################

# This code helps to create latency and bandwidth matrix based on number of links.

##############################

function get_links()
{
  #$1 - filename
  #$2 - SRC
  #$3 - DST
  sed "${2}q;d" ${1} | cut -d " " -f${3}
}



#$1: source index in latency matrix  $2: destination index in latency matrix
function get_default_latency () {
  sed "${1}q;d" ${LATENCY_FILE} | cut -f $2 -d","
}


#$1: source index in bandwidth matrix  $2: destination index bandwidth matrix
function get_default_bandwidth () {
 sed "${1}q;d" ${BANDWIDTH_FILE} | cut -f $2 -d","
}

. config

if [[ $# < 1 ]]
then
  echo "Usage: $0 <links_matrix.csv>"
  exit
fi

MESH_LINKS_NUMBER=${1}
#echo link_csv_file: ${LINKS_CSV_FILE}

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE_TCSET}
public_ip_arr=(${public_ip_arr})
VMS=$(echo ${public_ip_arr[@]} | wc -w)
echo "number of VMs:" $VMS



# Removes  latency and bandwidth file for mesh network
echo "CREATING LATENCY MATRIX FILE in ${PATH_PREFIX} FOR MESH NETWORK"
lat_file=$(echo ${ASYM_MESH_LATENCY_FILE} )
[[ -f ${lat_file} ]] && rm  ${lat_file}

echo "CREATING BANDWIDTH MATRIX FILE in ${PATH_PREFIX} FOR MESH NETWORK"
band_file=$(echo ${ASYM_MESH_BANDWIDTH_FILE} )
[[ -f ${band_file} ]] && rm  ${band_file}


#Creating a sparse matrix including  latency and bandwidth for mesh network based on the real latency and bandwidth across data centers (i.e., latency_def and bandwidth_def)
for VM_SRC in `seq 1 1 ${VMS}`
do
  LATENCY_ENTRY=""
  BANDWIDTH_ENTRY=""
  for VM_DST in `seq 1 1 ${VMS}`
  do
    LATENCIES=""
    BANDWIDTHS=""
    if [[ ${VM_SRC} == ${VM_DST} ]]
    then
      LATENCIES=${LATENCIES}"0"
      BANDWIDTHS=${BANDWIDTHS}"0"
      BANDWIDTH_TRACK=${BANDWIDTH_TRACK}"0"
    else

      NUMLINKS=$(get_links ${MESH_LINKS_NUMBER} ${VM_SRC} ${VM_DST}) #get_links-matrix(${VM_SRC},${VM_DST})
      for LINK in `seq 1 1 ${NUMLINKS}`
      do
           LATENCY_DEFAULT_VALUE=$(get_default_latency ${VM_SRC} ${VM_DST})
           if [[ ${LATENCY_DEFAULT_VALUE} -eq 0 ]]
           then
              LATENCY_DEFAULT_VALUE=$(get_default_latency ${VM_DST} ${VM_SRC}) 
            fi
           BANDWIDTH_DEFAULT_VALUE=$(get_default_bandwidth ${VM_SRC} ${VM_DST})


           if [[ ${LINK} -eq 1 ]]
           then 
                  if [[ ${VM_SRC} -lt ${VM_DST} ]]
                  then
                        LATENCIES=${LATENCIES}"   "${LATENCY_DEFAULT_VALUE}
                  else
                        LATENCIES=${LATENCIES}"   "0
                  fi
                  BANDWIDTHS=${BANDWIDTHS}"   "${BANDWIDTH_DEFAULT_VALUE}
                  BANDWIDTH_TRACK=${BANDWIDTH_TRACK}",${BANDWIDTH_DEFAULT_VALUE}"
           else
                  LATENCY_VALUE=$(( ( RANDOM % ${LATENCY_DEFAULT_VALUE} )  + ${MESH_NET_BASE_BANDLAT_VALUE} ))
                  if [[ ${VM_SRC} -lt ${VM_DST} ]]
                  then
                        LATENCIES=${LATENCIES}"   "${LATENCY_VALUE}
                        BANDWIDTH_VALUE=$(( ( RANDOM % ${BANDWIDTH_DEFAULT_VALUE} )  + ${MESH_NET_BASE_BANDLAT_VALUE} ))
                        BANDWIDTHS=${BANDWIDTHS}"   "${BANDWIDTH_VALUE}
                        BANDWIDTH_TRACK=${BANDWIDTH_TRACK}" "${BANDWIDTH_VALUE}
                  else
                        LATENCIES=${LATENCIES}"   "0
                        # Retrive the bandwidth value in position (row, col) when we want to assign bandwidth value to position of (col, row)
                        P=$(( ${VM_SRC}*${VM_DST} ))

                        ###################################
                        BANDWIDTH_VALUE=$(( ( RANDOM % ${BANDWIDTH_DEFAULT_VALUE} )  + ${MESH_NET_BASE_BANDLAT_VALUE} ))

                        BANDWIDTHS=${BANDWIDTHS}"   "${BANDWIDTH_VALUE}
                        BANDWIDTH_TRACK=${BANDWIDTH_TRACK}",${BANDWIDTH_VALUE}"
                  fi
          fi
      done
    fi
    LATENCY_ENTRY=${LATENCY_ENTRY}${LATENCIES}","
    BANDWIDTH_ENTRY=${BANDWIDTH_ENTRY}${BANDWIDTHS}","
  done

  echo ${LATENCY_ENTRY} | sed 's/,$//' >>${ASYM_MESH_LATENCY_FILE}

  echo ${BANDWIDTH_ENTRY}| sed 's/,$//'>>${ASYM_MESH_BANDWIDTH_FILE}
done

















