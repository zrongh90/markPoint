#!/bin/sh
mkdir -p /tmp/zxyx/nmon
/usr/bin/nmon -s 60 -c 1440 -t -F /tmp/zxyx/nmon/nmon_`hostname`_`date +"%y%m%d"`.nmon 
find /tmp/zxyx/nmon -name "nmon*.nmon" -type f -mtime +10 -exec rm '{}' \;

