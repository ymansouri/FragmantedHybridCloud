#!/bin/bash

. config


#*****Removing all the rules applied previously*********
./04-remove-bandwidth-latency-matrix-rules.sh

#****Creating latency and bandwidth matrix for sparsely connected network**********
./05-creat-latencies-bandwidths-sparse-matrix.sh

#*****Apply and show  latency/bandwidth rules mentioned in above step***************

./06-apply-bandwidth-latency-sparse-matrix-rules-to-cluster.sh
./08-show-bandwidth-latency-sparse-matrix-rules.sh
