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