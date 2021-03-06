# LIUNX常用知识

## 常用初始化内容

- 安装man-pages，lsof，psmisc(killall、pstree、fuser)

- 安装net-tools

    提供netstat、route、ifconfig等centos 6常用命令，在centos 7被ip的命令替代。

        netstat  —— ss
        route    —— ip route
        ifconfig —— ip addr
- 安装cheat(提供命令速查)

    需要安装yum install python-pip然后pip install cheat


1、`whatis`快速查出命令的用途

`whereis` 快速定位命令的位置

2、`basename` - strip directory and suffix from filenames
`dirname` - strip non-directory suffix from file name

3、linux下可以尝试用`vdir`命令提供ls -l

4、不推荐使用`sh scriptname`来执行脚本，因为这禁用了脚本从stdin中读取数据的功能

5、'STRING'将会阻止STRING中所有特殊字符的解释

6、在括号中的命令列表，作为一个子shell运行。
    例如

```shell
    a=123
    ( a=321; )
    echo "$a" #结果为123
```

7、数组初始化方式

```shell
    Array=(element1 element2 element3)
```

8、使用`a=$(echo test)`机制来进行变量赋值(这是一种比后置引用(反引号``a=`echo test` ``)更新的一种方法).

9、Bash变量不区分类型，关键因素是变量值是否只有数字

10、查看端口占用可以使用`lsof -i :80`（查看80端口是否被占用）

11、`du -s * | sort -k1nr` :作用是排序当前目录下的目录占用空间大小
    (k1:指定第一个区域，n以数字排序，r反向排序)

12、`fuser`命令非常的有用. 某些情况下, 也就是当你umount一个设备失败的时候, 会出现设备忙错误消息. 这意味着某些用户或进程正在访问这个设备. 可以使用fuser -um /dev/device_name来解决这种问题, 这样你就可以kill所有相关的进程.

