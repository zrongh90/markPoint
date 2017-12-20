#!/bin/bash
cd /home/tmpusr/ansible-aix-playbooks/ntp_look && ./startup.sh
cd /home/tmpusr/ansible-playbooks/ntp_look && ./startup.sh
python /home/tmpusr/drcbank/merge_xls.py "/tmp/ntp_look_aix.xls" "/tmp/ntp_look_linux.xls" "/tmp/ntp_look_all.xls"
curr_date=`date +"%Y%m%d%H%M"`
target_file="/home/tmpusr/result/ntp_look/ntp_look_all_"$curr_date".xls"
if [ -e "/tmp/ntp_look_aix.xls" ]
then
	rm /tmp/ntp_look_aix.xls
fi
if [ -e "/tmp/ntp_look_linux.xls" ]
then
	rm /tmp/ntp_look_linux.xls
fi
if [ -e "/tmp/ntp_look_all.xls" ]
then
	mv "/tmp/ntp_look_all.xls" $target_file
fi
