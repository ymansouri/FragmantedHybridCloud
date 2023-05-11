#!/bin/bash
#$1 - ID
PROBEID=$1
cat $1 | awk '{if ($1 in vals) {vals[$1] = $2-vals[$1]} else {vals[$1] = $2}} END {for (key in vals) {print key ": " vals[key]}}'
