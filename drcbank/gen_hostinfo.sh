#!/bin/bash
cd /home/tmpusr/ansible-playbooks/hostInfo && ./startup.sh
curr_date=`date +"%m%d%H%M"`
target_file="/home/tmpusr/result/hostInfo/hostInfo_"$curr_date".xls"
if [ -e "/tmp/hostinfo.xls" ]
then
	mv "/tmp/hostinfo.xls" $target_file
fi
