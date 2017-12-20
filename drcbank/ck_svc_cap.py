#!/usr/bin/python
#通过登录svc使用lsmdiskgrp命令得到池的使用情况
import paramiko
import time

def check_svc(ip_addr_name):
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	ip_addr, svc_name = ip_addr_name.split(':')
	ssh.connect(ip_addr, 22, "superuser", "passw0rd")
	stdin, stdout, stderr = ssh.exec_command("lsmdiskgrp")
	title = stdout.readline().split()
	#print ("%20s %20s %20s"%(title[1],title[5],title[7]))
	print ("-----------------------------------%s-------------------------------------------------"%(svc_name))
	one_line = stdout.readline()
	while one_line:
		one_record = one_line.split()
		mdisk_grp_name = one_record[1]
		if mdisk_grp_name in POOL_LIST:
			print ("%-30s %15s %15s %15.2f"%(one_record[1], one_record[5], one_record[7], (1 - float(str(one_record[7])[0:-2])/float(str(one_record[5])[0:-2]))*100))
		one_line = stdout.readline()
	stdout.close()
	ssh.close()
	return 0

if __name__ == "__main__":
	print ("\n")
	print ("%35s %15s"%("",time.strftime("%Y/%m/%d %H:%M", time.localtime())))
	#需要采集的信息
	print ("%15s %-15s %15s %15s %15s"%("", "name", "capacity", "free_capacity", "used_percent"))
	#数据中心使用的SVC列表
	svc_list = [
	"10.8.254.66:GL_SVC",
	"10.8.254.57:VM_SVC",
	"10.8.254.60:AIX_SVC",
	"10.8.254.63:DR_SVC",
	"10.8.254.15:HD_SVC"]
	#SVC目前在用池（需要关注空间使用情况）
	POOL_LIST = ["VMware_I7_V7000", "V3700_K6", "V3700_K7", "VMware_I8_V7000",
	"HD_SLOWPOOL", "HD_FASTPOOL",
	"V3700_K6", "V3700_K7", "VMware_I7_V7000", "VMware_I8_V7000",
	"POOL1_DS5100DR_H1", "V5000_DR_H2", "DR_A4_V7000",
	"GL_SVC_Tier_Local_Pool1", "GL_SVC_Tier_DR_Pool1"]
	for one_svc in svc_list:
		check_svc(one_svc)
