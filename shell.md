1. shell赋值的=中间完全没有任何空格
```console
[root@vultr ~]# val='test'
[root@vultr ~]# val = 'test'
-bash: val: command not found
```

2. `echo -n` 不换行，`echo -e` 转义字符生效
```console
[root@vultr ~]# echo -n 'test'
test[root@vultr ~]# echo -e 'test\r'
test
```
3. $PATH的空项目表示当前目录

4. 开头^,结尾$

5. 字符串判定用双引号

6. `cp name{,.bak}` #linux下可用

7. 在shell头设置umask为077，只让进程执行的用户访问

8. POSIX内置Shell变量
	
>\#：进程的变量个数
>
>@：传递给当前进程的命令行参数。"$@",展开为个别参数(没有双引号的情况下，$*和$@是一样的)
>
>\*：传递给当前进程的命令行参数。"$*",展开为一个单独参数
>
>?：前一命令的退出状态
>
>$：PID
>
>0：shell进程名称
>
>PWD：当前工作目录
>
>PPID：父进程PID
	
9. 使用trap命令进行清理工作
>p.s: 在进程接受到下面HUP等信号时，执行exit 1命令退出程序，在捕获EXIT信号进行文件的清除
>
>trap "exit 1"	HUP EXIT PIPE QUIT	TERM
>
>trap "rm -f $filename" EXIT
	
10. sort排序	
>sort -t: -k1	以:为分割符，从第一个字段到记录结尾为键值
>sort -t: -k1,2	以:为分割符，从第一个字段到第二个字段结尾为键值
>sort -t: -k1.4	以:为分割符，从第一个字段的第四个字符为键值
	
11. 通过`echo`和`sleep`的组合，模拟在`sosreport`执行的过程中输入回车
```shell
(echo -e "\n";sleep 1) | sosreport --name `hostname` -a 
```

12. 使用$(...)进行命令替代而非`` `...` ``

13. google的shell编码规范
	1. 必须以#!/bin/bash开头
	2.
```html
          +- 无后缀（推荐）           
          +- 可执行-+
          +         +- .sh后缀				
文件后缀: -+
          +- 库方法：必须以.sh为后缀
```
	3. 禁止使用SUID和SGID的权限，如果必要，可用`sudo`替代
	4. 所有错误信息需要自定义重定向
	```shell
	err(){
		echo "[$(date +'%Y-%m-%d %H:%M%S%z')]: $@" > &2
	}
	if ! do_something; then
		err "unable to do!"
		exit "${END_STATUS}"
	fi
	```
	5. 注释要求：
		1. 每个文件需要对其作用进行注释；
		2. 每个函数注释需要包括a)函数;b)全局变量;c)变量;d)返回值的注释；
		3. 其他注释可根据实际情况
	6. 文件格式规范：
		1. 不使用tab键，使用两个空格进行排版；
		2. 每行的长度最好在80内；
		3. 管道符的情况下考虑换行；  
		4. do和then紧跟while、for和if
		5. case语句 a)语句较短，无需换行 b);;单列
	   case "${expr}" in
	     a) variable="..." ;;
		 b)
		   actions="act"
		   another_command "${actions}"
		   ;;
	   esac
		6. 使用"{$var}"方式；不引数字；如无歧义，不brace-quote 特殊变量；除非一定要用$*，否则使用"$@"
	   推荐做法：
	     echo "${flag}"
		 echo "Position: $1" "$3" "$@"
		 echo "Positon: ${1}0"  #避免歧义
         value=32	
  7）使用`$(command)` 替代`` `command` ``
     使用[[ ... ]] 优于 [] 和 test
	 使用-z -n来比较字符串
```shell
	   if [[ -z "${my_str}" ]]; then
	     ...
	   fi
	          优于
	   if [[ "${my_str}" = "" ]]; then 及
	   if [[ "${my_str}X" = "some_strX" ]]; then
```
	 使用./*优于*(考虑文件名为 -r -f的情况)
     避免使用eval
     避免通过管道传递给while	 
  8）命名规范：

	文件名 -+
	函数名 -+--小写、下划线
	变量名 -+
   		
	常    量 -+
              +--大写、下划线、文件头 
	全局变量 -+	

				
				
				
				
				
				
				
				
				
				