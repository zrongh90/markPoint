# TCPDUMP

## 例子

### 最简单的TCPDUMP

`tcpdump -i eth0`

### 抓取ping包

`tcpdump -i eth0 -vvv icmp`

- `-i`指定抓取的网络接口
- `-vvv`详细的输出结果
- `icmp`指定获取ICMP的包

```console
[root@vultr log]# tcpdump -i eth0 -vvv icmp
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
13:21:38.865469 IP (tos 0x0, ttl 111, id 31467, offset 0, flags [none], proto ICMP (1), length 60)
    210.83.240.178 > 45.77.26.164.vultr.com: ICMP echo request, id 6496, seq 2, length 40
13:21:38.865741 IP (tos 0x0, ttl 64, id 48543, offset 0, flags [none], proto ICMP (1), length 60)
    45.77.26.164.vultr.com > 210.83.240.178: ICMP echo reply, id 6496, seq 2, length 40
```

`tcpdump -i eth0 -vvv icmp and src 210.83.240.178`

- `and`指定组合条件
- `src 210.83.240.178`指定只抓取源地址为210.83.240.178的包

```console
[root@vultr log]# tcpdump -i eth0 -vvv icmp and src 210.83.240.178
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
13:29:29.335821 IP (tos 0x0, ttl 111, id 31654, offset 0, flags [none], proto ICMP (1), length 60)
    210.83.240.178 > 45.77.26.164.vultr.com: ICMP echo request, id 6498, seq 18, length 40
13:29:30.357739 IP (tos 0x0, ttl 111, id 31656, offset 0, flags [none], proto ICMP (1), length 60)
    210.83.240.178 > 45.77.26.164.vultr.com: ICMP echo request, id 6498, seq 19, length 40
13:29:31.373104 IP (tos 0x0, ttl 111, id 31657, offset 0, flags [none], proto ICMP (1), length 60)
    210.83.240.178 > 45.77.26.164.vultr.com: ICMP echo request, id 6498, seq 20, length 40
```

`tcpdump -X -nn -i eth0 port ! 22 and not icmp -w tcp.pcap`

- `-X`将报文内容抓取
- `-nn`不进行端口协议翻译，保留数字
- `-w`将抓包的结果写入到tco.pcap文件

```console
[root@vultr .ssh]# tcpdump -X -nn -i eth0 port ! 22 and not icmp -w tcp.pcap
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
^C6 packets captured
6 packets received by filter
0 packets dropped by kernel
[root@vultr .ssh]# view tcp.pcap
[root@vultr .ssh]# tcpdump -r tcp.pcap 
reading from file tcp.pcap, link-type EN10MB (Ethernet)
13:27:42.642789 ARP, Request who-has 45.77.26.164.vultr.com tell 169.254.169.254, length 28
13:27:42.642836 ARP, Reply 45.77.26.164.vultr.com is-at 56:00:01:c6:50:11 (oui Unknown), length 28
13:27:55.549092 IP 185.165.169.36.35688 > 45.77.26.164.vultr.com.1002: Flags [S], seq 3403804943, win 65535, length 0
13:27:56.641843 IP 104-179-89-24.lightspeed.nworla.sbcglobal.net.27164 > 45.77.26.164.vultr.com.cslistener: Flags [S], seq 85748727, win 14600, length 0
13:28:01.647200 ARP, Request who-has gateway tell 45.77.26.164.vultr.com, length 28
```

### 抓包结果分析

```console
12:40:47.743045 IP 45.77.26.164.vultr.com.ssh > 210.83.240.178.7717: Flags [P.], seq 132840:133132, ack 53, win 682, length 292
13:21:38.865469 IP (tos 0x0, ttl 111, id 31467, offset 0, flags [none], proto ICMP (1), length 60)
    210.83.240.178 > 45.77.26.164.vultr.com: ICMP echo request, id 6496, seq 2, length 40
```

- 12:40:47.743045: 抓包时间戳
- IP: 协议类型：IP-IPV4,IP6-IPV6
- 45.77.26.164.vultr.com.ssh：源地址及端口
- 210.83.240.178.7717：目的地址及端口
- Flags: [P.]，该字段取值如下：

    |值|标记类型|描述|
    | ------ | ------ | ------ |
    |S|SYN|Connection Start|
    |F|FIN|Connection Finish|
    |P|PUSH|Data Push|
    |R|RST|Connecion reset|
    |.|ACK|Acknowledgment|

- seq：数据包的起止
- win：接收缓冲区中可用的字节数
- length：数据包大小
