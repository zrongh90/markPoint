#!/bin/bash
#1、光纤交换机日志收集
# 1)对光纤交换机进行配置，使用"supportFtp -s -h 10.8.251.5 -u tmpusr -p DRC1bank -d /tmp/sw_log/f6/ -l ftp"  命令
#   supportFtp -S查看配置信息
# 2）使用sshpass命令收集support信息，supportsave -nc
# -n:静默模式；-c：使用supportFtp配置好的参数
#2、光纤交换机错误清理
#  	通过slotstateclear和stateclear清理光纤交换机上的端口报错
#3、光纤交换机配置备份
#   通过configupload -all -p ftp 10.8.251.5,root,${tar_file_name},root1234
#

my_user="admin"
my_pass="password"
my_port="22"
my_cmd="supportsave -n -c"
f6_ip_list=("10.8.1.216" "10.8.1.202" "10.8.253.88" "10.8.252.30" "10.8.253.2" "10.8.254.83" "10.8.254.115")
f7_ip_list=("10.8.1.217" "10.8.1.205" "10.8.253.87" "10.8.252.40" "10.8.253.3" "10.8.254.84" "10.8.254.116")
f6_sps(){
	#ip_list=("10.8.1.216" "10.8.1.202" "10.8.253.88" "10.8.252.30" "10.8.253.2" "10.8.254.83" "10.8.254.115")
	for one_ip in ${f6_ip_list[*]};do
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd"  | sh
	done
}

f7_sps(){
	#ip_list=("10.8.1.217" "10.8.1.205" "10.8.253.87" "10.8.252.40" "10.8.253.3" "10.8.254.84" "10.8.254.116")
	for one_ip in ${f7_ip_list[*]};do
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd" | sh
	done
}


config_f6(){
	ip_list=("10.8.1.216:B5000" "10.8.1.202:B384" "10.8.253.88:D08_F48_8U" "10.8.252.30:D14_1_B80" "10.8.253.2:F6_F48" "10.8.254.83:DR_B80_E5" "10.8.254.115:D09_F48_6U")
	for one_ip in ${ip_list[*]};do
		ip_addr=$(echo ${one_ip} | cut -d':' -f1 )
		baseName=$(echo ${one_ip} | cut -d':' -f2 )
		my_cmd="supportFtp -s -h 10.8.251.5 -u tmpusr -p DRC1bank -d /tmp/sw_log/f6/"${baseName}" -l ftp"
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$ip_addr $my_cmd" | sh
	done
}

config_f7(){
	ip_list=("10.8.1.217:B5000" "10.8.1.205:B384" "10.8.253.87:D08_F48_6U" "10.8.252.40:D14_2_B80" "10.8.253.3:F7_F48" "10.8.254.84:DR_B80_E7" "10.8.254.116:D09_F48_8U")
	for one_ip in ${ip_list[*]};do
		ip_addr=$(echo ${one_ip} | cut -d':' -f1 )
		baseName=$(echo ${one_ip} | cut -d':' -f2 )
		my_cmd="supportFtp -s -h 10.8.251.5 -u tmpusr -p DRC1bank -d /tmp/sw_log/f7/"${baseName}" -l ftp"
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$ip_addr $my_cmd" | sh
	done
}


clear_f6(){
	#ip_list=("10.8.1.216" "10.8.1.202" "10.8.253.88" "10.8.252.30" "10.8.253.2" "10.8.254.83" "10.8.254.115")
	my_cmd1="slotstatsclear"
	my_cmd2="statsclear"
	for one_ip in ${f6_ip_list[*]};do
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd1" | sh
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd2" | sh
	done

}

clear_f7(){
	#ip_list=("10.8.1.217" "10.8.1.205" "10.8.253.87" "10.8.252.40" "10.8.253.3" "10.8.254.84" "10.8.254.116")
	my_cmd1="slotstatsclear"
	my_cmd2="statsclear"
	for one_ip in ${f7_ip_list[*]};do
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd1" | sh
		echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$one_ip $my_cmd2" | sh
	done
}

#光纤交换机配置备份命令configupload，针对每台机器进行操作
upload_file(){
	one_ip=$1
	cfg_save_path=$2
	ip_addr=$(echo ${one_ip} | cut -d':' -f1 )
        baseName=$(echo ${one_ip} | cut -d':' -f2 )
        tar_file_name=${cfg_save_path}"/"${baseName}".cnf"
        my_cmd="configupload -all -p ftp 10.8.251.5,root,${tar_file_name},root1234"
	echo "sshpass -p $my_pass ssh -o \"StrictHostKeyChecking=no\" -t -p$my_port $my_user@$ip_addr \"$my_cmd\"" | sh
}

