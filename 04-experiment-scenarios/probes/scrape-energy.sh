#!/bin/bash
#$1 - ID
PROBEID=$1
VALBEFORE=$(head -n 1 ${PROBEID} | cut -f 2 -d " ")
VALAFTER=$(tail -n 1 ${PROBEID} | cut -f 2 -d " ")
echo $(( $VALAFTER - $VALBEFORE )) uJ
