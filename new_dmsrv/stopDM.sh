#!/bin/ksh
#����ũ���л���Ӧ��
su - jhusr -c "/acmis/JHODS/JHShell/baseshell/control/shutdownJH.sh"
count =`ps -u jhusr | grep -i sleep | wc -l`
if [ $count -ne 0 ]
then
        echo "manual kill jhusr's sleep process"
fi

echo "-------------------------------------------------------------------------------"
#�������˴���Ӧ��
su - jhczusr -c "/acmiscz/JHCZODS/JHShell/baseshell/control/startupJH.sh;/acmiscz/ACCZLOG/JHCZLOG/listMsg.sh"
if [ $? -ne 0 ]
then
        echo "start jhcz app failed"
fi
echo "-------------------------------------------------------------------------------"
#�����Ŵ�����Ӧ��
su - xdczusr -c "/acmiscz/XDCZODS/XDShell/baseshell/control/startupJKCZ.sh;/acmiscz/XDCZODS/XDShell/baseshell/control/startupXDCZ.sh"
if [ $? -ne 0 ]
then
        echo "start xdcz app failed"
fi
echo "-------------------------------------------------------------------------------"
#��ʾ��P6 570������Ӧ��
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
#�����ۺϹ���ϵͳϵͳũ����Ӧ��
su - jxusr -c "/acmis/JXODS/JXShell/baseshell/control/startupJX.sh"
if [ $? -ne 0 ]
then
        echo "start jx app failed"
fi

#��ʾ��11.8.8.25������Ӧ��
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



