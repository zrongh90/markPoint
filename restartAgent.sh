#!/bin/bash
myarr=`/tivoli/opt/IBM/ITM/bin/cinfo -i | awk '/ITCAM Agent for WebSphere Applications/ || /IBM Tivoli Composite Application Manager Agent for HTTP Servers/ || /Tivoli Log File Agent/ || /Monitoring Agent for DRCBank Linux Agent/ || /Monitoring Agent for Linux OS/ {print $0}' | awk -F" " '{print $1}'`
echo '安装的监控agent有:'
#eval $(awk -v info="$myarr" 'BEGIN{
#len = split(info, array, "|");
#for(i=1; i<len; i++)
#	 print array[i];
#
#}')
#echo -n "需要启动的agent列表，以','分割: "
#read agentToStart
echo $myarr
#OLD_IFS="$IFS"
#IFS=","
arr=($myarr)
#IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "正在停止agent：$s"
	if [ "$s" = "lz" ]; then
		/tivoli/opt/IBM/ITM/bin/itmcmd agent stop lz
	elif [ "$s" = "21" ]; then
		/tivoli/opt/IBM/ITM/bin/itmcmd agent stop 21
	elif [ "$s" = "lo" ]; then
		/tivoli/opt/IBM/ITM/bin/itmcmd agent -o messages stop lo
	else 
		echo "no match"
	fi
done
sleep 10
kill -9 `ps -ef | grep /tivoli/opt/IBM/ITM | grep -v grep | awk -F" " '{print $2}'`

for s in ${arr[@]}; do
         echo "正在启动agent：$s"
        if [ "$s" = "lz" ]; then
                /tivoli/opt/IBM/ITM/bin/itmcmd agent start lz
        elif [ "$s" = "21" ]; then
                /tivoli/opt/IBM/ITM/bin/itmcmd agent start 21
        elif [ "$s" = "lo" ]; then
                /tivoli/opt/IBM/ITM/bin/itmcmd agent -o messages start lo
        else
                echo "no match"
        fi
done
