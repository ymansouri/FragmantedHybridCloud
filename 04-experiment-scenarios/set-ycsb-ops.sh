#!/bin/bash
# $1 - ycsb large.dat location
# $2 - number of operations to set
sed -i "s/operationcount=.*/operationcount=${2}/" ${1}
