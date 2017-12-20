#!/bin/sh
current_pwd="/zxyx/collect"
current_utils="/zxyx/utils/utils.sh"
. $current_utils
printf "###########################################################\n"
printf "#1        db2                                             #\n"
printf "#2        was                                             #\n"
printf "#3        mq                                              #\n"
printf "###########################################################\n"
printf "please choose one to do:\n"
read input_cse
printf "###########################################################\n"
user_list=`get_user_list` #get filter user
printf "%s\t%s\t%s\n" $user_list
printf "please select one user to do:\n"
read input_usr
user_exist=`cat /etc/passwd | grep -i $input_usr | wc -l`

if [ $user_exist -eq 0 ]
then
        printf "user not exists,exit!"
fi
if [ $input_cse -eq 1 ]
then 
		target_path='/tmp/zxyx/'`hostname`'_db2_'`date +"%y%m%d%H%M%S"`
        su - $input_usr -c "sh $current_pwd'/get_db2_log.sh' $input_usr $target_path"
elif [ $input_cse -eq 2 ]
then
		target_path='/tmp/zxyx/'`hostname`'_javacore_'`date +"%y%m%d%H%M%S"`
        su - $input_usr -c "sh $current_pwd'/get_javacore.sh' $target_path"
elif [ $input_cse -eq 3 ]
then
		target_path='/tmp/zxyx/'`hostname`'_mq_'`date +"%y%m%d%H%M%S"`
        su - $input_usr -c "sh $current_pwd'/mq/get_mq_log.sh' $target_path"
else
        printf "choose is not allow,exit!"
        exit 1
fi

