#!/bin/ksh
#启动农商行稽核应用
su - jhusr -c "/acmis/JHODS/JHShell/baseshell/control/shutdownJH.sh"
count =`ps -u jhusr | grep -i sleep | wc -l`
if [ $count -ne 0 ]
then
        echo "manual kill jhusr's sleep process"
fi

echo "-------------------------------------------------------------------------------"
#启动稽核村镇应用
su - jhczusr -c "/acmiscz/JHCZODS/JHShell/baseshell/control/startupJH.sh;/acmiscz/ACCZLOG/JHCZLOG/listMsg.sh"
if [ $? -ne 0 ]
then
        echo "start jhcz app failed"
fi
echo "-------------------------------------------------------------------------------"
#启动信贷村镇应用
su - xdczusr -c "/acmiscz/XDCZODS/XDShell/baseshell/control/startupJKCZ.sh;/acmiscz/XDCZODS/XDShell/baseshell/control/startupXDCZ.sh"
if [ $? -ne 0 ]
then
        echo "start xdcz app failed"
fi
echo "-------------------------------------------------------------------------------"
#提示在P6 570上启动应用
xdcztips="login 11.8.11.3 connect to 11.8.8.2 to run (su - xdczusr -c '/etlcz/CMISCZServices/run.sh')" 
echo $xdcztips
echo "answer:yes or no"
read input
while [ $input != "yes" ]
do
	echo $xdcztips
	echo "answer:yes or no"
	read input
done

echo "-------------------------------------------------------------------------------"
#启动综合管理系统系统农商行应用
su - jxusr -c "/acmis/JXODS/JXShell/baseshell/control/startupJX.sh"
if [ $? -ne 0 ]
then
        echo "start jx app failed"
fi

#提示在11.8.8.25上启动应用
jxtips="login 11.8.8.25 connect to 11.8.8.17 to run (su - jxusr -c '/acmis/JXODX/JavaPro/startDX.sh')" 
echo $jxtips
echo "answer:yes or no"
read input
while [ $input != "yes" ]
do
	echo $jxtips
	echo "answer:yes or no"
	read input
done
	
echo "-------------------------------------------------------------------------------"



