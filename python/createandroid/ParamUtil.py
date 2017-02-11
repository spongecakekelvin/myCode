#coding=utf-8
import re
import os
import json

def doreplace(file, reList,aList):
	if len(reList) != len(aList):
		print "reList&aList's lenth is not equal!!!"
		return
		
	print '\n\n-----------------------------------------'	
	print file
	conFile = open(file)
	contentList = conFile.readlines()
	conFile.close()
	
	#遍历文件
	cSzie = len(reList)
	index = 0
	reindex = 0
	rereobj = re.compile(reList[reindex])
	for line in contentList:
		if rereobj.search(line):
			finded_param = rereobj.findall(line)
			#替换
			contentList[index] = line.replace(finded_param[0],aList[reindex])
			print ' line:',index+1
			print contentList[index]
			#下一个
			reindex = reindex+1
			if reindex >= cSzie:
				break
			rereobj = re.compile(reList[reindex])
		index = index+1
	
	confile = open(file,"w")
	contentlist = confile.writelines(contentList)
	confile.close()

def fileReplace(file,old,new,max):
	conFile = open(file)
	content = conFile.read()
	conFile.close()
	
	if max == None:
		content.replace(old,new)
	else:
		content.replace(old,new,max)
	
	confile = open(file,"w")
	content = confile.write(content)
	confile.close()

	
	