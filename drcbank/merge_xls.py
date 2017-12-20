import xlrd
import xlwt
import sys
def read_excel(sheet_path):
	workbook = xlrd.open_workbook(sheet_path)
	sel_sheet = workbook.sheet_by_index(0)
	return sel_sheet

def merge_excel(aix_sheet,linux_sheet,export_file):
	
	print "aix"
	print aix_sheet.ncols
	print aix_sheet.nrows
	print "linux"
	print linux_sheet.ncols
	print linux_sheet.nrows
	excel_file = xlwt.Workbook()
	sheet1 = excel_file.add_sheet("info", cell_overwrite_ok=True)
	current_row = 0
	for aix_row in range(0,aix_sheet.nrows):
                for aix_column in range(aix_sheet.ncols):
			sheet1.write(int(current_row)+int(aix_row),aix_column,aix_sheet.cell(aix_row,aix_column).value)
	current_row = int(current_row) + int(aix_sheet.nrows)
	for linux_row in range(0,linux_sheet.nrows):
                for linux_column in range(linux_sheet.ncols):
			sheet1.write(int(current_row)+int(linux_row),linux_column,linux_sheet.cell(linux_row,linux_column).value)
	excel_file.save(export_file)
	
aix_sheet_name = sys.argv[1]
linux_sheet_name = sys.argv[2]
out_sheet_name = sys.argv[3]
aix_sheet = read_excel(aix_sheet_name)
linux_sheet = read_excel(linux_sheet_name)
merge_excel(aix_sheet, linux_sheet, out_sheet_name)
