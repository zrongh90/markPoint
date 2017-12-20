#!/bin/bash
#init hostname
hostname=`grep -i myhostname initLz.cfg | cut -d'=' -f2`
ipInfo=`grep -i mynetwork initLz.cfg | cut -d'=' -f2 | cut -d'(' -f2 | cut -d')' -f1`
etherName=`echo $ipInfo |  awk -F"," '{print $1}'`
if [ ! $ipInfo ]
then
	echo "not ip info to modified!"
else	
	ipAddr=`echo $ipInfo | awk -F"," '{print $2}'`
	netmask=`echo $ipInfo | awk -F"," '{print $3}'`
	gateway=`echo $ipInfo | awk -F"," '{print $4}'`
	echo "IP ADDR is ${ipAddr}"
	echo "netmask is ${netmask}"
	echo "gateway is ${gateway}"
fi
################################change hostname info ###############################
chg_hostname(){
	if [ ! $hostname ]
	then
		echo "hostname not modified"
		return 1
	fi	
	ifModified=`grep -i $hostname /etc/hosts | wc -l`
	if [ $ifModified == 0 ]
	then
		echo "start to modify hostname in /etc/hosts and /etc/sysconfig/network"
		echo $ipAddr $hostname >> /etc/hosts
		sed -i "s/rhel67.drcbank.com/$hostname/g" /etc/sysconfig/network
	else
		echo "/etc/hosts and /etc/sysconfig/network is already modified"
	fi
}
################################change hostname info end ###############################

############################### change network info ##############################
init_net(){
	ethFileName="/etc/sysconfig/network-scripts/ifcfg-${etherName}"
	echo "ethFileName:"$ethFileName
	if [ -e $ethFileName ]
	then
		ifModified=`grep -i IPADDR $ethFileName| cut -d'=' -f2 | wc -w`
		if [ $ifModified == 0 ]
		then
			sed -i "s/IPADDR=/IPADDR=${ipAddr}/g" $ethFileName
			sed -i "s/NETMASK=/NETMASK=${netmask}/g" $ethFileName
			sed -i "s/GATEWAY=/GATEWAY=${gateway}/g" $ethFileName
		else
			echo $ethFileName" is modified"
		fi
	else
		echo "create ifcfg-${etherName} and set its network infomations"
		cd /etc/sysconfig/network-scripts
		ethFileName=/etc/sysconfig/network-scripts/ifcfg-${etherName}
		echo -e "DEVICE=${etherName}\nONBOOT=yes\nBOOTPROTO=static\nTYPE=Ethernet\nNM_CONTROLLED=no\nDNS1=\nDNS2=\nIPADDR=${ipAddr}\nNETMASK=${netmask}\nGATEWAY=${gateway}" > ${ethFileName}
		#cp ifcfg-eth0 ifcfg-${etherName}
		#sed -i "s/IPADDR=/IPADDR=${ipAddr}/g" $ethFileName
	   	 #sed -i "s/NETMASK=/NETMASK=${netmask}/g" $ethFileName
	    	#sed -i "s/GATEWAY=/GATEWAY=${gateway}/g" $ethFileName
	fi
	echo "start ether for file ${ethFileName}"
	isEthAlreadyOn=`ifconfig -a | grep -i ${etherName} -A 1 | grep ${ipAddr} | wc -l`
	if [ 0 == ${isEthAlreadyOn} ]
	then
		ifup $ethFileName
	else
		echo "${etherName} is already on"
	fi
}
	
############################### change network info end ##############################

