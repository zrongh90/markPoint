# -*- coding:UTF-8 -*-
import os
import time
import sys
import subprocess
import shutil

def time_stamp_to_time(ts=None):
    time_struct = time.localtime(ts)
    return time.strftime("%Y%m%d%H%M%S", time_struct)

def call_shell_return(cmd_str):
    result = subprocess.Popen(cmd_str,
                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = result.communicate()
    if len(out) == 0:
       print("can't get output.exist")
       sys.exit(1)
    return out

def call_shell(cmd_str):
    rtn_cod = subprocess.call(cmd_str, shell=True)
    if rtn_cod != 0:
        sys.exit(1)

def get_was_pid(in_prf_path, in_srv_name):
    get_was_cmd = "ps -ef |grep -v grep | grep -v py_getjc | grep {0} | grep {1}".format(in_prf_path, in_srv_name)
    print("call get pid shell: %s"%get_was_cmd)
    out_usr, out_pid = call_shell_return(get_was_cmd).split()[:2]
    return out_pid

def copy_jc(in_prf_path, in_target_path):
    fixed_jc_path = "/heapdump"
    curr_time = time.time()
    if not os.path.isdir(in_prf_path):
        print("profile path(%s) to get javacore is error!"%in_prf_path)
    raw_file_list = os.listdir(in_prf_path)
    in_prf_jc_list = [x for x in raw_file_list if "javacore" in x]
    fixed_jc_list = []
    if os.path.isdir(fixed_jc_path):
        fixed_jc_list = [x for x in os.listdir(fixed_jc_path) if "javacore" in x]
    if len(in_prf_jc_list) != 0 and len(fixed_jc_list) == 0:
        filted_file_list = in_prf_jc_list
        jc_path = in_prf_path
    elif len(in_prf_jc_list) == 0 and len(fixed_jc_list) !=0:
        filted_file_list = fixed_jc_list
        jc_path = fixed_jc_path
    else:
        print("profile path(%s) and fixed path /heapdump can not get javacore"%in_prf_path)
        sys.exit(1)
    for one_jc in filted_file_list:
        # print("start to copy %s to %s"%(one_jc, in_target_path))
        abs_src_file = "{0}/{1}".format(jc_path, one_jc)
        abs_dest_file = "{0}/{1}".format(in_target_path, one_jc)
        m_time = os.path.getmtime(abs_src_file)
        gap = curr_time - m_time
        if gap/60/60/24 < 3 and os.path.isfile(abs_src_file):
            print("move {0} to {1}".format(abs_src_file, abs_dest_file))
            shutil.move(abs_src_file, abs_dest_file)

def get_was_jc(was_pid):
    get_jc_cmd = "kill -3 {0}".format(was_pid)
    for times in range(0,2):
	print("call the %d time to get javacore"%(times+1))
        call_shell(get_jc_cmd)
        time.sleep(3)
    print("call the 3 time to get javacore")
    call_shell(get_jc_cmd)

def get_was_log(log_path, in_target_path):
    curr_time = time.time()
    if os.path.isdir(log_path):
        for file in os.listdir(log_path):
            abs_src_file = "{0}/{1}".format(log_path, file)
            abs_dest_file = "{0}/{1}".format(in_target_path, file)
            m_time = os.path.getmtime(abs_src_file)
            # 计算时间差
            gap = curr_time - m_time
            # 如果时间差为5天且目标存在，处理目标文件
            if gap/60/60/24 < 5 and os.path.isfile(abs_src_file):
                print("copy %s to %s"%(abs_src_file, abs_dest_file))
		shutil.copyfile(abs_src_file, abs_dest_file)
    else:
	print("path %s is not dir"%log_path)
        sys.exit(1)

def mk_target_dir(in_target_path):
    print("target path is %s"%in_target_path)
    if os.path.exists(in_target_path):
        print("path exist error")
        sys.exit(1)
    os.mkdir(target_path)
    print("target path not exist, created")


if __name__ == '__main__':
    hostname = call_shell_return("hostname").strip('\n')
    prf_path = sys.argv[1]
    srv_name = sys.argv[2]
    target_path = "/tmp/zxyx/{0}_javacore_{1}".format(hostname,time_stamp_to_time())
    print("target path is %s"%target_path)
    was_pid = get_was_pid(prf_path, srv_name)
    mk_target_dir(target_path)
    print("\n---------------------get javacore use kill -3--------------------------")
    get_was_jc(was_pid)
    log_path = "{0}/logs/{1}".format(prf_path, srv_name)
    print("\n---------------------get log--------------------------")
    get_was_log(log_path, target_path)
    print("\n---------------------get javacore--------------------------")
    copy_jc(prf_path, target_path)
    os.chdir(os.path.dirname(target_path))
    import tarfile
    tar = tarfile.open("{0}.tar.gz".format(os.path.basename(target_path)), "w:gz")
    tar.add(os.path.basename(target_path))
    tar.close()
    # print(prf_path)
    # print(srv_name)
