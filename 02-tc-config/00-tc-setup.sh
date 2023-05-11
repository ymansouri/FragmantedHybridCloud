#!/bin/bash

. config

./01-tcset-installation.sh

# APPLY TC RULES ON ens3 (a network with one link connection)
./02-apply-bandwidth-latency-matrix.sh
./03-show-bandwidth-latency-matrix-rules.sh


