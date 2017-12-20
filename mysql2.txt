insert into user (host,user,select_priv,insert_priv,update_priv,delete_priv,grant)

在安装软件后，会在/var/log/mysqld.log文件中产生一个临时密码，通过temporary password 可以找到，通过该密码登陆后，通过下面命令更新数据库密码
SET PASSWORD FOR 'root'@'%' = 'DRC@inst';



mysql -u root -p --connect-expired-password -e\"use mysql;select * from user\"

修改

错误：Package: mysql-workbench-community-6.3.8-1.el6.x86_64 (/mysql-workbench-community-6.3.8-1.el6.x86_64)
          Requires: libzip
错误：Package: mysql-workbench-community-6.3.8-1.el6.x86_64 (/mysql-workbench-community-6.3.8-1.el6.x86_64)
          Requires: proj
错误：Package: mysql-workbench-community-6.3.8-1.el6.x86_64 (/mysql-workbench-community-6.3.8-1.el6.x86_64)
          Requires: tinyxml


create database if not exists testdb character set utf8 default collate utf8_general_ci;

create tablespace tbs1 add datafile 'tbs1datafile.ibd' engine InnoDB;

CREATE TABLE mysql1_tb1 (c1 varchar(100)) TABLESPACE tbs1;

CREATE TABLE mysql1_tb1 (c1 char(1000),c2 char(1000))


读log文件，获取密码，更新密码

mysql主从数据库搭建
1、修改主从的my.cnf中的server-id，重启mysql
2、登陆主服务器新增主从复制用户
GRANT REPLICATION SLAVE ON *.* to 'mysync'@'%' identified by 'DRC1bank';
3、show master status;查看主服务器的日志位置Position，更新slave状态
4、配置从服务器并启动
change master to master_host='10.8.246.17',master_user='mysync',master_password='DRC1bank',master_log_file='mysql-bin.000004',master_log_pos=2553;
start slave；
5、检查从服务器复制状态
show slave status\G

检查Slave_IO_Running: Yes
    Slave_SQL_Running: Yes
	
备份mysql数据库
1）安装xtrabackup软件

2）新增用户用于备份
	CREATE USER 'bkpusr'@'localhost' IDENTIFIED BY 'DRC1bank';
	REVOKE ALL PRIVILEGES,GRANT OPTION FROM 'bkpusr';
	GRANT RELOAD,LOCK TABLES,PROCESS,SUPER,CREATE,INSERT,SELECT,REPLICATION CLIENT ON pmdb.* TO 'bkpusr'@'localhost';
	FLUSH PRIVILEGES;
3）创建完全备份（会在path_to_backup目录下生成一个以当前时间戳为名称的目录）
	innobackupex --defaults-file=/etc/my.cnf --user=bkpusr --password=DRC1bank /home/mysql/mybackup

恢复mysql数据库（使用mysql的root用户）
1）准备一个完全备份（即处理备份数据中未提交的事务或已经提交但未同步到数据文件的事务，确保数据文件的一致性状态）
	innobackupex --apply-log /path_to_backup
2）还原数据库及修改mysql库目录的权限,重启mysql
	innobackupex --force-non-empty-directories --copy-back /path_to_backup
	chown -R mysql:mysql /home/mysql/datatbs /home/mysql/log

mysql通过binlog日志前滚
1）在一次全备后，数据库恢复到全备状态后所有在备份后的操作将会丢失，可以通过使用bin-log日志将数据库前滚到目标状态
2）通过mysqlbinlog bin-log.000004命令确定前滚的位置(在文件里的 #at 1097234 或者时间戳格式 2017-09-05 11:11:11)
3）使用mysqlbinlog --stop-postion=6541578 /home/mysql/log/bin_log/bin-log.000004 >  /tmp/binlog4_restore.sql导出bin-log的sql操作，如果有多个可以通过全导出bin_log.000004,bin-log.000005,...,及bin-log.00000N的stop-postion的sql语句
可通过--start/stop-position及--start/stop-datetime获取生成的bin-log的sql操作
4）通过mysql -u root -p < /tmp/binlog4_restore.sql将生成的sql语句导入数据库中，如果有多个，则进行多次导入


comvalut备份mysql数据库
1）端口8400-8420,3306需要双向打开
2）用户权限
3）日志数据文件位置选择bin-log日志的位置

