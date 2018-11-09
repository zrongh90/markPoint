# supervisor
## 安装supervisor


## 初始化supervisor配置
echo_supervisord_conf > /tmp/supervisord.conf

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
配置一个任务涉及以下参数：
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

例如配置一个最简单的任务：
    
test任务,执行一个cat命令;
test2任务，执行一个ls命令
```ini
[program:test]
command=/bin/cat
[program:test2]
command=/usr/bin/ls
```
```console
[root@vultr etc]# supervisorctl status
test                             RUNNING   pid 10169, uptime 0:00:11
test2                            FATAL     Exited too quickly (process log may have details)
```

supervisorctl status