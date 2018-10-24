# nfs挂载问题导致df命令HAND死
## 准备环境
模拟nfs服务端问题导致nfs客户端的进行hand死，具体表现为调用`df`命令或者涉及访问该目录的命令时界面会hang住，如果大量后台进行调用访问该目录会导致`uptime`下的负载检查，而实际所有的sar检查都没有发现任何性能问题。

为了重现环境，需要在准备一台服务器（既做客户端也做服务端）
### 安装nfs rpm包并启动服务
```console
[root@vultr ~]# yum install nfs-utils -y
[root@vultr ~]# systemctl start nfs
[root@vultr ~]# systemctl start rpcbind
```

### 创建nfs服务端共享目录
```console
[root@vultr ~]# mkdir /var/nfs
[root@vultr ~]# chmod 755 /var/nfs/
[root@vultr ~]# chown nfsnobody:nfsnobody /var/nfs/
```

### 将目录共享
修改/etc/exports配置文件，将新创建的共享目录写入文件，并以读写模式进行共享。
```console
[root@vultr nfs]# cat /etc/exports
/var/nfs	*(rw,sync)
[root@vultr ~]# exportfs -a
```

### 确认共享情况并挂载
```console
[root@vultr ~]# showmount -e 149.28.143.23
Export list for 149.28.143.23:
/var/nfs *
[root@vultr ~]# mount -t nfs 149.28.143.23:/var/nfs /mnt/nfs
[root@vultr ~]# df
Filesystem             1K-blocks    Used Available Use% Mounted on
/dev/vda1               25778760 2714472  21737248  12% /
devtmpfs                  496928       0    496928   0% /dev
149.28.143.23:/var/nfs  25778816 2714496  21737344  12% /mnt/nfs
```

所有环境都准完毕，目录已经挂载，下一步进行nfs服务端的停止操作

## 实验
将nfs server进程停止，模拟NFS服务端故障导致客户端挂起，此时`df`命令无法正常运行。
```console
[root@vultr nfs]# systemctl stop nfs
[root@vultr nfs]# df

```
使用`strace df`进行分析发现`df`命令在系统调用尝试获取目录/var/nfs的stat信息时挂起，如下：

<img src='../pics/df_hand_trace.png'>

## 结论