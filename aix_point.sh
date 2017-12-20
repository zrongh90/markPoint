1、磁盘相关
chdev -l hdisk7 -a pv=yes  #分配hdisk的pvid
mpio_get_config -Av #获取AIX的hdisk对应的阵列LUN名称
