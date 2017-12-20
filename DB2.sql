--建库新规范
db2 CREATE DATABASE esbdb on /home/esbinst/datatbs DBPATH ON /home/esbinst USING CODESET UTF-8 TERRITORY CN;

--列出库列表
db2 list db directory  

--列出数据库的信息，当前生效和未生效信息（需要先connect数据库）
db2 get db cfg show detail

--查看实例用户下的数据库表
db2 list tables for schema <schema_name>

--db2 descirbe 语法
db2 descirbe table instanceName.tablename 

--查看数据库下对应的表空间的信息
db2 "select tbsp_id as TABLESPACE_ID, substr(tbsp_name,1,30) as TABLESPACE_NAME, substr(TBSP_TYPE,1,10) as TBSP_TYPE, substr(tbsp_content_type,1,10) as TABLESPACE_TYPE, sum(tbsp_total_size_kb)/1024 as TOTAL_MB, sum(tbsp_used_size_kb)/1024 as USED_MB, sum(tbsp_free_size_kb)/1024 as FREE_MB, tbsp_page_size AS PAGE_SIZE from SYSIBMADM.TBSP_UTILIZATION group by tbsp_id,tbsp_name, tbsp_type, tbsp_content_type, tbsp_page_size order by 1"   

--查看数据库下指定的表空间的ID
db2 "select tbsp_id as TABLESPACE_ID, substr(tbsp_name,1,30) as TABLESPACE_NAME, substr(TBSP_TYPE,1,10) as TBSP_TYPE, substr(tbsp_content_type,1,10) as TABLESPACE_TYPE, sum(tbsp_total_size_kb)/1024 as TOTAL_MB, sum(tbsp_used_size_kb)/1024 as USED_MB, sum(tbsp_free_size_kb)/1024 as FREE_MB, tbsp_page_size AS PAGE_SIZE from SYSIBMADM.TBSP_UTILIZATION group by tbsp_id,tbsp_name, tbsp_type, tbsp_content_type, tbsp_page_size order by 1" | grep DATAESTBS32K | awk '{print $1}'  

--查看指定的表空间ID的容器
db2 list tablespace container for <tablespace_id>

--db2look单独一张表
db2look -d cdfsdb -tw cln_cuptxn -e -o /home/cardfrs/cln_cuptxn.ddl

--export 命令
EXPORT TO filename OF {IXF | DEL | WSF}  
[LOBS TO lob-path [ {,lob-path} ... ] ]
[LOBFILE lob-file [ {,lob-file} ... ] ]
[MODIFIED BY {filetype-mod ...}]
[MESSAGES message-file]
{select-statement [WHERE ...] }

modified by 文本修饰符定制，CHARDELx指定字符串定界符，COLDELx指定字段定界符

--import 命令
IMPORT from <filename> OF {IXF | DEL | WSF}
[MODIFIED BY {filetype-mod ...}]
[MESSAGES message-file]
<action> INTO <table_name>

action包括insert（追加）、insert_update、replace（首先删除表，然后插入，注意数据的备份）

--load 命令
LOAD FROM <input_source> OF <input_type>
 MODIFIED BY DUMPFILE=</tmp/target.dump>
  MESSAGES <message_file>
   [INSERT | REPLACE | TERMINATE | RESTART ]
	 INTO <target_tablename>
	   FOR EXCEPTION <target_exp> (copy no: 将表空间置于backup pending状态; copy yes: 自动对表所属表空间备份；nonrecoverable 标记表不可恢复，否则需要备份表空间)
支持4种动作：insert、repalce、terminate、restart