13、${}替换规则：

    ${var#*/}:删除第一个/前的所有字符

    ${var##*/}:删除最后一个/前的所有字符

    ${var%/*}:删除最后一个/右边的字符

    ${var%%/*}}:删除第一个/右边的字符

    ${var-defaultVar}:测试$var是否为空，为空则返回defaultVar

    ${var=defaultVar}:测试$var是否为空，为空则设值后返回

14、在`tar`的过程中，可以通过添加--remove-files参数删除打包前的源文件

    tar -zcvf destFile.tar.gz sourceFiles --remove-files

15、文件信息

    etc —— 配置文件

    skel —— home目录建立，该目录初始化

    sysconfig —— 网络，时间，键盘配置目录

    opt —— 额外安装软件的目录

16、mount iso

1. linux

```console
mount -o loop /home/zrongh/test.iso /mnt
```

2. AIX

```console
loopmount -i test.iso -o "-V cdrfs -o ro" -m /mnt
```

17、vim多行注释

	在命令行ctrl+v,使用j或k选中多行，键入大写字母I，在插入注释符#后,esc退出
	vim取消多行注释：在命令行ctrl+v，通过x删除字符
	
18、遇到文件含有特殊字符的处理方法
1. 通过`ls -il`获取inode信息
```console
ls -il | cat -v
[tmpusr@ansible ~]$ ls -il
total 188
13736 drwxr-xr-x  6 root   root       88 Mar 13 11:42 ansible-aix-playbooks
185 -rw-r--r--  1 tmpusr tmpusr   4573 Jun  2  2016 ansible.hosts
50331821 drwxrwxr-x 14 tmpusr tmpusr   4096 Mar 24 09:42 ansible-playbooks
```

2. 通过第二步确定的inode(ls -il 的第一列的数字）的信息，使用以下命令进行删除
```shell
find . -inum XXX -exec rm {} \;
```

19、扩大swap分歧
```shell
swapoff -a	#关闭所有swap分区，把swap内容交换出去
lvextend -L 16G /dev/rootvg/swap  #LVM扩大 
mkswap /dev/rootvg/swap           #定义lv为swap分区
swapon -a                         #打开swap 
```

20、用户增加sudo权限（推荐在/etc/sudoers.d中增加一个文件）

	<授权用户> <主机列表>=<runas用户> <参数（例如NOPASSWD)> <命令>
	例如 tmpusr ALL=(ALL) /usr/bin/sysdumpdev   #运行tmpusr用户以任意用户执行sysdumpdev

21、使用`iperf`测试网络速度
1. 在两台主机安装iperf的rpm包
2. 服务端

	iperf -s

	客户端
	
	iperf -c X.X.X.X -t 60 -i 1
		
		-s指定启动服务器程序；
		-c指定服务端IP；
		-t指定时间间隔；
		-i指定结果返回时间；
		-u测试UDP模式

22、进程问题分析思路
1. ps aux 查看系统进程的状态（STAT）

		S睡眠
		R运行
		D不可中断睡眠，等待输入或输出完成
		T停止
		Z僵尸进程
2. 查看/proc/pid***/stack（栈）和/proc/pid***/fd（文件描述符）、lsof -p pid***、/var/log/dmesg或messages看系统日志

23、`top`中进程的信息

    VIRT：进程使用的虚拟内存总量
    RES：进程在使用的、未被换出的物理内存大小
    SHR：共享内存的大小
    使用指南：
    1）数字键1：每个逻辑CPU状态
    2）键盘b：高亮状态
    3）键盘x：进程排序（默认按照%CPU),可通过shift + <或>改变
    4）键盘c：切换显示命令行（是否全显示）
    5）键盘P：按照CPU使用率排序
    6）键盘M：按照内存使用率排序
    7）键盘f：添加或删除当前显示项
    8）键盘o：改变列显示的位置

24、用户管理

	`useradd`默认参数主要涉及/etc/login.defs和/etc/default/useradd。

默认的用户ID及组ID内容可以参考/usr/share/doc/setup-2.8.14/uidgid文件

	文件内容：
		NAME	UID	GID	HOME		SHELL	       PACKAGES
		root	0	0	/root		/bin/bash	    setup
		bin	    1	1	/bin		/sbin/nologin	setup
		daemon	2	2	/sbin		/sbin/nologin	setup

25、`lslogins`查看用户的登录信息，可以显示所有用户，也可以指定用户,定义输出内容

26、修改wheel组中的用户及/etc/pam.d/su可以控制哪些用户可以使用su命令，哪些用户可以不用密码授权进行su

	# Uncomment the following line to implicitly trust users in the "wheel" group.
	#auth		sufficient	pam_wheel.so trust use_uid
	# Uncomment the following line to require a user to be in the "wheel" group.
	#auth		required	pam_wheel.so use_uid

27、`repoquery --list package_name`可以列出软件包下包括的文件，yum provides "file_name" 可以列出文件属于repo库中的哪package

28、`lspci`查看PCI硬件信息

- lscpu查看CPU硬件信息；
- lsblk查看块设备信息；
- findmnt查看文件系统挂载信息

29、用户超时时间/etc/profile的TMOUT参数；

    密码及锁定策略/etc/pam.d/system-auth

    auth模块：身份识别
    auth        required      pam_tally2.so    onerr=fail deny=5 unlock_time=300 even_deny_root root_unlock_time=300

    password模块：密码策略
    password    requisite      pam_cracklib.so try_first_pass retry=5 minlen=8 dcredit=-1  lcredit=-1 enforce_for_root

    ssh是否允许root登录/etc/ssh/sshd_config中的PermitRootLogin no

30、切记~/.ssh/authorized_keys文件的权限会影响是否可以通过密钥连接，目标权限为0600

31、`sysctl`：可以修改正在运行中的linux系统接口，包括tcp/ip堆栈和虚拟内存系统的选项

    sysctl -a 列出当前生效的值
    sysctl -w kernel.hostname="test" 临时修改系统参数配置
    修改/etc/sysctl.conf文件 永久修改系统参数设置

32、tcpip的接受发送buffer

```console
sysctl -a

net.ipv4.tcp_rmem				/proc/sys/net/ipv4/tcp_rmem
net.ipv4.tcp_wmem				/proc/sys/net/ipv4/tcp_wmem
net.ipv4.tcp_mem				/proc/sys/net/ipv4/tcp_mem
```

33、通过`yum`环境确定需要安装的rpm包的依赖关系

1. yum deplist rpm_name     #查询rpm所需依赖包
2. yumdownloader rpm_name   #下载目标rpm包

```console
[tmpusr@ansible ~]$ yum deplist gcc-c++.x86_64 | grep provider | uniq | grep -v i686
provider: bash.x86_64 4.2.46-21.el7_3
provider: info.x86_64 5.1-4.el7
provider: binutils.x86_64 2.25.1-22.base.el7
provider: cpp.x86_64 4.8.5-11.el7
provider: glibc-devel.x86_64 2.17-157.el7_3.1
provider: glibc.x86_64 2.17-157.el7_3.1
provider: libgcc.x86_64 4.8.5-11.el7
provider: libgcc.x86_64 4.8.5-11.el7
provider: gmp.x86_64 1:6.0.0-12.el7_1
provider: libgomp.x86_64 4.8.5-11.el7
provider: libgomp.x86_64 4.8.5-11.el7
provider: glibc.x86_64 2.17-157.el7_3.1
provider: libmpc.x86_64 1.0.1-3.el7
provider: mpfr.x86_64 3.1.1-4.el7
provider: zlib.x86_64 1.2.7-17.el7
provider: glibc.x86_64 2.17-157.el7_3.1
```

34、/etc/security/limits.conf限制了用户的可使用资源，修改用户的打开文件资源限制。
1. 修改/etc/security/limits.conf的nofile
2. 打开文件限制设置值参考/proc/sys/fs/file-max
3. 用户的ulimit设置值不能大于limits.conf文件中的限制。
(例如root:ulimit -u为5000；tmpusr无法通过ulimit -u 5001)

35、进入单用户模式，在grub节修改kernel行，在末尾添加single

36、启动图形界面

1. AIX

    1. 执行/etc/rc.dt

2. linux

    1. 修改/etc/gdm/customer.conf：在[xdcmp]下增加Port=177和Enable=1 

    2. 修改root的.bash_profile添加export DISPLAY=X.X.X.X:0.0

    3. 重启runlevel 3和5（即init 3; init 5。注意重启runlevel对应用的影响）

37、iostat分析

38、vmstat分析

39、通过`uptime`分析系统负载,平均负载指特定时间间隔内运行队列中的平均进程数。

```console
$ uptime
09:22AM   up 251 days,  14:03,  3 users,  load average: 2.61, 1.99, 2.50
                                                        一      五   十五   分钟  
```

per cpu 活动进程<3    性能良好

per cpu 活动进程>5    性能问题

上述系统为8C，所有平均负载不大于3*8=24表明系统性能良好

40、使用`rsync`进行数据的同步，一般使用-auv参数。

1. 使用rsync SRC DEST，进行本地数据的拷贝
2. 使用rsync SRC [USER@]host:DEST 或 rsync [USER@]host:SRC DEST，进行远程数据的拷贝

        -a: 等于-rlptgoD，-r递归,-l保留软链接,-p保留文件权限,-t保留时间信息,-g保留组信息,-o保留用户信息,-D保留设备文件信息

       -u, --update：仅仅更新数据

       -v, --verbose：详细模式

       --exclude=PATTERN：排除模式,例如--exclude="test.log"

       --exclude-from=FILE：排除文件中指定模式，例如--exclude-from="/home/tmpusr/ex.pattern"

lsof常用方法

- lsof -P -i4 所有TCP4上的网络连接
- lsof -I @192.168.43.251 所有关于IP的连接
- lsof -I :3306确认端口占用情况
- lsof <path/to/file> 确认文件占用情况
- lsof -p pid 确认进程打开文件情况
- lsof +d <path/to/file> 确认目录下的文件打开情况

## dmidecode查看系统信息

亲测（例如底层机器型号或虚拟机），在容器中使用报错

`dmidecode -t 1`

```console
[root@vultr ~]# dmidecode -t 1
# dmidecode 3.0
Getting SMBIOS data from sysfs.
SMBIOS 2.8 present.

Handle 0x0100, DMI type 1, 27 bytes
System Information
Manufacturer: QEMU
Product Name: Standard PC (i440FX + PIIX, 1996)
Version: pc-i440fx-3.0
Serial Number: Not Specified
UUID: F3B6F3A2-305C-4CA0-A718-EF246FFDEF10
Wake-up Type: Power Switch
SKU Number: Not Specifie

[root@zrongh ~]# dmidecode -t 1
# dmidecode 3.0
Getting SMBIOS data from sysfs.
SMBIOS 2.5 present.

Handle 0x0001, DMI type 1, 27 bytes
System Information
Manufacturer: innotek GmbH
Product Name: VirtualBox
Version: 1.2
Serial Number: 0
UUID: 10866277-427E-4EBC-BBC4-DBF1C8ACABF1
Wake-up Type: Power Switch
SKU Number: Not Specified
Family: Virtual Machine
```

在容器中运行报错，如下：

```console
[root@820a0cc6702e /]# dmidecode 
# dmidecode 3.0
Scanning /dev/mem for entry point.
/dev/mem: No such file or directory
```

根据错误信息，将主机的/dev/mem映射到容器中（此处有坑）
docker run -it --device /dev/mem:/dev/mem centos /bin/bash
继续执行，提示另外一个错误Operation not permitted，这次是docker权限的设置问题，默认docker的容器是以unprivileged的方式进行运行，无法访问任何设备，如下：

```console
[root@50ccf0622c07 dev]# ls
core  fd  full  mqueue  null  ptmx  pts  random  shm  stderr  stdin  stdout  tty  urandom  zero
[root@d7206380b726 /]# dmidecode 
# dmidecode 3.0
Scanning /dev/mem for entry point.
/dev/mem: Operation not permitted
```

但是如果通过打开特权模式(`docker run -d --privileged=true centos /bin/bash`)启动容器，那容器可以由有访问所有设备的权限

```console
[root@669e2eb40e46 /]# ls /dev/
autofs           dri        log                 port      sr0     tty15  tty26  tty37  tty48  tty59  ttyS3    vcs6         vhci
block            fb0        loop-control        ppp       stderr  tty16  tty27  tty38  tty49  tty6   uhid     vcsa         vhost-net
bsg              fd         mapper              ptmx      stdin   tty17  tty28  tty39  tty5   tty60  uinput   vcsa1        zero
btrfs-control    full       mcelog              pts       stdout  tty18  tty29  tty4   tty50  tty61  urandom  vcsa2
bus              fuse       mem                 random    tty     tty19  tty3   tty40  tty51  tty62  usbmon0  vcsa3
cdrom            hidraw0    mqueue              raw       tty0    tty2   tty30  tty41  tty52  tty63  usbmon1  vcsa4
char             hpet       net                 rtc       tty1    tty20  tty31  tty42  tty53  tty7   vcs      vcsa5
core             hugepages  network_latency     rtc0      tty10   tty21  tty32  tty43  tty54  tty8   vcs1     vcsa6
cpu              hwrng      network_throughput  sg0       tty11   tty22  tty33  tty44  tty55  tty9   vcs2     vda
cpu_dma_latency  initctl    null                shm       tty12   tty23  tty34  tty45  tty56  ttyS0  vcs3     vda1
crash            input      nvram               snapshot  tty13   tty24  tty35  tty46  tty57  ttyS1  vcs4     vfio
disk             kmsg       oldmem              snd       tty14   tty25  tty36  tty47  tty58  ttyS2  vcs5     vga_arbiter
```

此时`dmidecode -t 1`命令运行正常.

```console
[root@669e2eb40e46 /]# dmidecode -t 1
# dmidecode 3.0
Getting SMBIOS data from sysfs.
SMBIOS 2.8 present.

Handle 0x0100, DMI type 1, 27 bytes
System Information
Manufacturer: QEMU
Product Name: Standard PC (i440FX + PIIX, 1996)
Version: pc-i440fx-3.0
Serial Number: Not Specified
UUID: F3B6F3A2-305C-4CA0-A718-EF246FFDEF10
Wake-up Type: Power Switch
SKU Number: Not Specified
Family: Not Specified
```

最后，如果需要以特权并且使用systemctl进行容器中进程的管理，需要以下启动方式
以服务方式启动docker `docker run -d --privileged centos /usr/sbin/init`

```console
[root@vultr dev]# ls -lrt /usr/sbin/init
lrwxrwxrwx. 1 root root 22 Jun  5 21:39 /usr/sbin/init -> ../lib/systemd/systemd
```

## 文件删除空间不释放

linux文件系统维护着指向每个文件的链接的计数，在该文件最后一个链接被删除前不释放该文件的数据块，这就导致了一个问题**“rm删除了文件但df仍没变化”**。

```console
[root@8498cde5b38f tmp]# ls -lh
total 2.0G
-rw-r--r--. 1 root root 2.0G Nov 25 08:53 test.log
[root@8498cde5b38f tmp]# df
Filesystem     1K-blocks     Used Available Use% Mounted on
overlay         20616252 10490724   9060632  54% /
[root@8498cde5b38f tmp]# rm test.log
rm: remove regular file 'test.log'? y
[root@8498cde5b38f tmp]# df
Filesystem     1K-blocks    Used Available Use% Mounted on
overlay         20616252 10490732   9060624  54% /
```

解决思路主要集中在两个方面：清理链接、truncate文件

### 清理链接

通过lsof方式可以确认文件被什么进程打开

```console
[root@8498cde5b38f tmp]# lsof | grep test.log
tail     41 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
tail     42 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
tail     43 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
tail     44 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
tail     45 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
tail     46 root    3r   REG   0,38 2097152000 390925 /tmp/test.log (deleted)
```

从输出结果看，test.log文件已经删除，但是它被tail进程占用，导致指向文件的链接数不为0，因此文件空间不释放。只能通过杀掉访问文件的进程（即tail）进程或者重启操作系统，空间会自动释放。

### truncate文件

对进程(tomcat、httpd、nginx等程序)不断对文件写操作的文件，最好的处理方式不是将文件链接删除触发系统释放数据块，而是通过对文件进行truncate，在线清理文件内容。

```console
[root@8498cde5b38f tmp]# cat /dev/null > test.log
或
[root@8498cde5b38f tmp]# echo "" > test.log
```

## 通过设置suid位让

对于系统的每个用户，它没有权限去更新/etc/passwd文件，因为文件权限如下：

```console
[root@vultr etc]# ls -lrt /etc/passwd
-rw-r--r--. 1 root root 1025 Nov 27 13:28 /etc/passwd
[root@vultr etc]# ls -lrt /etc/shadow
----------. 1 root root 585 Nov 27 13:28 /etc/shadow
```

只有root用户有权限去更改这个文件，但普通用户也能修改

## 调整内核参数

### 临时调整(重启后失效)

- 修改/proc/sys的内核映射文件

/proc/sys下的特殊文件可以让用户去查看或者设置内核运行时的参数

- sysctl命令修改

可通过sysctl -a命令列出所有的内核参数，通过
`sysctl key=value`
的方式更新该配置。

例如，修改响应icmp包的内核参数icmp_echo_ignore_all

```console
[root@vultr ipv4]# ping 45.77.26.164
PING 45.77.26.164 (45.77.26.164) 56(84) bytes of data.
64 bytes from 45.77.26.164: icmp_seq=1 ttl=64 time=0.152 ms
64 bytes from 45.77.26.164: icmp_seq=2 ttl=64 time=0.122 ms
^C
--- 45.77.26.164 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.122/0.137/0.152/0.015 ms
[root@vultr ipv4]# sysctl -a 2> /dev/null | grep icmp_echo_ignore_all
net.ipv4.icmp_echo_ignore_all = 0
[root@vultr ipv4]# cat /proc/sys/net/ipv4/icmp_echo_ignore_all
0
[root@vultr ipv4]# sysctl net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_all = 1
[root@vultr ipv4]# cat /proc/sys/net/ipv4/icmp_echo_ignore_all
1
[root@vultr ipv4]# ping 45.77.26.164
PING 45.77.26.164 (45.77.26.164) 56(84) bytes of data.

--- 45.77.26.164 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms
```

### 永久调整

修改/etc/sysctl.conf文件
net.ipv4.icmp_echo_ignore_all = 1
重启或者sysctl -p(read values from file)生效

### 常用参数

| 配置项 | 意义 |
| ------ | ------ |
| net.ipv4.icmp_echo_ignore_all | 忽略icmp包 |
| net.ipv4.tcp_fin_timeout | 等待最后的fin包的秒数 |
| net.ipv4.ip_local_port_range | 建立连接期间的本地端口范围 |

## 通过zip加密压缩文件

`zip -j -e result.zip source.file -P password`

- `-j`：junk-paths,丢弃文件路径
- `-e`：加密文件
- `-P`：加密的密码