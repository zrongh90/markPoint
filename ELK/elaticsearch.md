# 安装

```shell
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.3.rpm
sudo rpm -i elasticsearch-6.5.3.rpm
sudo service elasticsearch start
```

注意修改/etc/elaticsearch目录下jvm.options的JVM内存大小及elasticsearch.yml的监听IP端口（便于filebeat直接接入）