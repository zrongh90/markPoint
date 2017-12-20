#/bin/sh
. /zxyx/utils/filter_user.sh
. /zxyx/utils/rm_inner_file.sh
input_user_name(){
	user_list=$(get_user_list)
	printf "%s\t%s\t%s\n" $user_list
	printf "please select user to do:\n"
	read input_usr
	user_exist=$(cat /etc/passwd | grep -i $input_usr | wc -l)
	if [ $user_exist -eq 0 ]
	then
		printf "user not exists,exit!"
	fi
	echo ${input_usr}
}

tar_log(){
        printf "###########start to tar and gzip log#################"
        tar_path=$1
        in_tar_folder=`basename $tar_path`
        in_tar_path=`dirname $tar_path`
        tar_name=$in_tar_folder".tar"
        cd $in_tar_path && tar -cvf $tar_name $in_tar_folder
        if [ -e $tar_name ]
        then
                gzip $tar_name
        else
                printf "%s" "the file $tar_name is not exist!"
                exit 1
        fi
}

