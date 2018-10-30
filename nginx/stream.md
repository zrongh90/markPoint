# stream模块

通过stream模块将443端口的请求分发到本地的3306端口
nginx.conf
```ini
work_processes auto;
events {
    worker_connections 1024;
}
error_log /var/log/nginx_error.log info;

stream {
    upstream mysqld {
        server 127.0.0.1:3306;
    }
    server {
        listen 443;
        proxy_pass mysqld;
    }
}
```