backup_f6(){
	cfg_save_path=$1
	ip_list=("10.8.1.216:B5000" "10.8.1.202:B384" "10.8.253.88:D08_F48_8U" "10.8.252.30:D14_1_B80" "10.8.253.2:F6_F48" "10.8.254.83:DR_B80_E5" "10.8.254.115:D09_F48_6U")
	for one_ip in  ${ip_list[*]};do
		upload_file $one_ip $cfg_save_path
	done
}

backup_f7(){
	cfg_save_path=$1
	ip_list=("10.8.1.217:B5000" "10.8.1.205:B384" "10.8.253.87:D08_F48_6U" "10.8.252.40:D14_2_B80" "10.8.253.3:F7_F48" "10.8.254.84:DR_B80_E7" "10.8.254.116:D09_F48_8U")
	for one_ip in  ${ip_list[*]};do
		upload_file $one_ip $cfg_save_path
	done

}


support_main(){
	in_slide=$1
	if [ $in_slide = "f6" ];then
		f6_sps
	elif [ $in_slide = "f7" ];then
		f7_sps
	else
		printf "slide not correct,exit!"
		exit 1
	fi
}


clear_main(){
	in_slide=$1
	if [ $in_slide = "f6" ];then
		clear_f6
	elif [ $in_slide = "f7" ];then
		clear_f7
	else
		printf "slide not correct,exit!"
		exit 1
	fi
}

bak_main(){
	in_slide=$1
	#target machine's information
	current_date=$(date "+%Y%m%d")
	target_machine_ip="10.8.251.5"
	target_machine_user="root"
	target_machine_passwd="root1234"
	target_machine_port="22"
	#产生对应日期的目录yyyymmdd，同时根据F6和F7端进行区分
	if [ $in_slide = "f6" ];then
		target_folder_F6="/tmp/IBM/sanconfig/${current_date}/F6"
		echo "sshpass -p ${target_machine_passwd} ssh -o \"StrictHostKeyChecking=no\" -t -p${target_machine_port} ${target_machine_user}@${target_machine_ip} \"mkdir -p ${target_folder_F6}\"" | sh
		backup_f6 $target_folder_F6
	elif [ $in_slide = "f7" ];then
		target_folder_F7="/tmp/IBM/sanconfig/${current_date}/F7"
		echo "sshpass -p ${target_machine_passwd} ssh -o \"StrictHostKeyChecking=no\" -t -p${target_machine_port} ${target_machine_user}@${target_machine_ip} \"mkdir -p ${target_folder_F7}\"" | sh
		backup_f7 $target_folder_F7
	else
		printf "slide not correct,exit!"
		exit 1
	fi
}


tar_log_in_aix(){
#!/bin/ksh
#run in 10.8.251.5 to tar the switch's supportsave log and remove the origin file
option=$1
for i in 'f6' 'f7';do
        cd /tmp/sw_log/
        dir_list=$(ls -l ${i} | grep -i '^d' | awk '{print $NF}')
        for dir_name in ${dir_list};do
                cd /tmp/sw_log/${i}
                tar_fn=${dir_name}'.tar'
                if [ ! -e $tar_fn -o "$option" = "-f" ];then
                        echo "tar -cvf ${tar_fn} ${dir_name}'/'" | sh
                else
                        echo "tar file: $tar_fn exist, please clear or use -f to force"
                fi
        done
done
printf "clear source file. y or n?\n"
read clear_choice
if [ "$clear_choice" = "y" ];then
        find /tmp/sw_log -type f -name "*.gz" -exec rm -f '{}' \;
else
        printf "not clear source file!\n"
fi
}

if [ $# -ne 2 ];then
	printf "Usage: ./sw_ctrl.sh option slide\n"
	printf "option:\n"
	printf "   supportsave:   run supportsave in f6/f7 switch and put the result to 10.8.251.5\n"
	printf "   clear:         run the slotstatsclear and statsclear command to clear the switch's error count\n"
	printf "   cfgbak:        run the configupload command to backup the switch's configuration\n"
	printf "slide:\n"
	printf "   f6:            switch in f6 side\n"
	printf "   f7:            switch in f7 side\n"
	exit 1
fi
option=$1
slide=$2
if [ $option = "supportsave" ];then
	support_main $slide
elif [ $option = "clear" ];then
	clear_main $slide
elif [ $option = "cfgbak" ];then
	bak_main $slide
else
	printf "option err,exit!\n"
	exit 1
fi
