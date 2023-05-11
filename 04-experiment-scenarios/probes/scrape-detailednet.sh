#!/bin/bash
#$1 - ID
#$2 - network interface
#$3 - Space-separated IP list

cat >iftopsummary.awk <<AWK1
BEGIN { print "IP TX RX" }
/=>/ { txtmp=\$7 }
/<=/ { tx[\$1]=txtmp; rx[\$1]=\$6}
END { for (key in tx) {print key, tx[key], rx[key]} }
AWK1

echo scraping ${1} >>log
cat ${1} | awk -f iftopsummary.awk
