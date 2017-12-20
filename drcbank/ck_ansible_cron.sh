#!/bin/bash
#检查crontab -l中将结果写入/tmp目录的txt后缀的日志文件的ansible脚本的执行情况
#主要判断两种情况
#  1)ansible主机无法到达目标机器（需要排查机器情况）
#  2)目标主机failed情况（是否脚本问题）
printf "                          %s %s\n" $(date "+%Y/%m/%d %H:%M")
for one_file in $(ls /tmp/*.txt);do
	printf "\n$one_file\n"
	cat $one_file | grep -E "(unreachable|failed)=[1-9][0-9]{0,}"
done
printf "%s\n" "---------------------------------------------------------------------"
