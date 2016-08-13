#!/usr/bin/env python
# -*- coding: utf-8 -*-
#coding=utf-8 
# author yhd 
# 用于生成模块或单个view
from sys import argv
import os
import string
import xml.etree.ElementTree as ET
import json
import time
import sys

scriptdesc = "用于生成模块或单个view"
scriptdesc=scriptdesc.decode('utf-8').encode('gb2312')
print(scriptdesc)

currpath = os.getcwd()
modeviewpath = currpath+"\\modulenameView.lua"
modecontrollpath = currpath + "\\modulenameController.lua"
modulesPath = currpath+"\\modulenameModel.lua"
initpath = currpath + "\\__init__.lua"
yourdescpath = currpath + "\\yourdesc.json"

yourdescfile = open(yourdescpath,"r")
jsondic = json.load(yourdescfile)
yourshortname = jsondic["yourshorname"]
yourshortname= yourshortname.decode('gb2312').encode('utf-8')
timetable = time.localtime()
year = timetable[0]
month = timetable[1]
day = timetable[2]
nowtime = str(year)+"年"+str(month)+"月"+str(day)+"日"
chinacehua = "中文"
chinacehua = chinacehua.decode('utf-8').encode('gb2312')
#print("test"+chinacehua)

tipselectv = "请输入一个字符如果是(v)就只创建一个view其他字符就创建模块"
tipselectv = tipselectv.decode('utf-8').encode('gb2312')
print(tipselectv)
selecttype = raw_input()
if selecttype == "v":
	#onlycreateview
	print("please input viewname")
	viewname = raw_input()
	tipviewattac = "输入view要放置模块名"
	tipviewattac = tipviewattac.decode("utf-8").encode('gb2312')
	print(tipviewattac)
	modulename = raw_input()
	while os.path.exists(currpath + "\\..\\..\\src\\gamecore\\modules\\"+modulename)==False:
		#print("modulepaht not exists please input a modulename for view attchpath")
		tipviewattac = "模块名不存在 请重新输入"
		tipviewattac.decode("utf-8").encode('gb2312')
		modulename = raw_input()
	tipviewinheritace = "请输入view要继承类如果输入字符(1)继承BasePanel其他的是(baseLayer)"
	tipviewinheritace=tipviewinheritace.decode('utf-8').encode('gb2312')
	#print("please input the view Inheritance if it is (1) will Inheritance from BasePanel others Inheritance from BaseLayer")
	print(tipviewinheritace)
	
	parentselect = raw_input()
	parent = None
	if parentselect == '1':
		parent = "BasePanel"
	else:
		parent = "BaseLayer"
	tipdesc = "其输入view的作用描述"
	tipdesc = tipdesc.decode("utf-8").encode('gb2312')
	print(tipdesc)
	desc = raw_input()
	desc = desc.decode('gb2312').encode('utf-8')
    
	modeviewfile = open(modeviewpath,"r+")
	modeviewstr = modeviewfile.read()
	modeviewfile.close()

	firstbigview_1 = viewname[0]

	firstbig_modulename = modulename[0].upper()+modulename[1:]
	firstbigViewname = firstbigview_1.upper()+viewname[1:]
	destdir = currpath+"\\..\\..\\src\\gamecore\\modules\\"+modulename+"\\"

	viewpath = destdir+"\\"+firstbigViewname+".lua"

	fileview = open(viewpath,"w+")
	viewstr  = modeviewstr.replace("#name",yourshortname)
	viewstr  = viewstr.replace("#time",nowtime)
	viewstr  = viewstr.replace("#parent",parent)
	viewstr  = viewstr.replace("#modulenameModel",firstbig_modulename+"Model")                           
	viewstr  = viewstr.replace("#modulename",firstbigViewname)
	viewstr  = viewstr.replace("#littlemodulename",modulename)
	viewstr  = viewstr.replace("#yourshortname",yourshortname)
	viewstr  = viewstr.replace("#desc",desc)
	fileview.write(viewstr)
	fileview.close()
	print("creatviewsuccess")
