#!/bin/bash
#$1 - ID
PROBEID=$1
tail -n 1 "${PROBEID}" | cut -f 2 -d = | cut -f 2 -d /
