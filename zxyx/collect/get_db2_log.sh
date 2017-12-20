#!/bin/sh
LANG=en_US
inst_user=$1
target_path=$2
input_db_name=$3
if [ -z $target_path ];then
	target_path='/tmp/zxyx/'`hostname`'_db2_'`date +"%y%m%d%H%M%S"`
	#trap "rm -rf $target_path;exit 0" 0 1 2 3 13 15
fi
current_pwd="/zxyx/collect"
current_utils="/zxyx/utils/utils.sh"
. $current_utils

mkfld(){
	input_path=$1
	if [ ! -e $input_path ]
	then
		mkdir -p $input_path
	else
		echo "$input_path is exists!"
	fi
}
mkfld $target_path

user_home=`cat /etc/passwd | grep -i $inst_user | awk -F':' '{print $(NF-1)}'`
if [ $user_home ]
then
	diag_path=$user_home"/sqllib/db2dump/db2diag.log"
	if [ -f $diag_path ]
	then
		tail -200000 $diag_path > $target_path"/db2diag.log."`date +"%y%m%d"` 
	else
		printf "%s is not exist!\n" $diag_path
		exit 1
	fi
	if [ -z ${input_db_name} ];then
		db_name=`db2 list db directory | grep -i "Database alias" | awk '{print $NF}'`
		printf "the database are ( %s ),please select one or input one:\n" "${db_name}"
		read input_db_name
	fi
	is_db_exist=$(db2 list db directory | grep -i "Database alias" | grep -v grep | grep -w ${input_db_name})
	if [[ $? != 0 ]];then
		printf "Database named %s is not existed! EXIT!\n" ${input_db_name}
		exit 1
	fi
	printf "Start to collect DB2 snapshot and db2pd -everything\n"
	iternate=0
        while [ $iternate -lt 3 ]
        do
                printf "\n--------------collect the $iternate time snapshot and pd--------------\n"
		db2 connect to $input_db_name > /dev/null
		db2 get snapshot for all on $input_db_name > $target_path"/snapshot.log."`date +"%H%M%S"`
		db2pd -everything -o $target_path"/pdeverything.log."`date +"%H%M%S"`
		iternate=`expr $iternate + 1`
		sleep 5
	done
else
	printf "%s 's home is not exist!please check the /etc/passwd for %s!\n" $inst_user $inst_user
	exit 1
fi

printf "\n"
tar_log $target_path
tar_filename=$target_path".tar.gz"
printf "#####################################\n"
if [[ -e $tar_filename ]];then
	printf "collect db2pd and db2 snapshot success!\n"
fi