##############################init file system##############################
init_fs(){
	hdisk=`grep -i hdisk /zxyx/initLz/initLz.cfg | cut -d'|' -f1 | cut -d'=' -f2` 
	vgname=`grep -i vgname /zxyx/initLz/initLz.cfg | cut -d'|' -f2 | cut -d'=' -f2` 
	lvlist=`grep -i lvlist /zxyx/initLz/initLz.cfg | cut -d'|' -f3 | cut -d'=' -f2` 
	if [ -e /dev/$hdisk ]
	then
		
		count=`echo ${lvlist//[^;]} | wc -c`
		vgIsExists=`vgs | grep $vgname | wc -l`
		if [ $vgIsExists == 0 ]
		then
			echo "/dev/$hdisk initial"
			pvcreate /dev/$hdisk 
			echo "begin to create $vgname"
			vgcreate $vgname /dev/$hdisk 
		else
			echo "volumn group $vgname is already created"
			#return 1
		fi

		iternate=1
		while [ $iternate -le $count ]
		do
			onelv=`echo $lvlist | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
			iternate=`expr $iternate + 1`
			#lvcreate
			lvname=`echo $onelv | cut -d',' -f1`
			lvsize=`echo $onelv | cut -d',' -f2`
			mountP=`echo $onelv | cut -d',' -f3` 
			if [ -e /dev/${vgname}/${lvname} ]
			then 
				echo "logical volumn $lvname is exists, not create"
				break
			else
				echo -e "begin to create logical volumn \n name: ${lvname} \n size: ${lvsize} \n mountP: ${mountP} \n"
				lvcreate -L $lvsize -n $lvname $vgname 1>/dev/null
				mkfs.ext4 /dev/${vgname}/${lvname} 1>/dev/null
				mkdir -p ${mountP}
				#mount /dev/${vgname}/${lvname} ${mountP}
				fstabRc=`blkid /dev/${vgname}/${lvname} | cut -d" " -f2`
				fstabRc=${fstabRc}"\t"${mountP}"\t""ext4\tdefaults\t0 0"
				cp /etc/fstab /etc/fstab.bak.`date +%y%m%d%H%M`
				echo -e $fstabRc >> /etc/fstab
				mount -a
			fi
	 
		done 
	else
		echo "/dev/$hdisk is not exist"
	fi
}
##############################init file system end##############################	

##############################add user and group##############################
add_usr_grp(){
	#add group
	grpList=$(grep -i mygroup /zxyx/initLz/initLz.cfg | cut -d'=' -f2)
	count=$(echo ${grpList//[^;]} | wc -c)
	iternate=1
	while [[ $iternate -le $count && $grpList ]]
	do
		one_group=$(echo $grpList | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1)
		groupName=$(echo $one_group | cut -d',' -f1)
		groupID=$(echo $one_group | cut -d',' -f2)
		grpIsExist=`cat /etc/group | grep -w ${groupID} | wc -l`
		if [ $grpIsExist == 0 ]
		then
		#如果组不存在
			echo "start to create ${groupName} ; groupID is ${groupID}"
			groupadd -g ${groupID} ${groupName}
		else
			echo "grp ${groupID} is already exist and its name is `cat /etc/group | grep -w ${groupID} | cut -d':' -f1`"

		fi
		iternate=`expr $iternate + 1`
		
	done
	
	#addUser
	userList=`grep -w myuser /zxyx/initLz/initLz.cfg | cut -d'=' -f2 `
	count=`echo ${userList//[^;]} | wc -c`
	iternate=1
	while [[ $iternate -le $count && $userList ]]
	do
		
		oneUser=`echo $userList | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
		userName=`echo $oneUser | cut -d',' -f1`
		userID=`echo $oneUser | cut -d',' -f2`
		userGrp=`echo $oneUser | cut -d',' -f3`
		userGrpID=`cat /etc/group | grep -i $userGrp | cut -d':' -f3`
		if [ ! $userGrpID ]
		then
			echo " $userGrp is not found in /etc/group"
			iternate=`expr $iternate + 1`
			break
		fi
		userIsExist=`cat /etc/passwd | grep -w ${userName} | wc -l`
		if [ $userIsExist == 0 ]
		then
		#如果用户不存在
			echo "start to create ${userName} belong to ${userGrp}, it's userID is ${userID} and userGrpID is ${userGrpID}"
			useradd -u ${userID} -g ${userGrpID} -m -k /etc/skel -s /bin/bash ${userName} 1>/dev/null
			echo "DRC1bank" | passwd --stdin ${userName}
			cp /etc/skel/.bash* /home/${userName} 1>/dev/null
			chown -R ${userName}:${userGrp} /home/${userName} 1>/dev/null
		else
			echo "user $userName is already created!"
		fi
		iternate=`expr $iternate + 1`
		
	done
}
##############################add user and group end##############################

##############################change the filesystem auth ##############################
chg_fs_auth(){
	fsList=`grep -w filesystemAuth /zxyx/initLz/initLz.cfg | cut -d'=' -f2 `
	count=`echo ${fsList//[^;]} | wc -c`
	iternate=1
	while [ $iternate -le $count ]
	do
		oneFs=`echo $fsList | cut -d';' -f$iternate | cut -d'(' -f2 | cut -d')' -f1`
		fsPath=`echo $oneFs | cut -d',' -f1`
		fsOwner=`echo $oneFs | cut -d',' -f2`
		fsOwnerGID=`cat /etc/group | grep -i ${fsOwner} | cut -d':' -f3`
		echo "start to change the owner for ${fsPath}"
		if [ -e ${fsPath} -a `cat /etc/passwd | grep -w ${fsOwner} | wc -l` == 1 ]
		then
			chown -R ${fsOwner}:${fsOwnerGID} ${fsPath}
		else
			echo "chown Mod error , ${fsOwner} or ${fsPath} not exists"
		fi
		iternate=`expr $iternate + 1`
	done
}
##############################change the filesystem auth end#############################

##############################init used for #####################################
init_env(){
	usedForList=`grep -w usedFor /zxyx/initLz/initLz.cfg | cut -d'=' -f2`
	count=`echo ${usedForList//[^;]} | wc -c`
	yumIP='10.8.251.100'
	port=80
	if [ -e $usedForList ]
	then 
		echo "not need to initial software environment"
	else
		#check if the ip belong to hlw 2,if yes, add static route 20170609
		if [[ $ipAddr && $ipAddr == *"192.168.2"* ]]     
		then
			staticRtRec1="any net 10.8.1.0 netmask 255.255.255.0 gw 192.168.2.4"
			staticRtRec251="any net 10.8.251.0 netmask 255.255.255.0 gw 192.168.2.4"
			staticRtRecNtp="any net 11.8.8.0 netmask 255.255.255.0 gw 192.168.2.4"
			#file not exist, add file and routes
			if [ ! -f /etc/sysconfig/static-routes ]    
			then
				echo $staticRtRec1 >> /etc/sysconfig/static-routes
				echo $staticRtRec251 >> /etc/sysconfig/static-routes
				echo $staticRtRecNtp >> /etc/sysconfig/static-routes
			#file exist, if route not exist add
			else
				if [[ ! $(grep "$staticRtRec1" /etc/sysconfig/static-routes) ]]
				then
					echo $staticRtRec1 >> /etc/sysconfig/static-routes
				fi
				if [[ ! $(grep "$staticRtRec251" /etc/sysconfig/static-routes) ]]
				then
					echo $staticRtRec251 >> /etc/sysconfig/static-routes
				fi
				if [[ ! $(grep "$staticRtRecNtp" /etc/sysconfig/static-routes) ]]
				then
					echo $staticRtRecNtp >> /etc/sysconfig/static-routes
				fi
			fi
		fi			
				
			
		nc -vz -w 2 $yumIP $port
		if [ $? -eq 0 ]
		then
			echo > /zxyx/initLz/init_env.log
			iternate=1
			while [ $iternate -le $count ]
			do
				oneUsed=`echo $usedForList | cut -d';' -f${iternate}`
				curl $yumIP/scripts/02-init-${oneUsed}.sh | sh >> /zxyx/initLz/init_env.log
				iternate=`expr $iternate + 1`
			done
			echo "init environment success! please check file init_env.log in current directory!" 
		else
			echo "ERROR: yum source 10.8.251.100 is not accessable"
		fi
	fi
}
echo "########################start init hostname####################################"
chg_hostname

echo "########################start init network####################################"
if [ ! $etherName ]
then
	echo "no ether to init"
else	
	net_dev=`cat /proc/net/dev | grep -i $etherName | wc -l`
	if [ $ipInfo ]
	then
		if [ $net_dev -eq 1 ]
		then
			init_net
		else
			echo "network device $net_dev not exists!"
		fi
	else
		echo "ip Info is null"
	fi
fi
echo "########################start init filesystem####################################"
init_fs
echo "########################start init user and group####################################"
add_usr_grp
echo "########################start init filesystem auth####################################"
chg_fs_auth
echo "########################start init middleware env####################################"
init_env

