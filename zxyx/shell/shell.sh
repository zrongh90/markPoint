#!/bin/sh
current_pwd="/zxyx/shell"
current_utils="/zxyx/utils/utils.sh"
. $current_utils
printf "###########################################################\n"
printf "#1        grantSelect                                     #\n"
printf "#2        swapMon                                         #\n"
printf "###########################################################\n"
printf "please choose to do:\n"
read input_cse
printf "###########################################################\n"
if [ $input_cse -eq 1 ]
then
	user_list=$(get_user_list)
    printf "%s\t%s\t%s\n" $user_list
    printf "please select user to do:\n"
    read input_usr
    user_exist=$(cat /etc/passwd | grep -i $input_usr | wc -l)
    if [ $user_exist -eq 0 ]
    then
            printf "user not exists,exit!"
    fi
    su - $input_usr -c "sh $current_pwd'/grantSelect.sh'"
elif [ $input_cse -eq 2 ]
then
	${current_pwd}"/swap_show.sh"
else
        printf "choose is not allow,exit!"
        exit 1
fi



