#!/bin/bash
cd /home/tmpusr/ansible-aix-playbooks/nas_look && ./startup.sh
cd /home/tmpusr/ansible-playbooks/nas_look && ./startup.sh
python /home/tmpusr/drcbank/merge_xls.py "/tmp/nas_look_aix.xls" "/tmp/nas_look_linux.xls" "/tmp/nas_look_all.xls"
curr_date=`date +"%Y%m%d%H%M"`
target_file="/home/tmpusr/result/nas_look/nas_look_all_"$curr_date".xls"
if [ -e "/tmp/nas_look_aix.xls" ]
then
	rm /tmp/nas_look_aix.xls
fi
if [ -e "/tmp/nas_look_linux.xls" ]
then
	rm /tmp/nas_look_linux.xls
fi
if [ -e "/tmp/nas_look_all.xls" ]
then
	mv "/tmp/nas_look_all.xls" $target_file
fi
