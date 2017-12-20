#!/bin/bash
current_utils="/zxyx/utils/utils.sh"
. $current_utils
#use get_user_list to cover follow code
#user_list=`cat /etc/passwd | cut -d':' -f1`
#for user in `cat /zxyx/filter_user_list`
#do
#        user_list=`echo $user_list | tr ' ' '\n' | awk -v awk_filter="$user" '{if($0 !~ awk_filter) print $0}'`
#done
user_list=$(get_user_list)
printf "%s\t%s\t%s\n" $user_list
printf "please select user to grant select privilege(like dbqry):\n"
read selectUserName
db_name=`db2 list db directory | grep -i "Database alias" | awk '{print $NF}'`
printf "the database are ( %s ),please select one or input one:\n" "${db_name}"
read dbName
db2 connect to $dbName
db2 list tables for all | awk '{print $2}' | grep -v '^[ ]*$' | awk '!/record|---|Schema|SYSCAT|SYSIBM|SYSIBMADM|SYSPUBLIC|SYSSTAT|SYSTOOLS/' | sort | uniq > /tmp/table_owner_list.log
printf "the database owner are ( %s ),please select one or input one(like dbusr):\n" `cat /tmp/table_owner_list.log`
read tableOwnerName
#赋予连接权限给selectUserName用户
db2 grant connect on database to user $selectUserName
db2 connect reset
#获取实例用户下的表列表
db2 connect to $dbName
#db2 "select TABSCHEMA,tabname from syscat.tables" | grep -i $db2InstanceName >grantAll.log 
db2 "select TABSCHEMA,tabname from syscat.tables" | grep -i $tableOwnerName > /tmp/grantAll.log 
db2 connect reset
#针对实例用户下的所有表，单独对每个表进行select赋权
cat /tmp/grantAll.log|while read schema tabname
do
	db2 connect to $dbName
	db2 grant select on table $schema.$tabname to user $selectUserName
	db2 connect reset 
done 
rm -f /tmp/grantAll.log
rm -f /tmp/table_owner_list.log
