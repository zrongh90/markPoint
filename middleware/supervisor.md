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


supervisorctl status