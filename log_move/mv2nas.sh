sourcePath=$1
targetPath=$2
daybefore=$3
checkResult='no'
readdir(){
filelist=`ls $1`
for filename in $filelist; do
	absPath=$1'/'$filename
	if [ -f $absPath ];then
		relativePath=${absPath##*$sourcePath}
		relativePath=${relativePath##%$filename}
		checkResult=`checkCanMove $absPath`
		echo '---------------------'
		echo 'chekcResult: '$checkResult
		echo 'absPath:  '$absPath
        	echo 'relativePath:  '$relativePath
        	echo 'filename:  '$filename
		if [ "$checkResult" = "yes" ]
		then
			#echo "test"
			mvFile2Nas $absPath $relativePath $filename
		fi
	elif [ -d $absPath ]; then
		#echo $absPath
		cd $absPath
		readdir $absPath
		cd ..
	fi
done
}
checkCanMove(){
	relativePath=${1##*$sourcePath}
	relativePath=${relativePath%/*}
	localLang=`echo $LANG`
	if [ "$localLang" = "ZH_CN.UTF-8" ]
	then
		modifiedTime=`istat $1 | grep '上次修改'| awk '{print substr($2,3,4),substr($2,8,2),substr($2,11,2)}' | sed 's/[[:space:]]//g'`
	else 
		mydate=`istat $1 | grep 'Last modified' | awk '{print $3,$4,$5,$6,$7,$8}'`
		month=`echo $mydate | awk -F" " 'BEGIN{t=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec",a," ");for(n=1;n<=t;n++)mon[a[n]]=n}{printf("%02d",mon[$2])}'`
		year=`echo $mydate | awk '{print $6}'`
		day=`echo $mydate | awk '{printf("%02d",$3)}'`
		modifiedTime=$year$month$day
	fi
	d=`DaysAfterOrBefore -$daybefore "20%y%m%d"`
	if [ $modifiedTime -lt $d ]
	then
		echo 'yes'
	else
		echo 'no'
	fi
}
DaysAfterOrBefore()
{
  # $1:the number of days before or after today
  # $2:the format of date
  CurrentTZ=`echo $TZ`
  if (( $1 > 0 )) 
  then
    TimeZoneDiff=`echo 24*$1+8 | bc`
    export TZ=BEIST-$TimeZoneDiff
  elif (( $1 == 0 )) ;then
    :
  else
    TimeZoneDiff=`echo -24*$1-8 | bc`
    export TZ=BEIST+$TimeZoneDiff
  fi
  
  date +"$2"
  export TZ=$CurrentTZ
}


mvFile2Nas(){
	absPath=$1
	relativePath=$2
	filename=$3
	targetAbsPath=$targetPath$relativePath
	targetAbsFilename=$targetPath$relativePath$filename
	if [ ! -d $targetAbsPath ]; then
		mkdir -p $targetAbsPath
	fi
	if [ -f $absPath ];then
		mv $absPath $targetAbsPath
	fi
}

readdir $sourcePath
