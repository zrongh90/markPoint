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

`sed [-n][-e script]...[-f script_file]...[file...]`

截取某个时间段的日志

sed -n '/11-14 13:50/,/11-14 13:51/p' nts-pims-padis-xl.out

`sed -n 's/^/<h1>/;s/$/<\/h1>/p;q' rime.txt`

上面这段代码完成了以下内容：

- 使用-n参数只打印script处理后的结果
- `s/^/<h1>/`在行首插入`<h1>`标签
- `;`用于分割命令
- `s/$/<\/h1>/p`在行尾插入`<\h1>`标签并打印
- `q`完成前面script定义的操作后退出

```console
[root@vultr ~]# head -1 rime.txt 
THE RIME OF THE ANCYENT MARINERE, IN SEVEN PARTS.
[root@vultr ~]# sed -n 's/^/<h1>/;s/$/<\/h1>/p;q' rime.txt 
<h1>THE RIME OF THE ANCYENT MARINERE, IN SEVEN PARTS.</h1>
```

`sed -nE '/\b(the|The|THE)\b/p' rime.txt`

上面这段代码完成了以下内容：

- 使用-n参数只打印script处理后的结果
- `/\b(the|The|THE)\b/p`匹配带边界的the/The/THE的三种模式并`p`打印
- 命令的效果类似于`grep -E '\b(the|The|THE)\b' rime.txt`

```console
[root@vultr ~]# grep -E '\b(the|The|THE)\b' rime.txt | wc -l
259
[root@vultr ~]# sed -nE '/\b(the|The|THE)\b/p' rime.txt | wc -l
259
```

### sed常用命令

#### a和i命令

a: append

i: insert

用法：

`sed '1 i insert first line' test.txt`

```console
[root@vultr ~]# sed '1 i insert first line' test.txt 
insert first line
1
2
3
4
5
```

`sed '$ a append last line' test.txt`

```console
[root@vultr ~]# sed '$ a append last line' test.txt
1
2
3
4
5
append last line
```

结合匹配的结果进行插入或追加

```console
[root@vultr ~]# sed '/line 2/ i insert before 2' test.txt
line 1
insert before 2
line 2
line 3
line 4
line 5
```

#### c命令

c命令是替换匹配行

```console
[root@vultr ~]# sed '/line 2/ c change line 2' test.txt
line 1
change line 2
line 3
line 4
line 5
```

#### d命令

d命令是删除目标

```console
[root@vultr ~]# sed '/line 2/ d' test.txt
line 1
line 3
line 4
line 5
```

#### p命令

p命令是打印目标，可以类似grep的用法

```console
匹配两个模式line 2到line 4的记录
[root@vultr ~]# sed -n '/line 2/,/line 4/p' test.txt
line 2
line 3
line 4
```

### sed后向引用

当正则表达式的一个模式的部分或全部字符由一队括号分组时，它对内容进行捕获并临时存储在内存中。可以通过后向应用的方式对内存中的捕获分组进行引用，例如 **\1**引用第一个捕获分组。

`sed -En 's/(It is) (an ancyent Marinere)/\2 \1/p' rime.txt`

上面这段代码完成了以下内容：

- 捕获It is和an ancyent Marinere的内容并放入内存
- `\2 \1`方式将捕获的内容倒序，并以`p`结尾表示打印该结果

```console
[root@vultr ~]# sed -En '/(It is) (an ancyent Marinere)/p' rime.txt
     It is an ancyent Marinere,
[root@vultr ~]# sed -En 's/(It is) (an ancyent Marinere)/\2 \1/p' rime.txt
     an ancyent Marinere It is,
```