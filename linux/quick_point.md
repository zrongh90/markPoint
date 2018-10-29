1. 可以通过ctrl+a和ctrl+e到达当前输入命令的开头和结尾。

2. 命令复用
- !! ：上一条指令
- !1001: history结果中对应的1001条指令
- !nginx :复用上一条以nginx开头的指令

3. VIM使用技术点
- nG：定位到第n行
- w:下一个单词
- b:上一个单词
- dw:删除单个单词
- 10j: 下移10行
- 10G: 快速定位到10行

4. linux去除首行`ps -ef | sed '1d'`
    去掉尾行`ps -ef | sed '$d'`
```console
[root@vultr ~]# docker container ls
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@vultr ~]# docker container ls | sed '1d'
[root@vultr ~]#
```