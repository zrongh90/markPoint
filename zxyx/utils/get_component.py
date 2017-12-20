import commands
import json

def format_error(status, msg):
	result = {}
	result['status'] = status
	result['msg'] = msg
	return result

def get_db2_result():
	result = {}
	db_result = []
	pid_cmd_str = "ps -ef | grep -v grep | grep db2sysc | awk '{print $1,$2}'"
	(status, pid_output) = commands.getstatusoutput(pid_cmd_str)
	if status != 0:
		result = format_error("error", "not get db pid")
		return json.dumps(result)
	if len(pid_output.strip('\n')) == 0:
		result = format_error("error", "no db found")
		return json.dumps(result)
	for one_instance in pid_output.split('\n'):
		one_result = {}
		inst_name, db_sys_pid = one_instance.split()
		inst_port_cmd_str = "netstat -apn | grep LISTEN | grep -w " + db_sys_pid + " | awk '{print $4}' | awk -F':' '{print $NF}'"
		(status, port_output) = commands.getstatusoutput(inst_port_cmd_str)
		one_result['inst_name'] = inst_name
		one_result['port_ouput'] = port_output
		db_cmd_str = "su - " + inst_name + " -c 'export LANG=en_US;db2 list db directory' | grep 'Database name' | awk '{print $NF}'"
		(status, db_output) = commands.getstatusoutput(db_cmd_str)
		db_type_cmd_str = "su - " + inst_name + " -c 'export LANG=en_US;db2 list db directory' | grep 'Directory entry type' | awk '{print $NF}'"
		(status, db_type_output) = commands.getstatusoutput(db_type_cmd_str)
		db_output_list = db_output.split('\n')
		db_type_list = db_type_output.split('\n')
		if len(db_output_list) != len(db_type_list):
			print "error to get db info: dbname and type not match!"
		db_output_list_result = [ db_output_list[x] for x in range(0, len(db_type_list)) if db_type_list[x] == "Indirect"]
		db_str = ""
		for cur in range(0, len(db_output_list_result)):
			if cur < (len(db_output_list_result) - 1) :
				db_str = db_str + db_output_list_result[cur] + ','
			if cur == (len(db_output_list_result) - 1)  :
				db_str = db_str + db_output_list_result[cur]
		one_result['db_str'] = db_str
		db_result.append(one_result)
	result["status"] = "success"
	result["msg"] = db_result
	return json.dumps(result)

def get_was_result():
	result = {}
	cmd_str = "netstat -apn | grep tcp | grep -v grep | grep LISTEN | grep -wE '908[0-9]'"
	(status, pid_output) = commands.getstatusoutput(cmd_str)
	if status != 0:
		result = format_error("error", "get no was pid")
		return json.dumps(result)
	pid_output = [x.split('/')[0] for x in pid_output.split() if 'java' in x]
	was_list = []
	for pid in pid_output:
		one_was = {}
		ps_cmd_str = "ps -ef | grep -v grep | grep -w " + str(pid)
		(status, ps_output) = commands.getstatusoutput(ps_cmd_str)
		for one_component in ps_output.split():
			if "Xmx" in one_component:
				one_was["max_mem"] = one_component.replace("-Xmx",'').replace('m','')
			if "Dosgi.configuration.area" in one_component:
				if "servers" in one_component:
					one_was["prf_path"], one_was["srv_name"] = one_component.split('=')[1].replace('configuration','').split('servers')
					one_was["srv_name"] = one_was["srv_name"].replace('/','')
				else:
					one_was["prf_path"] = one_component.split('=')[1].replace('configuration','')
			else:
				if "Dam.wasserver" in one_component:
					one_was["srv_name"] = one_component.split('=')[1]
		ps_aux_str = "ps aux | grep -v grep | awk '{if($2==\"'" + str(pid) + "'\") print $4 }'"
		(ps_aux_status, ps_aux_output) = commands.getstatusoutput(ps_aux_str)
		get_mem_str = "free -m | grep Mem | awk '{print $2}'"
		(get_mem_status, get_mem_output) = commands.getstatusoutput(get_mem_str)
		if ps_aux_status == 0 and get_mem_status == 0:
            		one_was['mem'] = round(float(ps_aux_output) / 100 * int(get_mem_output))
		if not one_was.has_key("srv_name") or not one_was.has_key("prf_path"):
			result = format_error("error", "java format error")
			return json.dumps(result)
		was_list.append(one_was)
	result["status"] = "success"
	result["msg"] = was_list
	return json.dumps(result)
	
if __name__ == '__main__':
	component = {}
	db2_result = get_db2_result()
	was_result = get_was_result()
	component['db2'] = db2_result
	component['was'] = was_result
	print component
