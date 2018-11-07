0. 主控：ansible主机          远程主机：受管主机
1. command/script/shell
	
	command：可以运行远程权限范围内所有shell命令；

	script：远程主机执行主控端的shell脚本文件，类似与scp+shell；

	shell：执行远程主机的脚本文件

2. 使用注册变量，将find模块得到的文件信息写入shell_list中，在下一个模块中通过with_items获取变量的内容。
shell_list的结构：
"shell_list": {
	“changed":"false"
	"files": [{
		...
		"path":"/zxyx/zxyx/shell/nmon_collect.sh"
		...
	},{
		...
		"path":"/zxyx/zxyx/shell/nmon_collect.sh"
		...
	},...
	]
	"msg":"{}"
}

- name: find shell 
  find: paths="/zxyx" patterns="*.sh" recurse=True
  register: shell_list

- name: chmod for shell
  file: path={{ item.path }} state=touch mode="u+x"
  with_items: "{{ shell_list.files }}"     #循环遍历列表内的值
  
2、使用debug模块可以打印变量的结构，便于取值
- debug:var=shell_list

3、在命令行匹配主机时，通过""将正则表达式包括：
	ansible -i ./hosts "~10.8.24.([4-9]|1[0-1])$" -u ansible -m ping #匹配 10.8.24.4到10.8.24.11的主机列表
	
4、playbook中的命令行传值
	传值：ansible-playbook main.yml --extra-vars "hosts=test user=root"
	json格式：ansible-playbook main.yml --extra-vars "{'hosts':'test', 'user':'root'}"
	文件:ansible-playbook main.yml --extra-vars "@vars.json"
	
5、逻辑控制语句
	1）when：条件判断
		tasks:
			- name: "test shutdown"
			  command: "/usr/bin/oslevel -s"
			  when: ansible_os_family == "aix"
		
		tasks:
			- name: "action accroding to result"
			  command: "/usr/bin/somecommand"
			  register: result
			- command: "/usr/bin/result_true"
			  when: result | true
			- command: "/usr/bin/result_false"
			  when: result | false
			  
		tasks:
			- ...
			  when: item
			- ... 
			  when: not item
			- ...  
			  when: item is defined
			- ...  
			  when: item is not defined
			- ...  
			  with_items: [ 0, 2, 4, 6, 8]
			  when: item > 5
			- ...
			  when: "'hehe' in item"
			- hosts: rhel6
			  roles:
			    - { role: test_item, when: item == 'test' }
	2）loop：循环
		标准循环：
			- name: add user
			  user: name={{ item }} state=present group=staff
			  with_items:
				- userone
				- usertwo
		
		vars:
			user_list: ["userone", "usertwo"]
		tasks:
			- name: add user
			  user: name={{ item }} state=present group=staff
			  with_items: "{{ user_list }}"
		
		嵌套循环：
			- name: add user
			  user: name={{ item[0] }} group={{ item[1] }} state=present
			  with_nested:
				- [ 'userone', 'usertwo' ]
				- [ 'staff', 'usergrp' ]
		哈希表：
		users:
			userone:
				name: user_one
				telp: 123456
			usertow:
				name: user_two
				telp: 654321
		tasks:
			- name: print user telephone
			  debug: msg="User {{ item.key }} is {{ item.value.name }} {{ item.value.telp}}"
			  with_dict:
				- " {{ users }}"
		文件循环:
			- ...
			  with_fileglob:
				- /home/user/file/*
	3）block：代码块
		多个action结合，不同条件执行不同块
