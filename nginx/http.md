# http模块
## 反向代理
根据客户端的需求，从后端服务器获取资源并返回给客户端，和服务端在一个局域网内，对客户端透明。
## 好处
1. 缓冲请求
2. 安全，后端服务器隐藏在反向代理后；
3. 负载均衡，请求获取，可通过反向代理分发服务请求到rs，需要检查后端服务的可用性

    通过max_fails和timeout联合检查,在同一个timeout周期内，如果不可用次数达到max_fails,认为该后端节点不可用，需要在http中配置proxy_next_upstream指定分发到另外一台机器的情况，例如发生http_404/http_502/http_503时将请求分发到下一台机器
4. 静态内容缓存，无需到后端服务器获取
5. 传输压缩

nginx upstream-进行负载均衡
1. 轮询(默认)
2. weight
3. ip_hash

配置文件参考如下：
```ini
http{
  proxy_next_upstream http_502 http_504 http_404 error timeout invalid_header;
  … 
   upstream test_servers {
           ip_hash/least_conn
	    server localhost:8080 weight=10 max_fails=3 fail_timeout=10s;
	    server localhost:8081 weight=10 max_fails=3 fail_timeout=10s;
    }
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
	    proxy_pass http://test_servers;
        }
}
```