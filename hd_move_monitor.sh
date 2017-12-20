#!/bin/ksh
currentDate=`date +%D`
currentTime=`date +%H:%M:%S`
tagetPath='/backup/crontab/log'
currentTimeStamp=${currentDate}' '${currentTime}
echo "--------------------${currentTimeStamp}------------------------" >> /backup/crontab/keep
MoveOn.log
currentFileName=`ls -lrt ${tagetPath} | tail -1 | cut -d':' -f2 | cut -d' ' -f2`
absFile=${tagetPath}'/'${currentFileName}
echo "absFile: "$absFile >> /backup/crontab/keepMoveOn.log
errorM=`cat ${absFile} | grep -i ERROR`
errorCount=`cat ${absFile} | grep -i 'Migrate fail' | wc -l`
echo $errorM >> /backup/crontab/keepMoveOn.log
if [ $errorCount != 0 ]
then
        #check the process if on?
        processCnt=`ps -ef | grep -i '/opt/IBM/drc_DataMigrate/highToSlow/DataMigrate.jar' | g
rep -v grep | wc -l`
        if [ $processCnt == 0 ]
        then
                echo "start process at ${currentTimeStamp}" >> /backup/crontab/keepMoveOn.log
				#确保进程在执行后退出，避免当前脚本挂死
                /opt/IBM/drc_DataMigrate/highToSlow/hightoslow.sh &
        else
                echo "the process is on at ${currentTimeStamp}" >> /backup/crontab/keepMoveOn.
log
        fi
else
        echo "no ERROR report in ${absFile}" >> /backup/crontab/keepMoveOn.log
fi
echo '---------------------end-------------------------------------' >>  /backup/crontab/keepM
oveOn.log