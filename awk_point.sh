awk把输入流看作一连串记录的集合，每条记录都可进一步细分为字段。
通常，一行一条记录，而字段则由一个或多个非空字符的单词组成。类似一个for循环，对输入的数据中的每一行进行操作。

#awk程序模式
pattern { action } 	模式匹配，执行操作
pattern				如果模式匹配，则打印记录
		{ action }	针对每一条记录（则每一行），执行操作

FNR：输入文件记录数 
NR：当前处理的记录数
NF：当前记录的字段数
FS：输入字段分隔符（默认" "），只有在它超过一个字符时，才被视为正则表达式
OFS：输出字段分隔符（默认" "）
RS：输入记录（行）分隔符（默认"\n")
ORS：输出记录（行）分隔符（默认"\n")

#BEGIN和END关联的操作只会执行一次，BEGIN在任何命令行处理之前，但在-v初始化之后；END是在所有操作被完成后执行。
cat filename | 
awk '
#init recordC 0
BEGIN { recordC = 0 }
#对于每一条记录，打印记录对应的字段数
      { print NF }
#打印文件的记录数，则行数
END { recordC = FNR ; print recordC }'

#以/为分割符，打印最后一个记录
awk 'BEGIN { FS="/" } { print $(NF) }'

#以" "为分割符，循环结果，打印满足条件的字段
awk '{for(i=1;i<NF;i++) {if($i ~ "Xmx" || $i ~ "wasserver" || $i ~ "wasprofile") print $i}}'

#循环将每行的结果相加
awk 'BEGIN{total=0}{for(i=1;i<=NF;i++) total=total+$i} END{print total}'