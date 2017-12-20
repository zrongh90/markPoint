#!/bin/ksh
getVal(){
        out_val=`echo $1 | cut -d',' -f$2`
        echo $out_val
}

initFs(){
        fs_list=`grep -i '^fs_info' $cfg_file_path | cut -d'=' -f2`
        count=`echo ${fs_list} | grep -c ";"`
        count=`expr $count + 1`
        iternate=1
        while [ $iternate -le $count ]
        do
                #one_fs=`echo $fs_list | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
                one_fs=`echo $fs_list | cut -d';' -f$iternate | awk -F"[()]" '{print $2}'`
                fs_owner=`getVal $one_fs 1`
                fs_path=`getVal $one_fs 2` 
                lv_name=`getVal $one_fs 3` 
                vg_name=`getVal $one_fs 4` 
                lp_num=`getVal $one_fs 5` 
                echo "/usr/sbin/mklv -y'$lv_name' -t'jfs2' $vg_name $lp_num" | sh
                echo "mkdir $fs_path" | sh
                echo "/usr/sbin/crfs -v jfs2 -d'$lv_name' -m'$fs_path' -A'yes' -p'rw' -a agblksize='4096' -a isnapshot='no'" | sh
                echo "mount $fs_path" | sh
                id $fs_owner 
                if [ $? -eq 0 ]  
                then
                        fs_owner_grp=`id $fs_owner | awk -F' ' '{print $2}' | awk -F"[()]" '{print $2}'`
                        echo "chown -R ${fs_owner}:${fs_owner_grp} $fs_path" | sh
                else
                        echo "$fs_owner not exist!" 
                fi
                        
                iternate=`expr $iternate + 1`
        done
}

rmFs(){
        fs_list=`grep -i '^fs_info' $cfg_file_path | cut -d'=' -f2`
        count=`echo ${fs_list} | grep -c ";"`
        count=`expr $count + 1`
        iternate=$count
        while [ $iternate -ge 1 ]
        do
                one_fs=`echo $fs_list | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
                fs_path=`getVal $one_fs 2` 
                lv_name=`getVal $one_fs 3` 
                vg_name=`getVal $one_fs 4` 
                lsfs $fs_path
                if [ $? -eq 0 ]
                then
                        echo "umount $fs_path" | sh
                        echo "/usr/sbin/rmfs -r'' $fs_path" | sh
                fi              
                lslv $lv_name
                if [ $? -eq 0 ]
                then
                        echo "/usr/sbin/rmlv -f '$lv_name'" | sh
                fi
                iternate=`expr $iternate - 1`
        done
}

addUser(){
        user_list=`grep -i '^user_info' $cfg_file_path | cut -d'=' -f2`
        count=`echo ${user_list} | grep -c ";"`
        count=`expr $count + 1`
        iternate=1
        while [ $iternate -le $count ]
        do
                one_user=`echo $user_list | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`      
                user_name=`getVal $one_user 1`
                user_id=`getVal $one_user 2`
                id_exist=`cat /etc/passwd | grep -i $user_id | wc -l`
                if [ $id_exist -gt 0 ]
                then
                        echo "id $user_id exist,please input a new id:"
                        sleep 1
                        read -s user_id
                fi
                user_grp=`getVal $one_user 3`
                if [ $user_grp ]
                then
                        :       
                else
                        user_grp="staff"
                fi
                echo "mkuser id='$user_id' admin='false' pgrp='$user_grp' $user_name"  | sh
                iternate=`expr $iternate + 1`
        done
}

delUser(){
        user_list=`grep -i '^user_info' $cfg_file_path | cut -d'=' -f2`
        count=`echo ${user_list} | grep -c ";"`
        count=`expr $count + 1`
        iternate=1
        while [ $iternate -le $count ]
        do
                one_user=`echo $user_list | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
                user_name=`getVal $one_user 1`
                id $user_name
                if [ $? -eq 0 ]
                then
                        echo "userdel $user_name" | sh
                else
                        echo "user $user_name not exist!"
                fi
                iternate=`expr $iternate + 1`
        done

}

initDb2(){
        user_list=`grep -i '^db_info' $cfg_file_path | cut -d'=' -f2`
        count=`expr $(echo ${user_list} | grep -c ";") + 1`
        iternate=1
        while [ $iternate -le $count ]
        do
                one_user=`echo $user_list | cut -d';' -f$iternate | awk -F"[()]" '{print $2}'`
                user_name=`getVal $one_user 1`
                db2_version=`getVal $one_user 2`
                id $user_name && cd /opt/IBM/db2/${db2_version}/instance/ 2>/dev/null &&  echo "/opt/IBM/db2/${db2_version}/instance/db2icrt -u db2fenc $user_name" | sh
                iternate=`expr $iternate + 1`
        done
}

dropDb2(){
        user_list=`grep -i '^db_info' $cfg_file_path | cut -d'=' -f2`
        count=`expr $(echo ${user_list} | grep -c ";") + 1`
        iternate=1
        while [ $iternate -le $count ]
        do
                one_user=`echo $user_list | cut -d';' -f$iternate | awk -F"[()]" '{print $2}'`
                user_name=`getVal $one_user 1`
                db2_version=`getVal $one_user 2`
                id $user_name && cd /opt/IBM/db2/${db2_version}/instance/ 2>/dev/null &&  echo "/opt/IBM/db2/${db2_version}/instance/db2idrop $user_name" | sh
                iternate=`expr $iternate + 1`
        done
}


cfg_file_path="/zxyx/db2Recover/initDb2.cfg"
type=`grep -i '^type_info' $cfg_file_path | cut -d'=' -f2`
if [ $type == "create" ]
then
        addUser
        initFs
        initDb2
elif [ $type == "delete" ]
then
        dropDb2
        delUser
        rmFs
else
        echo "choose type error"
fi