chown -R pcinst:db2iadm /home/pcinst
chown -R pcusr:pcgrp /home/pcusr
chown -R pcqry:pcgrp /home/pcqry

chown -R ppinst:db2iadm /home/ppinst
chown -R ppusr:ppgrp /home/ppusr
chown -R ppqry:ppgrp /home/ppqry

chown -R psinst:db2iadm /home/psinst
chown -R psusr:psgrp /home/psusr
chown -R psqry:psgrp /home/psqry

myDb2Codepage=1386
for oneUser in psinst ppinst psinst
do
	if [ $oneUser = pcinst ]
	then
		dbname=pcdb
	elif [ $oneUser = ppinst ]
	then
		dbname=ppdb
	elif [ $oneUser = psinst ]
	then
		dbname=psdb
	fi
	echo $oneUser $dbname
	su - $oneUser -c "db2set DB2COUNTRY=86;db2set DB2CODEPAGE=${myDb2Codepage};db2set DB2COMM=TCPIP;db2 update dbm cfg using SVCENAME DB2_pcdb;db2 update dbm cfg using HEALTH_MON OFF;db2 update dbm cfg using DFT_MON_BUFPOOL on DFT_MON_LOCK on DFT_MON_SORT on DFT_MON_STMT on DFT_MON_TABLE on DFT_MON_TIMESTAMP on DFT_MON_UOW on"
	su - $oneUser -c "db2set;db2 get dbm cfg | grep -i svce;db2 get dbm cfg | grep -i HEALTH_MON;db2 get dbm cfg | grep -i DFT_MON"
	isDbCreate=`su - $oneUser -c "db2 list db diretory | grep -i ${dbname} | wc -l"`
	if [ $isDbCreate -lt 1 ]
	then 
		echo "db not create,exist!"
	else
		su - $oneUser -c "db2 update db cfg for $dbname using LOGFILSIZ 25600;db2 update db cfg for $dbname using LOGSECOND 50;db2 update db cfg for $dbname using LOGPRIMARY 100;db2 update db cfg for $dbname using AUTO_MAINT OFF;"
	fi
	echo "--------------------------------------------------------"
done


dbname=psdb;
db2 update db cfg for $dbname using LOGFILSIZ 25600;db2 update db cfg for $dbname using LOGSECOND 50;db2 update db cfg for $dbname using LOGPRIMARY 100;db2 update db cfg for $dbname using AUTO_MAINT OFF;

db2 update db cfg for $dbname using LOGARCHMETH1 DISK:/db2log;
db2 backup db $dbname to /dev/null


su - pcinst -c "db2set DB2COUNTRY=86;db2set DB2CODEPAGE=1386;db2set DB2COMM=TCPIP;db2 update dbm cfg using SVCENAME DB2_pcdb;db2 update dbm cfg using HEALTH_MON OFF;db2 update dbm cfg using DFT_MON_BUFPOOL on DFT_MON_LOCK on DFT_MON_SORT on DFT_MON_STMT on DFT_MON_TABLE on DFT_MON_TIMESTAMP on DFT_MON_UOW on"
su - ppinst -c "db2set DB2COUNTRY=86;db2set DB2CODEPAGE=1386;db2set DB2COMM=TCPIP;db2 update dbm cfg using SVCENAME DB2_ppdb;db2 update dbm cfg using HEALTH_MON OFF;db2 update dbm cfg using DFT_MON_BUFPOOL on DFT_MON_LOCK on DFT_MON_SORT on DFT_MON_STMT on DFT_MON_TABLE on DFT_MON_TIMESTAMP on DFT_MON_UOW on"
su - psinst -c "db2set DB2COUNTRY=86;db2set DB2CODEPAGE=1386;db2set DB2COMM=TCPIP;db2 update dbm cfg using SVCENAME DB2_psdb;db2 update dbm cfg using HEALTH_MON OFF;db2 update dbm cfg using DFT_MON_BUFPOOL on DFT_MON_LOCK on DFT_MON_SORT on DFT_MON_STMT on DFT_MON_TABLE on DFT_MON_TIMESTAMP on DFT_MON_UOW on"




$update db cfg for esbdb using LOGFILSIZ 65535;

$update db cfg for esbdb using LOGSECOND 20;

$update db cfg for esbdb using LOGPRIMARY 300；

$ db2 update db cfg for carddb using AUTO_MAINT OFF

$ db2 update db cfg for carddb using LOGARCHMETH1 DISK:/db2log

$db2 update dbm cfg using DFT_MON_BUFPOOL on DFT_MON_LOCK on DFT_MON_SORT on DFT_MON_STMT on DFT_MON_TABLE on DFT_MON_TIMESTAMP on DFT_MON_UOW on






db2set DB2CODEPAGE=1208

db2set DB2COMM=TCPIP

db2 update dbm cfg using SVCENAME DB2_esbdb

db2 update dbm cfg using HEALTH_MON OFF