else: 
	#createmode
	#print("please input modename")
	tipmodename = "请输入模块名"
	tipmodename=tipmodename.decode("utf-8").encode('gb2312')
	print(tipmodename)
	modename=raw_input()
	tipviewinheritace = "请输入view要继承类如果输入字符(1)继承BasePanel其他的是(baseLayer)"
	tipviewinheritace=tipviewinheritace.decode('utf-8').encode('gb2312')
	print(tipviewinheritace)
	parentselect = raw_input()
	parent = None
	if parentselect == '1':
		parent = "BasePanel"
	else:
		parent = "BaseLayer"
	tipviewdesc = "其输入view的作用描述"
	tipviewdesc=tipviewdesc.decode('utf-8').encode("gb2312")
	print(tipviewdesc)
	desc = raw_input() 
	desc = desc.decode('gb2312').encode('utf-8')

	lowmodename = modename[0].lower()+modename[1:]
	print("lowmodename:"+lowmodename)
	firstbigmodename = modename[0].upper()+modename[1:]
	print("firstbigmodename:"+firstbigmodename)

	destdir = currpath+"\\..\\..\\src\\gamecore\\modules\\"+lowmodename
	if os.path.exists(destdir)==False:
		os.mkdir(destdir)

	allbigmodulename = firstbigmodename.upper()
	print("allbigmodulename:"+allbigmodulename)
	eventtype ="OPEN_CLOSE_"+allbigmodulename+"_VIEW"

# viewchange
	modeviewfile = open(modeviewpath,"r+")
	modeviewstr = modeviewfile.read()
	modeviewfile.close()


	viewname = firstbigmodename+"View"
	viewfile = destdir+"\\"+viewname+".lua"

	fileview = open(viewfile,"w")
	viewstr  = modeviewstr.replace("#name",yourshortname)
	viewstr  = viewstr.replace("#time",nowtime)
	viewstr  = viewstr.replace("#parent",parent)
	viewstr  = viewstr.replace("#modulename",firstbigmodename)
	viewstr  = viewstr.replace("#littlemodulename",lowmodename)
	viewstr  = viewstr.replace("#yourshortname",yourshortname)
	viewstr  = viewstr.replace("#allbigmodulename",eventtype)	
	viewstr  = viewstr.replace("#desc",desc)
	fileview.write(viewstr)
	fileview.close()

# moduechange
	Modelmodefile = open(modulesPath,"r")
	Modelstr = Modelmodefile.read()
	Modelmodefile.close()

	Modelname = firstbigmodename+"Model"
	Modelfile = destdir+"\\"+Modelname+".lua"
	filemodel = open(Modelfile,"w")
	Modelstr  = Modelstr.replace("#name",yourshortname)
	Modelstr  = Modelstr.replace("#time",nowtime)
	Modelstr  = Modelstr.replace("#modulename",firstbigmodename)
	filemodel.write(Modelstr)
	filemodel.close()

# initchange
	modeinitfile  = open(initpath,"r")
	initstr =  modeinitfile.read()
	modeinitfile.close()

	initfile = destdir+"\\"+"__init__.lua"
	fileint = open(initfile,"w")
	initstr = initstr.replace("#littlemodulename",lowmodename)
	initstr = initstr.replace("#modulename",firstbigmodename)
	fileint.write(initstr)
	fileint.close()
# controlchage
	modecontrollfile = open(modecontrollpath,"r+")
	modecontrollstr = modecontrollfile.read()
	modecontrollfile.close()

	controllername = firstbigmodename+"Controller"
	controllerfile = destdir+"\\"+controllername+".lua"

	filecontrol = open(controllerfile,"w")
	modecontrollstr  = modecontrollstr.replace("#name",yourshortname)
	modecontrollstr  = modecontrollstr.replace("#time",nowtime)
	modecontrollstr  = modecontrollstr.replace("#littlemodulename",lowmodename)
	modecontrollstr  = modecontrollstr.replace("#modulename",firstbigmodename)
	modecontrollstr  = modecontrollstr.replace("#allbigmodulename",eventtype)	
	filecontrol.write(modecontrollstr)
	filecontrol.close()

