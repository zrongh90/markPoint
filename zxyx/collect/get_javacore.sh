#!/bin/ksh
#author huangzr 20170412
current_utils="/zxyx/utils/utils.sh"
. $current_utils
target_path='/tmp/zxyx/'`hostname`'_javacore_'`date +"%y%m%d%H%M%S"`

mkdir -p $target_path
chmod a+rwx $target_path
if [ -e $target_path ]
then
#        sys_pl=$(echo $(uname) | tr '[A-Z]' '[a-z]')
#        if [ $sys_pl = "linux" ]
#        then
#                #for linux platform, trap signal to clear folder
                trap "rm -rf ${target_path};exit 1" 0 1 2 3 13 15 
#        fi
else
        exit 1
fi




prf_path=`ps -ef | grep java | grep -v grep | awk '/-Duser.install.root=/' | awk -F"-Duser.install.root=" '{print $2}'  | cut -d' ' -f1 | sort | uniq`
prf_list=""
for prf in $prf_path
do
	if [ -d "${prf}/servers" ]
	then
		prf_list=${prf_list}'|'`ls ${prf}/servers`
	fi
done
if [ -z "${prf_list}" ]
then
	echo "other way to get server"
	#other way to find server name
	prf_list=`ps -ef | grep java | grep -v grep | awk '/-Duser.install.root=/' | awk -F"-Duser.install.root=" '{print $2}' | awk '{print $NF}'`
else
	:  #ls can find the server name
fi

echo "the profile in running is (${prf_list}), please choose one to collect javacore:"
read server_name

profile_path=`ps -ef | grep ${server_name} | grep -v grep | awk '/-Duser.install.root=/' | awk -F"-Duser.install.root=" '{print $2}'  | cut -d' ' -f1 | sort | uniq`
if [ 0 -eq ${#profile_path} ]
then
	echo "server ${server_name} is not exists"
	exit 1
else
	:
fi
#profile_path=`dirname $profile_config_path`


mv_heap_and_javacore(){
	i_file_list=$2
	i_file_path=$1
	i_target_path=$3'/'
	for i_filename in $i_file_list
        do
                i_file=${i_file_path}'/'${i_filename}
                if [ -e $i_file ]
                then
                        echo "mv $i_file $i_target_path"
                        mv $i_file $i_target_path
                fi
        done
}

get_new_javacore_heapdump(){
	echo "wsadmin_user:"
	read wsadmin_user
	echo "wsadmin_passwd:"
	read wsadmin_passwd
	collect_count=0
	while [ $collect_count -lt 3 ]
	do
		${profile_path}/bin/wsadmin.sh -user $wsadmin_user -password $wsadmin_passwd -c 'set objectName [$AdminControl queryNames WebSphere:type=JVM,process='${server_name}',*];$AdminControl invoke $objectName generateHeapDump'  
		${profile_path}/bin/wsadmin.sh -user $wsadmin_user -password $wsadmin_passwd -c 'set jvm [$AdminControl completeObjectName type=JVM,process='${server_name}',*];$AdminControl invoke $jvm dumpThreads'
		collect_count=$((collect_count + 1))	
	done

	#find javacore and heapdump in two path: profile_path or /headump directory
	h_j_path=${profile_path}
	p_heapdump_file_list=$(find ${h_j_path} -type f -name "heapdump*" -mtime -2 -exec basename '{}' \;)
	p_javacore_file_list=$(find ${h_j_path} -type f -name "javacore*" -mtime -2 -exec basename '{}' \;)
	
	h_path="/heapdump"
	if [ -e $h_path ]
	then
		h_heapdump_file_list=$(find "${h_path}" -type f -name "heapdump*" -mtime -2 -exec basename '{}' \;)
		h_javacore_file_list=$(find "${h_path}" -type f -name "javacore*" -mtime -2 -exec basename '{}' \;)
	fi

	#call mv action ,remember use "" to avoid space
	mv_heap_and_javacore $h_j_path "$p_heapdump_file_list" $target_path
	mv_heap_and_javacore $h_j_path "$p_javacore_file_list" $target_path
	mv_heap_and_javacore $h_path "$h_heapdump_file_list" $target_path
	mv_heap_and_javacore $h_path "$h_javacore_file_list" $target_path
}

get_new_javacore_heapdump

profile_counts=`echo $prf_list | wc -w`
if [ $profile_counts -gt 1 ]
then
	find_path=${profile_path}'/logs/'${server_name}
else
	find_path=${profile_path}'/logs'
fi

for file_name in `find $find_path -name "*.log" -type f -mtime -2 -print | awk '/SystemOut|SystemErr|native_stderr|native_stdout/'`
do 
	echo "cp $file_name $target_path"
	cp $file_name $target_path
done


tar_log $target_path
