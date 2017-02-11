#coding=utf-8
import sys
def EnSure(resule,sureValue = 0):
	if resule == sureValue:
		return
	
	istr = "停止请按：n"
	inputstr = raw_input(istr.decode("utf-8").encode("gb2312"))
	if inputstr.lower() == 'n':
		sys.exit(1)