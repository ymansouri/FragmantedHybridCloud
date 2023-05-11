#!/bin/bash

declare -a latency_matrix
declare -a bandwidth_matrix

function get_links()
{
  #$1 - filename
  #$2 - SRC
  #$3 - DST
  sed "${2}q;d" ${1} | cut -d"," -f${3}
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

LINKS_CSV_FILE=${1}
#echo link_csv_file: ${LINKS_CSV_FILE}

IFS=,$'\n' read -d '' -r -a public_ip_arr < ${PUBLIC_IPS_FILE}
public_ip_arr=(${public_ip_arr})
VMS=$(echo ${public_ip_arr[@]} | wc -w)


# Removes  latency and bandwidth file for mesh network

lat_file=$(echo ${PATH_PREFIX}/asym_mesh_latency.csv )
[[ -f ${lat_file} ]] && rm  ${lat_file}

band_file=$(echo ${PATH_PREFIX}/asym_mesh_bandwidth.csv )
[[ -f ${band_file} ]] && rm  ${band_file}

function print_matrix () {

   echo $1
   echo $2  
   echo "${latency_matrix[$1,$2]}"
}


for VM_SRC in `seq 1 1 ${VMS}`
do
  for VM_DST in `seq 1 1 ${VMS}`
  do
      echo INDEX: ${VM_SRC} "," ${VM_DST}
      LATENCIES=""
      #BANDWIDTHS=""
    if [[ ${VM_SRC} == ${VM_DST} ]]
    then
      latency_matrix[${VM_SRC},${VM_DST}]=0
      echo ${VM_SRC} ${VM_DST}  ${latency_matrix[${VM_SRC},${VM_DST}]}
      #bandwidth_matrix[${VM_SRC},${VM_DST}]=0
      #echo ${VM_SRC} ${VM_DST}  ${latency_matrix[${VM_SRC},${VM_DST}]}
      #print_matrix
     else
          NUMLINKS=$(get_links ${LINKS_CSV_FILE} ${VM_SRC} ${VM_DST}) #get_links-matrix(${VM_SRC},${VM_DST})
          for LINK in `seq 1 1 ${NUMLINKS}`
          do
             echo NUMLINKS: ${NUMLINKS}

              LATENCY_DEFAULT_VALUE=$(get_default_latency ${VM_SRC} ${VM_DST})
              #BANDWIDTH_DEFAULT_VALUE=$(get_default_bandwidth ${VM_SRC} ${VM_DST})
              if [[ ${LINK} -eq 1 ]]
              then
                    LATENCIES=${LATENCIES}"   "${LATENCY_DEFAULT_VALUE}
                    #BANDWIDTHS=${BANDWIDTHS}"   "${BANDWIDTH_DEFAULT_VALUE}

             else
                    LATENCY_VALUE=$(( ( RANDOM % ${LATENCY_DEFAULT_VALUE} )  + ${MESH_NET_BASE_BANDLAT_VALUE} ))
                    LATENCIES=${LATENCIES}"   "${LATENCY_VALUE}
                    #BANDWIDTH_VALUE=$(( ( RANDOM % ${BANDWIDTH_DEFAULT_VALUE} )  + ${MESH_NET_BASE_BANDLAT_VALUE} ))
                    #BANDWIDTHS=${BANDWIDTHS}"   "${BANDWIDTH_VALUE}
              fi

          done
         latency_matrix[${VM_SRC},${VM_DST}]=${LATENCIES}
         echo ${VM_SRC} ${VM_DST}  ${latency_matrix[${VM_SRC},${VM_DST}]}
    fi
   done
done 



#for VM_SRC in `seq 1 1 ${VMS}`
#do
#  LINE=""
#  for VM_DST in `seq 1 1 ${VMS}`
#  do
    #LINE=${LINE}","
#     echo $(latency_matrix[${VM_SRC},${VM_DST}])
#  done
#  echo $
#done


exit






for VM_SRC in `seq 1 1 ${VMS}`
do
  LINE=""
  for VM_DST in `seq 1 1 ${VMS}`
  do
    if [[ ${VM_SRC} == ${VM_DST} ]]
    then
      LINE=${LINE}"0"
    else
      NUMLINKS=$(get_links ${LINKS_CSV_FILE} ${VM_SRC} ${VM_DST}) #get_links-matrix(${VM_SRC},${VM_DST})
      for LINK in `seq 1 1 ${NUMLINKS}`
      do
        LINE=${LINE}" "${matrix[${VM_SRC},${VM_DST},${LINK}]}
      done
    fi
    LINE=${LINE}","
  done
  LINE=$(echo ${LINE} | sed "s/, /,/g")
  LINE=$(echo ${LINE} | sed "s/,$//")
  echo ${LINE}
done
