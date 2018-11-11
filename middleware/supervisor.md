# supervisor
## 安装supervisor


## 初始化supervisor配置
通过echo_supervisord_conf命令可以
echo_supervisord_conf > /tmp/supervisord.conf

supervisord进程涉及以下配置
```ini
[supervisord]
logfile=/tmp/supervisord.log ; main log file; default $CWD/supervisord.log
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
pidfile=/tmp/supervisord.pid ; supervisord pidfile; default supervisord.pid
nodaemon=false               ; start in foreground if true; default false
minfds=1024                  ; min. avail startup file descriptors; default 1024
minprocs=200                 ; min. avail process descriptors;default 200
```

## 启动supervisor
supervisord以默认搜索路径启动supervisor,从以下目录中顺序查找
    
    /usr/etc/supervisord.conf
    /usr/supervisord.conf
    supervisord.conf
    etc/supervisord.conf
    /etc/supervisord.conf
    /etc/supervisor/supervisord.conf

strace信息如下：
```console
4500 stat("/usr/etc/supervisord.conf", 0x7ffd94152b40) = -1 ENOENT (No such file or directory)
4501 stat("/usr/supervisord.conf", 0x7ffd94152b40) = -1 ENOENT (No such file or directory)
4502 stat("supervisord.conf", 0x7ffd94152b40) = -1 ENOENT (No such file or directory)
4503 stat("etc/supervisord.conf", 0x7ffd94152b40) = -1 ENOENT (No such file or directory)
4504 stat("/etc/supervisord.conf", 0x7ffd94152b40) = -1 ENOENT (No such file or directory)
4505 stat("/etc/supervisor/supervisord.conf", {st_mode=S_IFREG|0644, st_size=9197, ...}) = 0
```
## 配置supervisor任务
配置一个program涉及以下参数：

- command：必须，program需要为nodaemon，即前台任务
- directory：任务的根目录
- priority：任务优先级，无法通过其控制program启动顺序

    数字越少，优先级越高；在start all时先启动，在stop all时先停止
```ini
[program:test]
command=/bin/cat
priority=10

[program:test2]
command=/usr/bin/read
priority=100

[program:test3]
command=/usr/bin/read
priority=1
```
```console
[root@vultr tmp]# supervisorctl start all
test3: started
test: started
test2: started
[root@vultr tmp]# supervisorctl status
test                             RUNNING   pid 22289, uptime 0:00:05
test2                            RUNNING   pid 22290, uptime 0:00:05
test3                            RUNNING   pid 22288, uptime 0:00:05
[root@vultr tmp]# supervisorctl stop all
test3: stopped
test: stopped
test2: stopped
```
- 日志信息
    
    日志包含标准输出日志和标准错误输出日志，常用参数主要有：

        stdout/stderr_logfile（位置，默认应该是/tmp目录）
        stdout/stderr_logfile_maxbytes（大小）
        stdout/stderr_logfile_backups（数目）

stdout日志信息：
```ini
stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
```
stderr日志信息：
```ini
stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
```

具体涉及单个program的配置参考如下：
```ini
[program:theprogramname]
command=/bin/cat              ; the program (relative uses PATH, can take args)
process_name=%(program_name)s ; process_name expr (default %(program_name)s)
numprocs=1                    ; number of processes copies to start (def 1)
directory=/tmp                ; directory to cwd to before exec (def no cwd)
umask=022                     ; umask for process (default None)
priority=999                  ; the relative start priority (default 999)
autostart=true                ; start at supervisord start (default: true)
startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
startretries=3                ; max # of serial start failures when starting (default 3)
autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
stopsignal=QUIT               ; signal used to kill process (default TERM)
stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
stopasgroup=false             ; send stop signal to the UNIX process group (default false)
killasgroup=false             ; SIGKILL the UNIX process group (def false)
user=chrism                   ; setuid to this UNIX account to run the program
redirect_stderr=true          ; redirect proc stderr to stdout (default false)
stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
```

例如配置一个最简单的任务，只需要提供programname及command信息即可，其他信息使用默认值：
    
test任务,执行一个cat命令

test2任务，执行一个ls命令
```ini
[program:test]
command=/bin/cat
[program:test2]
command=/usr/bin/ls
```

## 任务管理
supervisorctl支持以下命令
```console
[root@vultr tmp]# supervisorctl help

default commands (type help <topic>):
=====================================
add    exit      open  reload  restart   start   tail   
avail  fg        pid   remove  shutdown  status  update 
clear  maintail  quit  reread  signal    stop    version
```

### 查看任务状态

supervisorctl status

```console
[root@vultr etc]# supervisorctl status
test                             RUNNING   pid 10169, uptime 0:00:11
test2                            FATAL     Exited too quickly (process log may have details)
```

### 更新任务
修改supervisord.conf配置，将test2任务删除
```ini
[program:test]
command=/bin/cat

;[program:test2]
;command=/usr/bin/ls
```
可通过`supervisor update`更新项目信息，如下：
```console
[root@vultr tmp]# supervisorctl update
test2: stopped
test2: removed process group
[root@vultr tmp]# 
```


### 启停任务
`supervisor start/stop programname` 可以控制项目的启停。
```console
[root@vultr tmp]# supervisorctl status
test                             STOPPED   Nov 11 01:26 AM
[root@vultr tmp]# supervisorctl start test
test: started
[root@vultr tmp]# supervisorctl status test
test                             RUNNING   pid 21390, uptime 0:00:06
[root@vultr tmp]# supervisorctl stop test
test: stopped
[root@vultr tmp]# supervisorctl status test
test                             STOPPED   Nov 11 01:27 AM
```