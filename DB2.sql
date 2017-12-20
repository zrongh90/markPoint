--�����¹淶
db2 CREATE DATABASE esbdb on /home/esbinst/datatbs DBPATH ON /home/esbinst USING CODESET UTF-8 TERRITORY CN;

--�г����б�
db2 list db directory  

--�г����ݿ����Ϣ����ǰ��Ч��δ��Ч��Ϣ����Ҫ��connect���ݿ⣩
db2 get db cfg show detail

--�鿴ʵ���û��µ����ݿ��
db2 list tables for schema <schema_name>

--db2 descirbe �﷨
db2 descirbe table instanceName.tablename 

--�鿴���ݿ��¶�Ӧ�ı�ռ����Ϣ
db2 "select tbsp_id as TABLESPACE_ID, substr(tbsp_name,1,30) as TABLESPACE_NAME, substr(TBSP_TYPE,1,10) as TBSP_TYPE, substr(tbsp_content_type,1,10) as TABLESPACE_TYPE, sum(tbsp_total_size_kb)/1024 as TOTAL_MB, sum(tbsp_used_size_kb)/1024 as USED_MB, sum(tbsp_free_size_kb)/1024 as FREE_MB, tbsp_page_size AS PAGE_SIZE from SYSIBMADM.TBSP_UTILIZATION group by tbsp_id,tbsp_name, tbsp_type, tbsp_content_type, tbsp_page_size order by 1"   

--�鿴���ݿ���ָ���ı�ռ��ID
db2 "select tbsp_id as TABLESPACE_ID, substr(tbsp_name,1,30) as TABLESPACE_NAME, substr(TBSP_TYPE,1,10) as TBSP_TYPE, substr(tbsp_content_type,1,10) as TABLESPACE_TYPE, sum(tbsp_total_size_kb)/1024 as TOTAL_MB, sum(tbsp_used_size_kb)/1024 as USED_MB, sum(tbsp_free_size_kb)/1024 as FREE_MB, tbsp_page_size AS PAGE_SIZE from SYSIBMADM.TBSP_UTILIZATION group by tbsp_id,tbsp_name, tbsp_type, tbsp_content_type, tbsp_page_size order by 1" | grep DATAESTBS32K | awk '{print $1}'  

--�鿴ָ���ı�ռ�ID������
db2 list tablespace container for <tablespace_id>

--db2look����һ�ű�
db2look -d cdfsdb -tw cln_cuptxn -e -o /home/cardfrs/cln_cuptxn.ddl

--export ����
EXPORT TO filename OF {IXF | DEL | WSF}  
[LOBS TO lob-path [ {,lob-path} ... ] ]
[LOBFILE lob-file [ {,lob-file} ... ] ]
[MODIFIED BY {filetype-mod ...}]
[MESSAGES message-file]
{select-statement [WHERE ...] }

modified by �ı����η����ƣ�CHARDELxָ���ַ����������COLDELxָ���ֶζ����

--import ����
IMPORT from <filename> OF {IXF | DEL | WSF}
[MODIFIED BY {filetype-mod ...}]
[MESSAGES message-file]
<action> INTO <table_name>

action����insert��׷�ӣ���insert_update��replace������ɾ����Ȼ����룬ע�����ݵı��ݣ�

--load ����
LOAD FROM <input_source> OF <input_type>
 MODIFIED BY DUMPFILE=</tmp/target.dump>
  MESSAGES <message_file>
   [INSERT | REPLACE | TERMINATE | RESTART ]
	 INTO <target_tablename>
	   FOR EXCEPTION <target_exp> (copy no: ����ռ�����backup pending״̬; copy yes: �Զ��Ա�������ռ䱸�ݣ�nonrecoverable ��Ǳ��ɻָ���������Ҫ���ݱ�ռ�)
֧��4�ֶ�����insert��repalce��terminate��restart

