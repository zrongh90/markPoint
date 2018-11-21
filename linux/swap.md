# SWAP

## 查看swap占用情况

可通过/proc/进程PID/smaps文件内的Swap信息统计出每个进程的swap占用情况

```console
[root@vultr 2570]# readlink -f smaps
/proc/2570/smaps
[root@vultr 2570]# cat smaps
6447cd02000-56447cd0f000 r-xp 00000000 fd:01 26482                      /usr/sbin/rpcbind
Size:                 52 kB
Rss:                   0 kB
Pss:                   0 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:            0 kB
Anonymous:             0 kB
AnonHugePages:         0 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
VmFlags: rd ex mr mw me dw sd
56447cf0f000-56447cf10000 r--p 0000d000 fd:01 26482                      /usr/sbin/rpcbind
```

可以通过以下脚本获取进程对应的swap情况

```shell
#!/bin/bash
function get_swap(){
    CURRENT_PWD=$(pwd)
    cd /proc
    # 通过使用Perl的正则表达式获取以0-9数字开头的文件夹信息
    pids=$(ls /proc | grep -P '^[0-9]')
    total_swap=0
    for pid in $pids;do
        # 进程使用的swap信息记录在smaps文件中
        pid_smaps=$(readlink -f $pid)'/smaps'
        # 可通过awk对ps的结果进行处理获取从11列后的结果合并到command中
        # pid_command=$(ps --no-headers -up $pid | awk '{for(i=1;i<=10;i++){$i=""};print $0}')
        # 通过指定-o可以快速得到进程的command信息
        pid_command=$(ps --no-headers -o command -p $pid)
        let pid_swap_total=0
        for proc_swaps in $(grep 'Swap' $pid_smaps 2>/dev/null | awk '{print $2}');do
            pid_swap_total=$((pid_swap_total+proc_swaps))
        done
        if [[ $pid_swap_total > 0 ]];then
            total_swap=$((total_swap+pid_swap_total))
            echo -e "${pid}\t${pid_swap_total}KB\t${pid_command}"
        fi
    # 对得到的结果进行排序
    done | sort -nrk2
    cd $CURRENT_PWD
}
get_swap
exit 0
```

脚本执行结果如下：

```console
[root@zrongh tmp]# sh get_swap.sh
1271    71224KB /usr/libexec/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --log-error=/var/log/mariadb/mariadb.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/lib/mysql/mysql.sock
1007    10496KB /usr/bin/python -Es /usr/sbin/tuned -l -P
1098    4684KB  docker-containerd --config /var/run/docker/containerd/containerd.toml
...
```

## 释放swap

- sync

Force changed blocks to disk, update the super block.
将数据先同步到硬盘中，防止后续回收导致数据丢失。

- echo 3 > /proc/sys/vm/drop_caches

drop_caches共有三种值：1：清理pagecache；2：清理dentries和缓冲inodes；3：清除前两种.

需要注意的是，这个方法不会对dirty对象的强制回收，使用`sync`作为前置命令是为了更好地提高回收效果。这只是针对buff/cache中的内存，如果物理内存确实不足，回收也不会有很好的效果。

内核说明文档如下，

        Writing to this will cause the kernel to drop clean caches, as well as
        reclaimable slab objects like dentries and inodes.  Once dropped, their
        memory becomes free.

        To free pagecache:
            echo 1 > /proc/sys/vm/drop_caches
        To free reclaimable slab objects (includes dentries and inodes):
            echo 2 > /proc/sys/vm/drop_caches
        To free slab objects and pagecache:
            echo 3 > /proc/sys/vm/drop_caches

        This is a non-destructive operation and will not free any dirty objects.
        To increase the number of objects freed by this operation, the user may run
        `sync' prior to writing to /proc/sys/vm/drop_caches.  This will minimize the
        number of dirty objects on the system and create more candidates to be dropped.

```console
Swap:        839676      138676      701000
[root@zrongh tmp]# free
              total        used        free      shared  buff/cache   available
Mem:         499288       31272      392640         216       75376      428948
Swap:        839676      138676      701000
[root@zrongh tmp]# sync
[root@zrongh tmp]# free
              total        used        free      shared  buff/cache   available
Mem:         499288       31352      392496         216       75440      428804
Swap:        839676      138676      701000
[root@zrongh tmp]# echo 3 > /proc/sys/vm/drop_caches
[root@zrongh tmp]# free
              total        used        free      shared  buff/cache   available
Mem:         499288       47484      383476         284       68328      412588
Swap:        839676      136884      702792
```

- 关闭所有swap设备或文件

swapoff -a

```console
[root@zrongh ~]# swapoff -a
[root@zrongh ~]# free
              total        used        free      shared  buff/cache   available
Mem:         499288       99472      314552        7188       85264      353468
Swap:         66864       66864           0
[root@zrongh ~]# free
              total        used        free      shared  buff/cache   available
Mem:         499288      158092      250632        8752       90564      293344
Swap:             0           0           0
```

- 打开所有swap设备或文件

swapon -a

```console
[root@zrongh ~]# swapon -a
[root@zrongh ~]# free
              total        used        free      shared  buff/cache   available
Mem:         499288      158112      249680        8752       91496      293308
Swap:        839676           0      839676
```