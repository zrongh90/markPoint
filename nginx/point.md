# IP直接返回

在nginx的配置文件nginx.conf中添加判断逻辑针对访问的IP进行默认的返回。

配置策略`$remote_addr ~ (66.42.81.47|45.77.26.164)`

    如果访问IP匹配（在nginx中通过~符号）正则表达式的内容

配置策略`$http_x_forwarded_for ~ (66.42.81.47|45.77.26.164)`

    如果访问源地址IP匹配（在nginx中通过~符号）正则表达式的内容

```conf
server {
    ...
    if ($remote_addr ~ (66.42.81.47|45.77.26.164)) {
        return 404;
    }
    if ($http_x_forwarded_for ~ (66.42.81.47|45.77.26.164)) {
        return 404;
    }
    ...
}
```

在shell中可通过sed直接更改nginx.conf中关于这一段的配置
`sed -Ei 's/(remote_addr)(.*)(\)\))/\1\2|45.77.26.164\3/' nginx.conf`

具体sed逻辑如下：

    - 使用-E参数扩展正则表达式
    - `(remote_addr)(.*)(\)\))` 分别匹配三个不同的捕获分组remote_addr/remote_addr后到两个括号前的内容/两个括号
    - `\1\2|45.77.26.164\3` 后向引用打印捕获分组，并在捕获分组2和3之间添加需要新增的IP
    - 使用-i参数就地更新文件