#!/bin/bash

. config


#*****Removing all the rules applied previously*********
./04-remove-bandwidth-latency-matrix-rules.sh

#****Creating latency and bandwidth matrix for sparsely connected network**********
#./05-creat-latencies-bandwidths-sparse-matrix.sh

#*****Apply and show  latency/bandwidth rules mentioned in above step***************

./02-apply-bandwidth-latency-matrix.sh
./07-remove-bandwidth-latency-sparse-matrix-rules-from-cluster.sh
./06-apply-bandwidth-latency-sparse-matrix-rules-to-cluster.sh
./08-show-bandwidth-latency-sparse-matrix-rules.sh
