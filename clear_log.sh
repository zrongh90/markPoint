linux
#!/bin/bash
find /db2log/tsmpinst/TSMPDB/NODE0000/C0000000/ -name 'S*.LOG' -mtime +10 -exec gzip "{}" \;
find /db2log/tsmcinst/TSMCDB/NODE0000/C0000000/ -name 'S*.LOG' -mtime +10 -exec gzip "{}" \;
find /db2log/tsmpinst/TSMPDB/NODE0000/C0000000/ -name 'S*.LOG.gz' -mtime +90 -exec rm -f "{}" \;
find /db2log/tsmcinst/TSMCDB/NODE0000/C0000000/ -name 'S*.LOG.gz' -mtime +90 -exec rm -f "{}" \;

unix

find /db2log/db2Archive/cdfsinst/CDFSDB/NODE0000/C0000000 -type f -name 'S*.LOG' -mtime +3 -print -exec gzip {} \;

find /db2log/db2Archive/db2bwp/BWP/NODE0000/C0000000/ -type f -name 'S*.LOG' -mtime +3 -print -exec gzip {} \;

find /db2log/db2Archive/ftpinst/FTPDB/NODE0000/C0000000/ -type f -name 'S*.LOG' -mtime +3 -print -exec gzip {} \;


find /db2log -type f -name "S*.LOG" -mtime +0 -print 


find /dwsoft/ibpsusr/ComForLib/log/201603 -type f -name '*.log.*' -print -exec gzip {} \;


find  /dwsoft/ibpsusr/ComForLib/log/. -type f -name '20*.log*' -mtime +10 -print -exec gzip {} \;


find  /home/epayusr/log/batch -type f -name '*.log*' -mtime +30 -print -exec gzip {} \;


find /db2log/db2bvp/BVP/NODE0000/LOGSTREAM0000/C0000000 -name 'S*.LOG' -mtime +0 -exec rm -f "{}" \;

0 6 * * *   sh /sasSrvLog/mv2nas.sh /home/sas/log /sasSrvLog 60 > /sasSrvLog/mv2nas.log136 2>/sasSrvLog/mv2nas.error136

0 6 * * *  sh /sasSrvLog/mv2nas.sh /home/sas/log /sasSrvLog 60 > /sasSrvLog/mv2nas.log146 2>/sasSrvLog/mv2nas.error146

0 6 * * *  sh /sasSrvLog/mv2nas.sh /home/sas/log /sasSrvLog 60 > /sasSrvLog/mv2nas.log136 2>/sasSrvLog/mv2nas.error136
0 7 * * * sh /sasSrvLog/change_folder_mod.sh > /sasSrvLog/change_folder_mod.out136 2>/sasSrvLog/change_folder_mod.error136


find /home/sas/SmartAgent/data/agent/tmp -name "*.txt" -mtime +90 -exec rm -f {} \;


find /home/sas/SmartAgent/data/agent/tmp -name "*201604*.txt" -exec rm -f {} \;

find /home/sas/SmartAgent/data/agent/tmp -name "*2011*.txt" | xargs ls -l 

find /home/sas/SmartAgent/data/agent/tmp -name "*.txt" -mtime +720 | xargs ls -l 

find /home/sas/SmartAgent/data/agent/tmp -name "*.txt" -mtime +360 -exec rm -f {} \;




压缩目录方式
#!/bin/bash
tarPath="/home/gxp/log"
targetPath=$tarPath"/gzip"
#check the targetPath is ok
if [ -e $targetPath ]
	then
		echo "target path is ok"
	else
		echo "begin to make the target path"
		mkdir -R &targetPath
fi
#command  "-type d -name gzip -prune -o" tell the find command don't include folder gzip
for file in `find $tarPath -type d -name gzip -prune -o -type d -name .tmpblog -prune -o -type d -mtime +7 -print`
do
        tarFile=${file//\//}'.tar.gz'
        echo "----------------------------"
        echo "targetFile: "$tarFile
        echo "folder to tar: "$file
        if [ -e $targetPath/$tarFile ]
        then
                echo "File exits"
        else
                echo "begin to make tar.gz package"
                #cd $file && tar -zcvf $targetPath/$tarFile * --remove-files > /dev/null
        fi
        echo "----------------------------"
done



for targetFolder in `find /home/gjsusr/log/GessNetServer -type d -mtime +180 -print` 
do 
	folderName=`basename $targetFolder`
	cd `dirname $targetFolder`
	if [ $? -eq 0 ];
	then 
		tarFName=${folderName}".tar.gz"
		tar -zcvf $tarFName $folderName --remove-files
	fi
done


for file in 41 42 43 44 45 46 47
do
	sed -i 's/^[][ ]*//g' /tmp/10.8.253.${file}.log                                   #去除文件每一列头的空格
	for user in `cat /tmp/10.8.253.${file}.log | cut -d" " -f1 | sort | uniq`         #获取文件的第一列并获取唯一的UID
	do
		grep "^$user" /tmp/10.8.253.${file}.log > /tmp/10.8.253.${file}.${user}.log   #根据UID获取用户的进程信息
	done
done



#分析目录下的指定条件的文件的大小
for one_dir in $(ls /DATAROOT/20170729/)
do
	printf "%s\n" $one_dir
	time_list=$(ls -lRt /DATAROOT/20170729/$one_dir |awk '{print $8}' | awk -F':' '{print $1}' | grep -v '^$' | uniq)
	for one_time in $time_list
	do
		ts=$(ls -lRt /DATAROOT/20170729/$one_dir | grep $one_time":" | awk '{a=a+($5/1024/1024)}END{print a}')
		printf "%s %s\n" $one_time $ts 
	done 
done

