#!/bin/sh
get_user_list(){
	user_list=`cat /etc/passwd | cut -d':' -f1`
	for user in `cat /zxyx/utils/filter_user_list`
	do
	        user_list=`echo $user_list | tr ' ' '\n' | awk -v awk_filter="$user" '{if($0 != awk_filter) print $0}'`
	done
	echo $user_list
}
