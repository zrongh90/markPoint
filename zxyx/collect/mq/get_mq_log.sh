#!/bin/ksh
current_utils="/zxyx/utils/utils.sh"
. $current_utils

curr_pwd="/zxyx/collect/mq"
target_folder='mq_log'`date +"%y%m%d%H%M%S"`
target_path='/tmp/zxyx/'$target_folder
mq_err_path=$target_path"/errors"
mq_mgr_err_path=$target_path"/mgr_errors"
hostname=`hostname`
mq_list=`dspmq | awk -F'[()]' '{print $2}'`
one_mgr=""

mkfld(){
	input_path=$1
	if [ ! -e $input_path ]
	then
		mkdir -p $input_path
	else
		echo "$input_path is exists!"
	fi
}

cp_log(){
	sour_path_in=$1
	target_path_in=$2
	regex=$3
	cd $sour_path_in
	if [ $? == 0 ]
	then
		for log_name in `ls $regex`
		do
			echo "cp $log_name from $sour_path_in to $target_path_in"
			cp $log_name $target_path_in
		done
	else
		echo "$sour_path_in not exist!"
	fi
}

get_log(){
	mgr_name=$1
	dspmqver > $target_path"/dspmqver.out"
	cp_log "/var/mqm/errors" "${mq_err_path}" "AMQERR*.LOG" 
	mq_data_path=`/usr/mqm/bin/dspmqinf $mgr_name | grep -i "DataPath" | awk -F'=' '{print $2}'`
        if [ $mq_data_path ]
        then
                cp_log "${mq_data_path}/errors" "${mq_mgr_err_path}" "AMQERR*.LOG"
        else
                cp_log "/var/mqm/qmgrs/${1}/errors" "${mq_mgr_err_path}" "AMQERR*.LOG"
        fi
}

tarLog(){
	tar_name=$target_folder".tar"
	cd `dirname $target_path` && tar -cvf $tar_name $target_folder 
	if [ -e $tar_name ]
	then
		gzip $tar_name
	else
		printf "%s" "the file $tar_name is not exist!"
		exit 1
	fi
}

echo "the mgr ( ${mq_list} ) , please select one to collect log:"
read one_mgr
mkfld $target_path
mkfld $mq_err_path
mkfld $mq_mgr_err_path
get_log $one_mgr
runmqsc $one_mgr < $curr_pwd"/getqmgrcfg" > $target_path"/getqmgrcfg.out"
runmqsc $one_mgr < $curr_pwd"/getqmgrstats" > $target_path"/getqmgrstats.out"
tar_log $target_path