--在线备份(日志是归档模式）
backup db <db> online [to <path>] compress [include logs]
backup db <db> tablespace (<tbs1>[, <tbs2>]) online [to <path>]
db2 backup db CNAPSDB online to /home/uppinst1/tbspace/backup compress include logs without prompting

--离线备份（需要确保应用没有连接数据库）
db2 connect to CMISCZDB
db2 list applications 
db2 quiesce db immediate force connections
db2 terminate
db2 deactivate db CMISCZDB
db2 connect to CMISCZDB
db2 backup db CMISCZDB to /home/xdczinst1/datatbs/backup
db2 connect to CMISCZDB
db2 activate db CMISCZDB
db2 unquiesce db
db2 connect reset
db2 connect to CMISCZDB

--查看是否属于归档日志模式
通过db2 get db cfg for <db> | grep -i log 中的LOGARCHMETH1参数是否等于OFF，
1）如果是OFF时，表示循环日志模式；
2）如果是OFF外的其他值时，表示归档模式。

--db2扩大裸设备的表空间
db2pd -d db_name -tablespace #查看表空间信息，确认表空间使用的裸设备

Database Partition 0 -- Database PCRMDB -- Active -- Up 3 days 14:50:25 -- Date 2017-07-29-17.15.23.732792
Tablespace Configuration:
Address            Id    Type Content PageSz ExtentSz Auto Prefetch BufID BufIDDisk FSC NumCntrs MaxStripe  LastConsecPg Name
0x07700001DAF2D000 4     DMS  Large   32768  32       No   32       3     3         Off 1        0          31           SPDTBS32K
Containers:
Address            TspId ContainNum Type    TotalPgs   UseablePgs PathID     StripeSet  Container 
0x07700007514DA3A0 4     0          Disk    13107200   13107168   -          0          /dev/rSPDTBS32K1

smit hacmp扩大裸设备对应的LV大小
db2 "alter tablespace 表空间名 resize(device '/dev/rdeivcename' 20G,device '/dev/rdeivcename' 20G)"

--设置表空间自增
for tbs in ESSC5DBSPACE ESSC5DB_INDEX
do
db2 ALTER TABLESPACE $tbs AUTORESIZE YES INCREASESIZE 5G MAXSIZE NONE;
done

--查看日志占用空间(log space used)
db2 get snapshot for all on dbname | grep -i log

--db2在表空间类型为regular的状态下，表空间最大支持256G，如果超过这个限制，表空间自增长失败，需要通过以下命令对表空间类型进行转换：
db2 alter tablespace *** convert to large


--数据库切换后，如果数据库起不来，报表空间无法连接，权限错误，注意文件系统下的裸设备权限。
1、停止数据库
2、lsvg -l datavg查看裸设备状态，是否为closed
3、如果裸设备权限不对，需要修改该裸设备的权限
4、启动数据库

--db2上线注意svce_name不用使用db2自动生成的60000到60005的端口，重新选择一个高位端口使用
cat /etc/services
svce_db2inst	60040/tcp

db2 update dbm cfg using SVCENAME svce_db2inst

--数据库runstat、reorg及rebind问题
1、runstats(针对单表执行)收集统计信息，为DB2优化器提供最佳路径选择；reorg重组表，减少表和索引在物理存储的碎片；rebind对包、存储过程或静态程序进行重新绑定。
一般过程为：runstats->reorg->runstats->rebind
2、runstats用法：
	db2 runstats ON TABLE <schema_name>.<table_name> ON ALL COLUMNS WITH DISTRIBUTION AND DETAILED INDEXES ALL
	抽样：
	db2 "runstats ON TABLE <schema_name>.<table_name> TABLESAMPLE BERNOULLI(10)"
	查看runstats执行情况
	db2 "select char(TABSCHEMA,20) as tabschema, char(tabname,30) as tabname, stats_time from syscat.tables where tabschema = db2inst"
3、	reorg知识
	1）离线reorg:影子拷贝，默认read access；四个阶段：扫描、排序->表构建->替换->重建索引
	2）在线reorg：不间断访问，默认write access;
	3）可以通过db2pd -d dbname -reorg查看正在执行和近期完成的reorg情况
	reorg用法：
	离线：db2 reorg table tbname [ index i1 ] allow read/no access
	在线：db2 reorg table tbname [ index i1 ] inplace allow write/read access
4、rebind知识
	嵌入式SQL当表的统计信息发生变化导致执行计划发生变化，建议通过rebind命令进行重绑定。
	1）db2 list packages for schema schema_name
	2）db2 rebind package pkg_name
	
--DB2 修改活动日志文件目录的步骤

	1. 连接数据库
	db2 connect to ecifdb
	2. 更新数据库参数 
	---- 当前日志路径: /home/ecifinst/ecifinst/NODE0000/SQL00001/SQLOGDIR/
	---- 新的日志路径: /ecifdb/log/
	db2 update db cfg using NEWLOGPATH /ecifdb/log
	3. 重启数据库，以使数据库参数生效
	db2 terminate
	db2 force applications all
	db2 deactivate db ecifdb
	db2 activate db ecifdb    -- 将消耗几分钟时间，因为这一步将会把原来的日志文件转移到新的路径下
	4. 检查新旧路径，以确认参数修改生效。如果生效，那么日志文件将出现在新的路径
	ls -lrt /home/ecifinst/ecifinst/NODE0000/SQL00001/SQLOGDIR/
	ls -lrt /ecifdb/log/NODE0000/
	
	
-- DB2表通过load命令后check约束问题
   1. 通过db2 load query tablename确认表是否为set integrity pending状态
   2. 使用set integrity for tablename,... immediate checked for exception in tablename use tablename_exp, in tablename1 use tablename1_exp 恢复
      （set integrity for tablename,... off 使表进入set integrity pending状态
	    set integrity for table all immediate unchecked 关闭所有字段上的check约束
		
-- load pending状态
   由于数据提交前load操作异常终止，表处于load pending状态，可通过load ... terminate; load ... restart 或load ... replace恢复
   load from /dev/null of del terminate into t1