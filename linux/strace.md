# strace
strace常用来跟踪进程执行时的系统调用和所接收的信号。

打开进程的的黑盒，通过跟踪系统调用的线索，大致判断进程在做什么。

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

## 组合用法
- -c -p pid 可以跟踪进程的大部分系统调用的时间统计情况。
```console
[root@vultr ~]# strace -c -p 16321
strace: Process 16321 attached
^Cstrace: Process 16321 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 62.71    0.000037           4        10           poll
 23.73    0.000014          14         1           restart_syscall
 13.56    0.000008           1        11           wait4
------ ----------- ----------- --------- --------- ----------------
100.00    0.000059                    22           total
```

## 例子
### 分析进程异常退出原因

假设有一个一直在运行的进程run.sh，运行一段时间后自动死掉，没有明确的错误信息输出。

思路： 可以通过`strace -o run.strace -p run.sh的pid` 定位程序运行过程中的系统调用信息。
```console
[root@vultr ~]# ps -ef | grep run
root     16126 15769  0 12:11 pts/1    00:00:00 /bin/bash ./run.sh
[root@vultr ~]# strace -o run.strace -p 16126
strace: Process 16126 attached
[root@vultr ~]# ls
run.sh  run.trace  super.strace
[root@vultr ~]# view run.trace
...
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
rt_sigaction(SIGINT, {0x43e800, [], SA_RESTORER, 0x7f3fa6cea2f0}, {SIG_DFL, [], SA_RESTORER, 0x7f3fa6cea2f0}, 8) = 0
wait4(-1,  <unfinished ...>
+++ killed by SIGKILL +++
```
从strace的结果观察，进程run.sh是被信号KILL给中止的，可以发掘是什么程序产生kill信号中断该进程。

正常情况下，应用退出是通过调用exit_group(exit_code)退出。
```console
write(1, "sleep\n", 6)                  = 6
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  = 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  = 0
read(255, "", 88)                       = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```
