以mysql中的root用户连接mysql数据库
mysql [-h ip_addr] -u root -p密码

list db directory			show databases
connect to db_name			use db_name
list table for schema *** 	show tables

数据库启动和关闭
mysqladmin shutdown -u root -p 	db2stop
mysqld_safe &	db2start

mysql日志 /var/log/mysqld.log

mysql主从数据库搭建
1、修改主从的my.cnf中的server-id，重启mysql
2、登陆主服务器新增主从复制用户
GRANT REPLICATION SLAVE ON *.* to 'mysync'@'%' identified by 'DRC1bank';
3、show master status;查看主服务器的日志位置Position，更新slave状态
4、配置从服务器并启动
change master to master_host='10.8.246.17',master_user='mysync',master_password='DRC1bank',master_log_file='mysql-bin.000025',master_log_pos=5854594;
start slave；
5、检查从服务器复制状态
show slave status\G

查看用户权限
show grants for username;

可以通过show variables查看数据库中的所有参数，也可以通过查询information_schema库下的GLOBAL_VARIABLES视图来查询；
可以通过show status查看mysql服务器的状态信息

mysql启停方式
启动：mysqld_safe &
停止：mysqladmin shutdown -u root -p

授予用户在所有主机连接(%)所有库所有表(*.*)权限,如果允许本地(localhost)
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%'

查看mysql binlog的状态
mysql> show variables like 'binlog_cache_size';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| binlog_cache_size | 32768 |
+-------------------+-------+
mysql> show global status like '%binlog_cache%';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| Binlog_cache_disk_use | 0     |
| Binlog_cache_use      | 0     |
+-----------------------+-------+
Binlog_cache_disk_use:表示binlog_cache_size设置不足导致binlog cache使用到临时文件的次数。

查看innodb日志刷新频率
mysql> show variables like 'innodb_flush_log_at_trx_commit';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 2     |
+--------------------------------+-------+
innodb_flush_log_at_trx_commit参数可选为0,1,2；
0：log buffer每秒将日志buffer写入日志文件并刷新到磁盘一次；
1：每次事务提交将log buffer的数据写入log file，并且flush到磁盘；
2：每次事务提交时mysql会把log buffer的数据写入log file，但是每秒执行一次flush操作。

查看binlog日志刷新频率
mysql> show variables like 'sync_binlog';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| sync_binlog   | 1     |
+---------------+-------+
0：mysql不做磁盘同步操作，让文件系统做同步；
n：每进行n次事务提交后，mysql进行一次sync磁盘同步。

通过系统状态确定缓冲池命中率
命中率= 缓冲池读 / (缓冲池读 + 预读 + 磁盘读)
mysql> show status like '%inno%read%';
+---------------------------------------+---------+
| Variable_name                         | Value   |
+---------------------------------------+---------+
| Innodb_buffer_pool_read_ahead_rnd     | 0       |
| Innodb_buffer_pool_read_ahead(预读)   | 0       |
| Innodb_buffer_pool_read_ahead_evicted | 0       |
| Innodb_buffer_pool_read_requests(缓冲池读)| 1455    |
| Innodb_buffer_pool_reads(磁盘读)      | 235     |
| Innodb_data_pending_reads             | 0       |
| Innodb_data_read(读入字节)            | 3920384 |
| Innodb_data_reads（读取次数）         | 268     |
| Innodb_pages_read                     | 234     |
| Innodb_rows_read                      | 8       |
+---------------------------------------+---------+

锁方面可以关注information_schema下的三张表：INNODB_TRX（事务信息）、INNODB_LOCKS（锁信息）及INNODB_LOCK_WAITS（事务锁等待信息）。

select r.trx_id waiting_trx_id,r.trx_mysql_thread_id waiting_thread,r.trx_query waiting_query,b.trx_id blocking_trx_id,b.trx_mysql_thread_id blocking_thread,b.trx_query blocking_query FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id\G;

在忘记mysql密码情况下修改密码
mysqld_safe --skip-grant-tables &;
update mysql.user set authentication_string=PASSWORD("root1234") where user='root';
flush privileges;

mysql bin_log清理策略（注意清理binlog时，对从mysql的影响，不能清除未同步到从服务器的日志）
1）关闭mysql主从，关闭binlog(注释my.cnf中的log-bin配置)，重启数据库
2）设置my.cnf中的expire_logs_day（触发条件为：1、重启；2、binlog文件大小达到max_binlog_size限制；3、手工执行flush log命令）
3）手动清除（purge master logs to 'mysql-bin.00005'或purge master logs before '2017-06-01 13:00:00'） 

mysql通过配置my.cnf的secure_file_priv控制数据导出导入
1)限制mysql不允许导出导入
secure_file_priv=null
2)限制mysql导出导入在指定目录
secure_file_priv=/tmp/
3)不限制导出导入
secure_file_priv=
