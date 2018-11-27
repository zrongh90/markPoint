# awk && sed 

## awk

awk把输入流看作一连串记录的集合，每条记录都可进一步细分为字段。
通常，一行一条记录，而字段则由一个或多个非空字符的单词组成。类似一个for循环，对输入的数据中的每一行进行操作。

### awk程序模式

- pattern { action }    模式匹配，执行操作

- pattern-----------如果模式匹配，则打印记录

- ---------{ action }   针对每一条记录（则每一行），执行操作

      FNR：输入文件记录数
      NR：当前处理的记录数
      NF：当前记录的字段数
      FS：输入字段分隔符（默认" "），只有在它超过一个字符时，才被视为正则表达式
      OFS：输出字段分隔符（默认" "）
      RS：输入记录（行）分隔符（默认"\n")
      ORS：输出记录（行）分隔符（默认"\n")

BEGIN和END关联的操作只会执行一次，BEGIN在任何命令行处理之前，但在-v初始化之后；END是在所有操作被完成后执行。

```shell
cat filename |
awk '
#init recordC 0
BEGIN { recordC = 0 }
#对于每一条记录，打印记录对应的字段数
      { print NF }
#打印文件的记录数，则行数

END { recordC = FNR ; print recordC }'
```

#以/为分割符，打印最后一个记录

awk 'BEGIN { FS="/" } { print $(NF) }'

#以" "为分割符，循环结果，打印满足条件的字段

awk '{for(i=1;i<NF;i++) {if($i ~ "Xmx" || $i ~ "wasserver" || $i ~ "wasprofile") print $i}}'

#循环将每行的结果相加

awk 'BEGIN{total=0}{for(i=1;i<=NF;i++) total=total+$i} END{print total}'

### 打印bin目录下suid为true的二进制文件列表

首先通过grep获取类型为file的项目，然后通过awk -F ''将字符逐个拆开，打印满足第四个字符为s的行的信息。
要知道，这是个笨方法，最好的方式是通过find指定perm去查找

```console
[root@vultr tmp]# ls -lrt /bin/ | grep ^- |  awk -F ''  'BEGIN{suid="s"}{if($4==suid)print $0}'
-rwsr-xr-x. 1 root root      27832 Jun 10  2014 passwd
-rwsr-xr-x. 1 root root      41776 Nov  5  2016 newgrp
-rwsr-xr-x. 1 root root      78216 Nov  5  2016 gpasswd
-rwsr-xr-x. 1 root root      64240 Nov  5  2016 chage
-rwsr-xr-x. 1 root root     155000 Aug  3  2017 netstat
-rwsr-xr-x. 1 root root      27680 Apr 11  2018 pkexec
-rwsr-xr-x. 1 root root      57576 Apr 11  2018 crontab
---s--x--x. 1 root root     143248 Jun 27 18:03 sudo
-rwsr-xr-x. 1 root root      32048 Aug 16 18:47 umount
-rwsr-xr-x. 1 root root      32184 Aug 16 18:47 su
-rwsr-xr-x. 1 root root      44320 Aug 16 18:47 mount
-rws--x--x. 1 root root      23960 Aug 16 18:47 chsh
-rws--x--x. 1 root root      24048 Aug 16 18:47 chfn
[root@vultr etc]# find /bin/ -perm -4000 -exec ls -lrt '{}' \;
-rwsr-xr-x. 1 root root 64240 Nov  5  2016 /bin/chage
-rws--x--x. 1 root root 24048 Aug 16 18:47 /bin/chfn
-rwsr-xr-x. 1 root root 41776 Nov  5  2016 /bin/newgrp
-rwsr-xr-x. 1 root root 27832 Jun 10  2014 /bin/passwd
-rwsr-xr-x. 1 root root 44320 Aug 16 18:47 /bin/mount
-rwsr-xr-x. 1 root root 78216 Nov  5  2016 /bin/gpasswd
-rwsr-xr-x. 1 root root 27680 Apr 11  2018 /bin/pkexec
---s--x--x. 1 root root 143248 Jun 27 18:03 /bin/sudo
-rwsr-xr-x. 1 root root 32184 Aug 16 18:47 /bin/su
-rws--x--x. 1 root root 23960 Aug 16 18:47 /bin/chsh
-rwsr-xr-x. 1 root root 32048 Aug 16 18:47 /bin/umount
-rwsr-xr-x. 1 root root 155000 Aug  3  2017 /bin/netstat
-rwsr-xr-x. 1 root root 57576 Apr 11  2018 /bin/crontab
```

## sed

截取某个时间段的日志

sed -n '/11-14 13:50/,/11-14 13:51/g' nts-pims-padis-xl.out