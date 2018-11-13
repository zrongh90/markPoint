# strace
strace常用来跟踪进程执行时的系统调用和所接收的信号。

每一行都是一条系统调用，等号左边是系统调用的函数名及其参数，右边是该调用的返回值。
- -o file 将标准错误输出的内容写入file中
```console
[root@vultr ~]# strace -o ls.trace ls 
[root@vultr ~]# view ls.trace
execve("/usr/bin/ls", ["ls"], [/* 24 vars */]) = 0
brk(NULL)                               = 0x1d7f000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd54ff5a000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
...
```
- -c 统计时间、syscall数目、错误调用数目、syscall名称
```console
[root@vultr ~]# strace -c ls
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 28.53    0.000200           8        26           mmap
 24.68    0.000173          10        18           mprotect
 13.69    0.000096          10        10           open
  5.85    0.000041           5         8           read
...
------ ----------- ----------- --------- --------- ----------------
100.00    0.000551                   107         1 total
```
- -tt 给出系统调用的时间戳
```console
[root@vultr ~]# strace -tt -o ls.trace.tt ls 
[root@vultr ~]# view ls.trace.tt
13:15:54.484389 execve("/usr/bin/ls", ["ls"], [/* 24 vars */]) = 0
13:15:54.485094 brk(NULL)               = 0x1b32000
13:15:54.485215 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdb8d36e000
13:15:54.485325 access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
13:15:54.485440 open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
...
```
- -r 给出syscall的相对时间
```console
[root@vultr ~]# strace -r ls
     0.000000 execve("/usr/bin/ls", ["ls"], [/* 24 vars */]) = 0
     0.000440 brk(NULL)                 = 0x1ecf000
     0.000233 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f64a54ba000
     0.000243 access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
     0.000199 open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
```
- -p pid 跟踪进程号的系统调用情况
```console
[root@vultr ~]# strace -p 674
strace: Process 674 attached
select(12, [3 4], NULL, NULL, NULL
)     = 1 (in [3])
accept(3, {sa_family=AF_INET, sin_port=htons(4631), sin_addr=inet_addr("210.83.240.178")}, [16]) = 5
fcntl(5, F_GETFL)                       = 0x2 (flags O_RDWR)
pipe([6, 7])                            = 0
socketpair(AF_LOCAL, SOCK_STREAM, 0, [8, 9]) = 0
clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7f8450a4bb90) = 9952
close(7)                                = 0
write(8, "\0\0\2\276\0", 5)             = 5
...
```






