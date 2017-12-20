#!/bin/bash

check_ip_port(){
	input_ip=$1
	for port_num in 111 2049 2050;do
		nc -w 1 -vz ${input_ip} ${port_num}
		nc -w 1 -vz -u ${input_ip} ${port_num}
	done
}



check_nfs(){
	input_nas=$1
	case ${input_nas} in
	"WQZ")
		#10.8.9.85(灾备10.8.9.83）	10.8.9.86(灾备10.8.9.84）
		#10.8.5.59(灾备10.8.5.61）	10.8.5.60(灾备10.8.5.62）
		#10.8.10.89(灾备10.8.10.91）	10.8.10.90(灾备10.8.10.92）
		#10.8.11.4(灾备10.8.11.6）	10.8.11.5(灾备10.8.11.7）
		#10.8.12.6(灾备10.8.12.8）	10.8.12.7(灾备10.8.12.9）
		#11.8.10.19(灾备11.8.10.21）	11.8.10.20(灾备11.8.10.22）
		printf "%s\n" "belong to"
		printf "%s\n%s\n%s\n" "1)10.8.9" "2)10.8.5" "3)10.8.10" "4)10.8.11" "5)10.8.12" "6)11.8.10"
		printf "%s" "select one to do:"
		read input_choice
		if [ $input_choice = "1" ];then
			for num in 83 84 85 86;do	
				check_ip_port "10.8.9."$num
				printf "\n" 
			done
		elif [ $input_choice = "2" ];then
			for num in 59 60 61 62;do	
				check_ip_port "10.8.5."$num
				printf "\n"
			done
		elif [ $input_choice = "3" ];then
			for num in 89 90 91 92;do	
				check_ip_port "10.8.10."$num
				printf "\n"
			done
		elif [ $input_choice = "4" ];then
			for num in 4 5 6 7;do	
				check_ip_port "10.8.11."$num
				printf "\n"
			done
		elif [ $input_choice = "5" ];then
			for num in 6 7 8 9;do	
				check_ip_port "10.8.12."$num
				printf "\n"
			done	
		elif [ $input_choice = "6" ];then
			for num in 19 20 21 22;do	
				check_ip_port "11.8.11."$num
				printf "\n"
			done
		fi
		;;
	"ZHXX")
		#11.8.8.110(灾备11.8.8.97）  	11.8.8.111(灾备11.8.8.98）
		#11.8.11.11(灾备11.8.11.13）	11.8.11.12(灾备11.8.11.14）
		printf "%s\n" "belong to"
		printf "%s\n%s" "1)11.8.8" "2)11.8.11"
		printf "%s" "select one to do:"
		read input_choice
		if [ $input_choice = "1" ];then
			for num in 97 98 110 111;do	
				check_ip_port "11.8.8."$num
				printf "\n" 
			done
		elif [ $input_choice = "2" ];then
			for num in 11 12 13 14;do	
				check_ip_port "11.8.11."$num
				printf "\n"
			done
		fi
		;;
	"HLW3")
		#192.168.3.66(灾备192.168.3.63）	192.168.3.67(灾备192.168.3.64）
		for num in 63 64 66 67;do	
			check_ip_port "192.168.3."$num
			printf "\n" 
		done
		;;
	esac

}

printf "%s\n" "to check 1)WQZ 2)ZHXX 3)HLW3"
read input_c
case $input_c in
"1")
	check_nfs "WQZ"
	;;
"2")
	check_nfs "ZHXX"
	;;
"3")
	check_nfs "HLW3"
	;;
esac