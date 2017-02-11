#coding=utf-8

import sys
import os
import ParamUtil
import addConfig
import addPlatform
argLen = len(sys.argv)
if argLen < 2:
	print "param should more than one"
	sys.exit(1)
curpath = os.getcwd()
	
platform = sys.argv[1]

needCompile = True #是否编译项目。
if argLen >2:
	needCompile = not(sys.argv[2] == "False")
	
vcode = "1.0.1.24656"
if argLen>3:
	vcode = sys.argv[3]

#config 目录
os.chdir("./../../config/templet")
addConfig.doConfig(platform,vcode)
os.chdir(curpath)
print("config templte done!!!")

#config_chcq 目录
os.chdir("./../../config_chcq/templet")
addConfig.doConfig(platform,vcode)
os.chdir(curpath)
print("config_chcq templte done!!!")

#gamecode 目录
os.chdir("./../../src/gamecore")
addPlatform.doPlatform(platform)
os.chdir(curpath)
print("gamecode done!!!")


#拷贝平台资源（背景图）
os.chdir("./../../res/platform")
res = platform.split("_")[2]
os.system("md "+platform)
if not os.path.exists(res):#检查是否有相应的游戏的模板。
	istr = "停止请按：n"
	inputstr = raw_input(istr.decode("utf-8").encode("gb2312"))
	if inputstr.lower() == 'n':
		sys.exit(1)
os.system("xcopy "+res+" "+platform+" /e /q /h /y")
if platform.split('_')[1] == 'qq':
	os.system("xcopy qq_res "+platform+" /e /q /h /y")
#提交svn.
os.system("svn add --force "+platform)
os.system("svn ci -m addplatform:"+platform+" "+platform)
os.chdir(curpath)
print("copy res done!!!")
os.chdir(curpath)

os.chdir("./../../res_chcq/platform")
res = platform.split("_")[2]
os.system("md "+platform)
os.system("xcopy "+res+" "+platform+" /e /q /h /y")
if platform.split('_')[1] == 'qq':
	os.system("xcopy qq_res "+platform+" /e /q /h /y")
#提交svn.
os.system("svn add --force "+platform)
os.system("svn ci -m addplatform:"+platform+" "+platform)
os.chdir(curpath)
print("copy res done!!!")
os.chdir(curpath)

#改config.json
os.chdir("./../../config/templet")
ParamUtil.doreplace("config.json",['''"gameplatform": "([0-9a-zA-Z_]+)"'''],[platform])
os.chdir(curpath)

#拷贝assets
if os.path.exists(".\\..\\..\\frameworks\\runtime-src\\proj.android_"+platform+"\\additional\\assets"): 
	os.system("xcopy assets .\\..\\..\\frameworks\\runtime-src\\proj.android_"+platform+"\\additional\\assets"+" /e /q /h /y")

#编译工程。
if needCompile:
	os.chdir("./../../frameworks/runtime-src")
	os.system("cocos compile -p android --ap 20 --ndk-mode none -g "+platform)
	os.chdir(curpath)
	print("compile project done!!!")
os.chdir(curpath)
