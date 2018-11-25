# 安装docker-ce

centos下可以通过安装yum-utils，下载docker-ce的repo文件，通过yum命令安装这三部完成docker-ce的安装。

## 安装yum-utils

```console
[root@vultr ~]# yum install -y yum-utils
```

## 添加docker-ce的repo源

可以通过两种方式添加(docker的源和阿里的mirror)

- yum-config-manager
- 下载文件到/etc/yum.repos.d/

```console
[root@vultr ~]# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
[root@vultr ~]# yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
[root@vultr ~]# cd /etc/yum.repos.d/ && wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

## yum安装docker-ce

```console
[root@vultr ~]# yum install -y docker-ce
```

## 启动docker服务

```console
[root@vultr ~]# systemctl start docker
```