#!/bin/bash

#load data
. config
. probes-library-hybridcloud.sh

if [[ "$3" == "" ]]
then
  echo Usage: $0 "<DB_NAME>" "<WORKER_IP>" "<EXPERIMENT_LABEL>"
  exit
fi

DB_NAME="$1"
WORKER_IP="$2"
EXPERIMENT_LABEL="$3"


#echo IP: cat ( terraform-vms-deployment/consumer-private-ip )
# For whole  ips on opensatck and azure
DB_IPS=$(cat ${PRIVATE_IPS_FILE})
DB_IPS_WITH_COMMA=${DB_IPS// /,}

#b=$(echo ${a// /,})



echo DB name: ${DB_NAME}
echo Worker IP: ${WORKER_IP}
echo Results folder: ${EXPERIMENT_ID}

echo DB IPs: ${DB_IPS}
echo DB IPs WITH COMMA : ${DB_IPS_WITH_COMMA}



while read line
do
  echo line is $line
  WORKLOAD=`echo ${line} | cut -f 1 -d" "`
  OPS=`echo ${line} | cut -f 2 -d " "`
  echo Workload $WORKLOAD will have $OPS operations

  ./runscriptat.sh "${VM_USERNAME}@${WORKER_IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "set-ycsb-ops.sh" "/home/${VM_USERNAME}/ycsb-0.15.0/large.dat ${OPS}" </dev/null

  CURRENT_RESULT_FOLDER=all-results/${EXPERIMENT_LABEL}-${DB_NAME}-${WORKLOAD}-$(date +"%Y%m%d%H%M%S%N")
  mkdir -p "${CURRENT_RESULT_FOLDER}"
  echo "---- Running workload $WORKLOAD ----"
  tmux rename-window "Workload ${WORKLOAD}" </dev/null

  
  # For OpenStack nodes
  for IP in  ${DB_IPS}
  do
    echo "Setting probes for" $IP
    # Remote DB nodes probes
    start_probe $IP diskspace /dev/vda1 </dev/null
    start_probe $IP totaltraffic ens3 </dev/null
    echo "Setting detailednet probe for " $IP
    start_probe $IP detailednet ens3 ${DB_IPS} ${WORKER_IP} </dev/null
    # traffic
  done


  # Worker node probes

  #For worker 
  start_probe $WORKER_IP diskspace /dev/vda1 </dev/null
  # terrafic on wifi and wireguard
  start_probe $WORKER_IP totaltraffic ens3 </dev/null
  #start_probe $WORKER_IP totaltraffic eno2 </dev/null

  start_probe $WORKER_IP detailednet ens3 ${DB_IPS} </dev/null
  #start_probe $WORKER_IP detailednet wlp58s0 ${DB_IPS_WITH_SPACE} </dev/null
  #start_probe $WORKER_IP energyall </dev/null

  # OpenStack and Azure Broker: Note that these two nodes are  made hybrid cloud  (az well as shared  nodes on both clouds)
  #start_probe $PRIVATE_IP_BROKER_OPENSTACK totaltraffic wg1 </dev/null
  #start_probe $PRIVATE_IP_BROKER_OPENSTACK totaltraffic wg0 </dev/null
  #start_probe $PRIVATE_IP_BROKER_OPENSTACK totaltraffic ens4 </dev/null


  echo ./db-performance-workloadbased.sh "${DB_NAME}" "${DB_IPS}" "${WORKER_IP}" "${WORKLOAD}" "${CURRENT_RESULT_FOLDER}"
  ./db-performance-workloadbased.sh "${DB_NAME}" "${DB_IPS_WITH_COMMA}" "${WORKER_IP}" "${WORKLOAD}" "${CURRENT_RESULT_FOLDER}" </dev/null 
  #if [[ $WORKLAOD == 'c' ]]
  #then
  #   sleep 20m
  #fi

  echo stopping probes
  echo stopping probes >>log
  stop_probes </dev/null

  echo scraping probes
  echo scraping probes >>log
  scrape_probes "${CURRENT_RESULT_FOLDER}" </dev/null

  echo Proceeding to next workload
done < "workloads.ops.l"


