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

## 释放swap

- sync

- swapoff -a

- swapon -a