# allmodulinit
	initmanagerpath = currpath+"\\..\\..\\src\\gamecore\\modules\\__init__.lua"
	initmanagerfile = open(initmanagerpath,"r+")
	initmanagerstr = initmanagerfile.read()

	pos = initmanagerstr.find("}")
	print("initmanagerstr:"+str(pos))

	insertpath = "  \"gamecore/modules/"+lowmodename+"/__init__"+"\","
	newinitmanagerstr = initmanagerstr[0:(pos-1)]+"\n"+insertpath+"\n"+initmanagerstr[pos:len(initmanagerstr)]
	initmanagerfile.truncate()
	initmanagerfile.seek(0)
	initmanagerfile.write(newinitmanagerstr)
	initmanagerfile.close()

# eventype
	eventypepath = currpath+"\\..\\..\\src\\gamecore\\manager\\EventType.lua"
	eventypefile = open(eventypepath,"r+")
	eventypestr = eventypefile.read()

	pos = eventypestr.find("}")
	print("eventypestr:"+str(pos))
	insertpath ="\n    --------------------------------------\n    ---"+firstbigmodename+":"+desc+"\n"+"    --------------------------------------\n"
	insertpath +="     OPEN_CLOSE_"+allbigmodulename+"_VIEW = 0,"
	neweventypestr = eventypestr[0:(pos-1)]+"\n"+insertpath+"\n"+eventypestr[pos:len(eventypestr)]
	eventypefile.truncate()
	eventypefile.seek(0)
	eventypefile.write(neweventypestr)
	eventypefile.close()
	print("creatmodulsuccess")


#luastudiopath = currpath+"\\..\\mobeluastudio\\mobeluastudio.luaprj"
"""if os.path.isfile(luastudiopath):
	print("luastudiopath_isexist")
	stdiofile = open(luastudiopath,"r+")
	#stdiofilestr = stdiofile.read()
	tree =ET.ElementTree()
	tree.parse(stdiofile)

	root = tree.getroot()
	print("root:")
	print(root)
	for fiter in root.iter("Filter"):
	    #root.findall("Filter"):
		name = fiter.get("Name")
		Directory = fiter.get("Directory")
		print("gotofiter:"+name)
		if name =="modules" and Directory.find("work\src\modules") != -1:

			print("gotomodules")
			defaultindex = 0
			print("defaultindex"+str(defaultindex))
			for sonfilter in fiter.iter("Filter"):
				name2 = sonfilter.get("Name")
				print("name2:"+name2)
				print("compare two name"+str(cmp(lowmodename,name2)))
				hasInsert = None
				defaultindex = defaultindex+1
				if cmp(lowmodename,name2) == -1:
					print("gotoaddelement_1")
					direct = ".\..\mobile\work\src\modules\\"
					element = ET.SubElement(fiter,"Filter",{"Name":lowmodename,"Directory":(direct+lowmodename)})
			
					fiter.insert(defaultindex,element)
					ET.dump(fiter) 
					direct_control = direct +lowmodename +"\\" +controllername+".lua"
					direct_view = direct + lowmodename + "\\"+viewname + ".lua"
					sonelement_control = ET.SubElement(element,"LuaFile",{"RelativePath":direct_control})
					ET.dump(fiter) 
					sonelement_view = ET.SubElement(element,"LuaFile",{"RelativePath":direct_view} )
					hasInsert = True
					ET.dump(fiter) 
					break

			if hasInsert == True:
				break
			else:
				print("gotoaddelement_1")
				direct = ".\..\mobile\work\src\modules\\"
				element = ET.SubElement(fiter,"Filter",{"Name":lowmodename,"Directory":(direct+lowmodename)})
				
				fiter.insert(defaultindex,element)
				ET.dump(fiter) 
				direct_control = direct +lowmodename +"\\" +controllername+".lua"
				direct_view = direct + lowmodename +"\\"+ viewname + ".lua"
				sonelement_control = ET.SubElement(element,"LuaFile",{"RelativePath":direct_control})
				ET.dump(fiter) 
				sonelement_view = ET.SubElement(element,"LuaFile",{"RelativePath":direct_view})
				hasInsert = True
				ET.dump(fiter) 

				break
	tree.write(stdiofile)
	stdiofile.close()"""





    































