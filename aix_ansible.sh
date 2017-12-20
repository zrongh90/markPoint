/tmp/test_hosts
10.8.253.120
10.8.253.140

[tmpusr@ansible tmp]$ cat check_hosts.sh 
#!/bin/bash
host_file="/tmp/test_hosts"
ping_result="/tmp/ping_result"
echo > $ping_result
for host_ip in `cat $host_file`
do
	echo "start to ping $host_ip"
	ping -c 1 $host_ip > /dev/null
	result=$?
	my_output=""
	if [ $result -eq 0 ]
	then
		my_output="$host_ip accessible"
		echo $my_output
	else
		my_output="$host_ip not accessible"
		echo $my_output
	fi
	echo $my_output >> $ping_result
done

[tmpusr@ansible tmp]$ cat check_aix_version.sh 
#!/bin/bash

port=22
user="root"
echo "input passwd:"
read -s passwd
passwd="root1234"
hostname="/usr/bin/hostname | tail -1"
oslevel="/usr/bin/oslevel -s | tail -1"

for host_ip in `cat /tmp/test_hosts`
do
	my_hostname=`sshpass -p $passwd ssh -o StrictHostKeyChecking=no -t  $user@$host_ip $hostname`
	my_aix_version=`sshpass -p $passwd ssh -o StrictHostKeyChecking=no -t  $user@$host_ip $oslevel`
	echo $host_ip
	echo $my_hostname
	echo $my_aix_version
done