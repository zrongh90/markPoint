#!/bin/bash
python /home/tmpusr/drcbank/gen_ansible_hosts/ansible_host_retrieve.py
cur_date=$(date +"%Y-%m-%d")
result_path="/home/tmpusr/result/ansible_hosts/"
aix_result=${result_path}"result_aix_file"
rhel_result=${result_path}"result_rhel_file"
if [ -e $aix_result -a $(stat $aix_result | grep "Modify" | awk '{print $2}') = $cur_date ];then
	target_path="/home/tmpusr/ansible-aix-playbooks"
	echo "cp ${target_path}/hosts ${target_path}/hosts.${cur_date}"
	echo "cp $aix_result ${target_path}/hosts"
fi
if [ -e $rhel_result -a $(stat $rhel_result | grep "Modify" | awk '{print $2}') = $cur_date  ];then
	target_path="/etc/ansible"
	echo "sudo cp ${target_path}/hosts ${target_path}/hosts.${cur_date}"
	echo "sudo cp $rhel_result ${target_path}/hosts"
fi
