#!/bin/bash
# This  file is the same as probe-library except including  private key in order to access vms in hybrid cloud.
. config

#PROBES: ID->DESTINATION:PROBENAME
declare -A PROBES
declare -A PROBES_ARGS

start_probe ()
{
  # $1 - IP
  # $2 - PROBE_NAME
  # $3* - args
  ID=$(date +"%Y%m%d%H%M%S%N")
  IP=$1
  PROBE_NAME=$2
  PROBES[$ID]=${IP}:${PROBE_NAME}
  shift 2
  PROBES_ARGS[$ID]="$*"
  echo ./runscriptat.sh "${VM_USERNAME}@${IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "probes/start-${PROBE_NAME}.sh" "$ID $*" >> log
  ./runscriptat.sh "${VM_USERNAME}@${IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "probes/start-${PROBE_NAME}.sh" "$ID $*" &
}

stop_probes ()
{
  for PROBE in ${!PROBES[@]}
  do
    ID=$PROBE
    IP=${PROBES[$ID]%:*}
    NAME=${PROBES[$ID]#*:}
    ARGS=${PROBES_ARGS[$ID]}
    echo stop_probe $ID $IP $NAME $ARGS >> log
    stop_probe $ID $IP $NAME $ARGS
  done
}

scrape_probes ()
{
  # $1 - Where to save to
  DOWNLOAD_LOCATION="$1"
  for PROBE in ${!PROBES[@]}
  do
    ID=$PROBE
    IP=${PROBES[$ID]%:*}
    NAME=${PROBES[$ID]#*:}
    ARGS=${PROBES_ARGS[$ID]}
    echo scrape_probe $ID $IP $NAME $ARGS >> log
    scrape_probe "${DOWNLOAD_LOCATION}" $ID $IP $NAME $ARGS
  done
  clear_probes
}

clear_probes ()
{
  for PROBE in ${!PROBES[@]}
  do
    ID=$PROBE
    IP=${PROBES[$ID]%:*}
    NAME=${PROBES[$ID]#*:}
    ARGS=${PROBES_ARGS[$ID]}
    echo removing probe $ID $IP $NAME $ARGS >> log
    unset PROBES[${PROBE}]
    unset PROBES_ARGS[${PROBE}]
  done
  echo Number of elements left in probes array is: ${#PROBES[@]}
}

stop_probe ()
{
  #echo Stopping probe $3 on $2 ID=$1
  ID=$1
  IP=$2
  NAME=$3
  shift 3
  ./runscriptat.sh "${VM_USERNAME}@${IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "probes/stop-${NAME}.sh" "$ID $*"
}

scrape_probe ()
{
  DOWNLOAD_LOCATION=$1
  shift 1
  ID=$1
  IP=$2
  NAME=$3
  shift 3
  echo Result of probe $NAME on $IP ID=$ID
  echo Running: ./runscriptat.sh "${VM_USERNAME}@${IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "probes/scrape-${NAME}.sh" "$ID $*" \> "${DOWNLOAD_LOCATION}/${IP}-${NAME}-${ID}"
  ./runscriptat.sh "${VM_USERNAME}@${IP}:/home/${VM_USERNAME}" "${SSH_KEY_FILE}" "probes/scrape-${NAME}.sh" "$ID $*" > "${DOWNLOAD_LOCATION}/${IP}-${NAME}-${ID}"
}




