# 安装

```shell
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.3-x86_64.rpm
sudo rpm -vi filebeat-6.5.3-x86_64.rpm
```

修改/etc/filebeat/filebeat.yml中关于elasticsearch和kibana的监听设置，配置后可通过filebeat setup -e配置