--���߱���(��־�ǹ鵵ģʽ��
backup db <db> online [to <path>] compress [include logs]
backup db <db> tablespace (<tbs1>[, <tbs2>]) online [to <path>]
db2 backup db CNAPSDB online to /home/uppinst1/tbspace/backup compress include logs without prompting

--���߱��ݣ���Ҫȷ��Ӧ��û���������ݿ⣩
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

--�鿴�Ƿ����ڹ鵵��־ģʽ
ͨ��db2 get db cfg for <db> | grep -i log �е�LOGARCHMETH1�����Ƿ����OFF��
1�������OFFʱ����ʾѭ����־ģʽ��
2�������OFF�������ֵʱ����ʾ�鵵ģʽ��

--db2�������豸�ı�ռ�
db2pd -d db_name -tablespace #�鿴��ռ���Ϣ��ȷ�ϱ�ռ�ʹ�õ����豸

Database Partition 0 -- Database PCRMDB -- Active -- Up 3 days 14:50:25 -- Date 2017-07-29-17.15.23.732792
Tablespace Configuration:
Address            Id    Type Content PageSz ExtentSz Auto Prefetch BufID BufIDDisk FSC NumCntrs MaxStripe  LastConsecPg Name
0x07700001DAF2D000 4     DMS  Large   32768  32       No   32       3     3         Off 1        0          31           SPDTBS32K
Containers:
Address            TspId ContainNum Type    TotalPgs   UseablePgs PathID     StripeSet  Container 
0x07700007514DA3A0 4     0          Disk    13107200   13107168   -          0          /dev/rSPDTBS32K1

smit hacmp�������豸��Ӧ��LV��С
db2 "alter tablespace ��ռ��� resize(device '/dev/rdeivcename' 20G,device '/dev/rdeivcename' 20G)"

--���ñ�ռ�����
for tbs in ESSC5DBSPACE ESSC5DB_INDEX
do
db2 ALTER TABLESPACE $tbs AUTORESIZE YES INCREASESIZE 5G MAXSIZE NONE;
done

--�鿴��־ռ�ÿռ�(log space used)
db2 get snapshot for all on dbname | grep -i log

--db2�ڱ�ռ�����Ϊregular��״̬�£���ռ����֧��256G���������������ƣ���ռ�������ʧ�ܣ���Ҫͨ����������Ա�ռ����ͽ���ת����
db2 alter tablespace *** convert to large


--���ݿ��л���������ݿ�����������ռ��޷����ӣ�Ȩ�޴���ע���ļ�ϵͳ�µ����豸Ȩ�ޡ�
1��ֹͣ���ݿ�
2��lsvg -l datavg�鿴���豸״̬���Ƿ�Ϊclosed
3��������豸Ȩ�޲��ԣ���Ҫ�޸ĸ����豸��Ȩ��
4���������ݿ�

--db2����ע��svce_name����ʹ��db2�Զ����ɵ�60000��60005�Ķ˿ڣ�����ѡ��һ����λ�˿�ʹ��
cat /etc/services
svce_db2inst	60040/tcp

db2 update dbm cfg using SVCENAME svce_db2inst

--���ݿ�runstat��reorg��rebind����
1��runstats(��Ե���ִ��)�ռ�ͳ����Ϣ��ΪDB2�Ż����ṩ���·��ѡ��reorg��������ٱ������������洢����Ƭ��rebind�԰����洢���̻�̬����������°󶨡�
һ�����Ϊ��runstats->reorg->runstats->rebind
2��runstats�÷���
	db2 runstats ON TABLE <schema_name>.<table_name> ON ALL COLUMNS WITH DISTRIBUTION AND DETAILED INDEXES ALL
	������
	db2 "runstats ON TABLE <schema_name>.<table_name> TABLESAMPLE BERNOULLI(10)"
	�鿴runstatsִ�����
	db2 "select char(TABSCHEMA,20) as tabschema, char(tabname,30) as tabname, stats_time from syscat.tables where tabschema = db2inst"
3��	reorg֪ʶ
	1������reorg:Ӱ�ӿ�����Ĭ��read access���ĸ��׶Σ�ɨ�衢����->����->�滻->�ؽ�����
	2������reorg������Ϸ��ʣ�Ĭ��write access;
	3������ͨ��db2pd -d dbname -reorg�鿴����ִ�кͽ�����ɵ�reorg���
	reorg�÷���
	���ߣ�db2 reorg table tbname [ index i1 ] allow read/no access
	���ߣ�db2 reorg table tbname [ index i1 ] inplace allow write/read access
4��rebind֪ʶ
	Ƕ��ʽSQL�����ͳ����Ϣ�����仯����ִ�мƻ������仯������ͨ��rebind��������ذ󶨡�
	1��db2 list packages for schema schema_name
	2��db2 rebind package pkg_name
	
--DB2 �޸Ļ��־�ļ�Ŀ¼�Ĳ���

	1. �������ݿ�
	db2 connect to ecifdb
	2. �������ݿ���� 
	---- ��ǰ��־·��: /home/ecifinst/ecifinst/NODE0000/SQL00001/SQLOGDIR/
	---- �µ���־·��: /ecifdb/log/
	db2 update db cfg using NEWLOGPATH /ecifdb/log
	3. �������ݿ⣬��ʹ���ݿ������Ч
	db2 terminate
	db2 force applications all
	db2 deactivate db ecifdb
	db2 activate db ecifdb    -- �����ļ�����ʱ�䣬��Ϊ��һ�������ԭ������־�ļ�ת�Ƶ��µ�·����
	4. ����¾�·������ȷ�ϲ����޸���Ч�������Ч����ô��־�ļ����������µ�·��
	ls -lrt /home/ecifinst/ecifinst/NODE0000/SQL00001/SQLOGDIR/
	ls -lrt /ecifdb/log/NODE0000/
	
	
-- DB2��ͨ��load�����checkԼ������
   1. ͨ��db2 load query tablenameȷ�ϱ��Ƿ�Ϊset integrity pending״̬
   2. ʹ��set integrity for tablename,... immediate checked for exception in tablename use tablename_exp, in tablename1 use tablename1_exp �ָ�
      ��set integrity for tablename,... off ʹ�����set integrity pending״̬
	    set integrity for table all immediate unchecked �ر������ֶ��ϵ�checkԼ��
		
-- load pending״̬
   ���������ύǰload�����쳣��ֹ������load pending״̬����ͨ��load ... terminate; load ... restart ��load ... replace�ָ�
   load from /dev/null of del terminate into t1