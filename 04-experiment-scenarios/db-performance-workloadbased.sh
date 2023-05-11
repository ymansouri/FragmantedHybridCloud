#!/bin/bash

. config

if [[ "$5" == "" ]]
then
  echo Usage: $0 "<DB_NAME>" "<DB_IPS>" "<WORKER_IP>" "<WORKLOAD>" "<RESULTS_FOLDER>"
  #experiment result folder id
  exit
fi

DB_NAME="$1"
#PRIVATENODES=1
#PUBLICNODES=0
DB_IPS="$2"
WORKER_IP="$3"
WORKLOAD="$4"
RESULTS_FOLDER="$5"
PRIVATENODES=${PRIVATE_NODES_NUMBER}
PUBLICNODES=${PUBLIC_NODES_NUMBER}


echo $DB_NAME
echo $DB_IPS
echo $WORKER_IP
echo $WORKLOAD
echo $RESULTS_FOLDER

echo Benchmark session at `date` started.


for REPEAT in `seq 1 1 1`
do
  echo running: ssh -o StrictHostKeyChecking=no ${VM_USERNAME}@${WORKER_IP} "cd ycsb-0.15.0 ; ./performance-scenario-max-workloadbased.sh ${DB_NAME} ${DB_IPS} ${WORKLOAD} ${PRIVATENODES}_${PUBLICNODES}_${REPEAT}"
  #ssh  -o StrictHostKeyChecking=no ${VM_USERNAME}@${MASTERIP} "tar xf ycsb.tar ; cd ycsb-0.15.0 ; ./performance-scenario-max-workloadbased.sh ${DB_NAME} ${DB_IPS} ${WORKLOAD} ${PRIVATENODES}_${PUBLICNODES}_${REPEAT}"
  ssh -o StrictHostKeyChecking=no ${VM_USERNAME}@${WORKER_IP} "rm -rf results/* ; cd ycsb-0.15.0 ; ./performance-scenario-max-workloadbased.sh ${DB_NAME} ${DB_IPS} ${WORKLOAD} ${PRIVATENODES}_${PUBLICNODES}_${REPEAT}"
  # Download YCSB results to controller node
  scp -o StrictHostKeyChecking=no ${VM_USERNAME}@${WORKER_IP}:/home/${VM_USERNAME}/results/* "${RESULTS_FOLDER}"
done

echo Benchmark session finished at `date`
