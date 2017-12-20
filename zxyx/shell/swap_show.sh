#!/bin/sh
linux_swap_show(){
	for pid in $(ls -l /proc | grep ^d | awk -F' ' '{print $9}' | grep -v [^0-9])
	do
			if [ $pid -eq 1 ]
			then
					continue;
			fi
		if [ ! -f /proc/${pid}/smaps ];then
			continue
		fi	
			grep -q "Swap" /proc/$pid/smaps
			if [ $? -eq 0 ]
			then
				pidSwapMem=$(cat /proc/$pid/smaps | grep -i swap | awk '{ sum+=$2;} END{print sum}')
				processName=$(ps aux | grep -w $pid | grep -v grep | awk '{for(i=11;i<=NF;i++){printf("%s ",$i)}}')
			printf "%8s%8sKB\t%s\n" $pid $pidSwapMem "$processName"
			fi
	done
}

aix_swap_show(){
	for pid in $(ps -ef | grep -vw PID | awk '{print $2}')
	do
		if [ $pid -eq 1 ]
		then
			continue;
		fi
		pgsp=$(svmon -P $pid | awk 'NR==4{print $5}')
		expr $pgsp + 0 >/dev/null 2>/dev/null
		if [ $? -ne 0 ]
		then
			continue;
		fi
		pgspKB=$(expr $pgsp \* 4)
		processCmd=$(ps -ef -o "%p %c %a" | grep -w $pid | grep -v grep| awk '{for(i=3;i<=NF;i++){printf("%s ",$i)}}')
		#echo $pid ${pgspKB} $processCmd
		printf "%8s%8sKB\t%s\n" $pid ${pgspKB} "$processCmd"
	done
}


sys_platform=$(echo $(uname) | tr '[A-Z]' '[a-z]')

if [ $sys_platform = "linux" ];then
	linux_swap_show
elif [ $sys_platform = "aix" ];then
	aix_swap_show
else
	echo "platform $sys_platform not know"
	exit 1
fi

