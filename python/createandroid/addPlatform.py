#coding=utf-8

import sys
import os

def doPlatform(platform):
    #解释平台名为正式的命名格式。
    pnames = platform.split('_')
    i = 0
    for pn in pnames:
        pnames[i] = pn.capitalize()
        i = i+1
    i = None
    platformName = "".join(pnames)
    pnames = None
    #更新svn.
    os.system("svn up -q DataGlobal.lua")
    #读DataGlobal文件
    pffile = open("DataGlobal.lua")
    curAndroid = pffile.read()
    pffile.close()

    #判断是否已经添加过。
    if curAndroid.find(platform) <> -1:
        print "is all ready ,do not add again!!!"
        return False
    if platform.split("_")[0] == "zqgame":
		str = '''local chcqPlatform = {
    %s = true,'''%(platform)
		curAndroid = curAndroid.replace("local chcqPlatform = {",str)
		confile = open("DataGlobal.lua","w")
		contentlist = confile.write(curAndroid)
		confile.close()
		#提交svn
		os.system("svn ci -m "+platform+" DataGlobal.lua")

if __name__ == '__main__':
    if len(sys.argv)!=2:
        print "param is not two"
        sys.exit(1)

    platform = sys.argv[1]
    doPlatform(platform)
