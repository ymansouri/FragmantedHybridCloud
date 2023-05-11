#!/bin/bash
#Negative results indicate less disk space available
#$1 - ID
#$2 - device to check
PROBEID=$1
VALBEFORE=$(head -n 1 ${PROBEID})
VALAFTER=$(tail -n 1 ${PROBEID})
echo $(( $VALAFTER - $VALBEFORE )) wh
