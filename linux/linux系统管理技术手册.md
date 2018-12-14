
# 周期性进程

## crontab的标准格式

minute hour day month weekday command

## crontab注意事项

- 如果指定了weekday字段和day字段，是选择满足两个条件**之一**的时间执行。

   例如 0,30 * 13 * 5 是每周五或者每月13日执行

- crontab默认不读取~/.bash_profile和~/.profile文件内容，所有如果需要环境变量最好将命令封装到脚本中并在该脚本设置环境变量。

- cron.deny和cron.allow指定用户是否可以提交crontab文件

- -u 可以指定root用户读取其他用户的crontab

    ```console
    [root@vultr cron.d]# crontab -u serviceop -l
    0 0 * * * echo 'hello'
    [root@vultr cron.d]# crontab -u serviceop -e
    crontab: no changes made to crontab
    ```
