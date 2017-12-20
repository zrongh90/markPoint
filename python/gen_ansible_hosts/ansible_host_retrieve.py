# coding=utf-8
import xlrd

__author__ = 'Zivin huang'
DEBUG = False

if DEBUG:
    ANSIBLE_IP_FILE = u"ip_file/DeviceInfo.xls"
    ANSIBLE_FILTER_RHEL_FILE = u"ip_file/ansible_filter_ip_rhel"
    ANSIBLE_OUT_RHEL_FILE = u"ip_file/result_rhel_file"
    ANSIBLE_RHEL_TEMPLATE = u'ip_file/rhel_template'

    ANSIBLE_FILTER_AIX_FILE = u"ip_file/ansible_filter_ip_aix"
    ANSIBLE_OUT_AIX_FILE = u"ip_file/result_aix_file"
    ANSIBLE_AIX_TEMPLATE = u'ip_file/aix_template'
else:
	UTILS_PATH = u"/home/tmpusr/drcbank/gen_ansible_hosts/ip_file/"
	RESULT_PATH = u"/home/tmpusr/result/ansible_hosts/"
	SOURCE_PATH = u"/home/tmpusr/upload/"
	
	ANSIBLE_IP_FILE = SOURCE_PATH + u"DeviceInfo.xlsx"
	ANSIBLE_FILTER_RHEL_FILE = UTILS_PATH + u"ansible_filter_ip_rhel"
	ANSIBLE_RHEL_TEMPLATE = UTILS_PATH + u'rhel_template'
	ANSIBLE_OUT_RHEL_FILE =  RESULT_PATH + u"result_rhel_file"
	
	ANSIBLE_FILTER_AIX_FILE = UTILS_PATH + u"ansible_filter_ip_aix"
	ANSIBLE_AIX_TEMPLATE = UTILS_PATH + u"aix_template"
	ANSIBLE_OUT_AIX_FILE = RESULT_PATH + u"result_aix_file"


def get_filter_dict(filter_file):
    in_filter_dict = {}
    f = file(filter_file, "r")
    line = f.readline()
    while line:
	line = line.strip()
        if line.__eq__('\n') or line.__eq__(''):
            line = f.readline()
        else:
            ip_addr = line.__str__().split(' ')[0]
            name = line.__str__().split(' ')[1]
            in_filter_dict[ip_addr] = name
        line = f.readline()
    f.close()
    return in_filter_dict


def get_filted_ip_list(in_ip_file, in_filter_dict, in_type):
    inner_filted_ip_dict = {}
    workbook = xlrd.open_workbook(in_ip_file)
    sheet = workbook.sheet_by_index(0)
    begin_row = 1
    for tgt_row in range(begin_row, sheet.nrows):
        device_type = sheet.cell_value(tgt_row, 7).encode('utf-8')
        device_type_2 = sheet.cell_value(tgt_row, 10).encode('utf-8')
        # print str(device_type).lower().__contains__("linux")
        if str(device_type).lower().__contains__(in_type) and str(device_type_2).lower().__contains__(in_type):
            hostname = sheet.cell_value(tgt_row, 0).encode('utf-8')
            ip_addr = sheet.cell_value(tgt_row, 4)
            if ip_addr in in_filter_dict.keys() or str(ip_addr).__len__() <= 1:
                pass
            else:
                inner_filted_ip_dict[ip_addr] = hostname
    return inner_filted_ip_dict


def get_filted_file(in_type, header, filter_file, out_file):
        filter_dict = get_filter_dict(filter_file)
        filted_dict = get_filted_ip_list(ANSIBLE_IP_FILE, filter_dict, in_type)
        f = open(out_file, 'w')

        f.write(header.__add__("\n"))
        for key in filted_dict.keys():
            one_line = str(key).__add__("\tname=").__add__(filted_dict[key]).__add__('\n')
            f.write(str(one_line))
        f.write('\n')
        if in_type == "linux":
            f_template = open(ANSIBLE_RHEL_TEMPLATE, 'r')
            f.write(f_template.read())
        elif in_type == "aix":
            f_template = open(ANSIBLE_AIX_TEMPLATE, 'r')
            f.write(f_template.read())
        else:
            raise
        f.close()

if __name__ == "__main__":
    get_filted_file("linux", "[drcbank_rhel6]", ANSIBLE_FILTER_RHEL_FILE, ANSIBLE_OUT_RHEL_FILE)
    get_filted_file("aix", "[drcbank_aix]", ANSIBLE_FILTER_AIX_FILE, ANSIBLE_OUT_AIX_FILE)
