import time


def read_file(input_file_name):
	print_flag = 0
	time_str = time.strftime("%Y/%m/%d", time.localtime())
	f = open(input_file_name, "r")
	line = f.readline()
	print ("++++++++++++++%s++++++++++++++"%(input_file_name))
	while line:
	        line = f.readline()
	        if time_str in line:
	                print_flag = 1
	        if print_flag == 1:
	                print line.replace('\n','')
	f.close


if __name__ == "__main__":
	check_file_list = ["/home/tmpusr/result/check/ck_svc_cap.log", "/home/tmpusr/result/check/ck_ansible_cron.log"]
	for file_name in check_file_list:
		read_file(file_name)
