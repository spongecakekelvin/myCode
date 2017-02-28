#coding=utf-8
# ----------------------------------------------------------------------------
# Author: YuZhenjian
# ----------------------------------------------------------------------------

import sys
import os
import shutil

currpath = os.getcwd()

argLen = len(sys.argv)
if argLen<2:
  print "param is not one"
  sys.exit()
print sys.argv


suffix = sys.argv[1] #e.g. uc_shenzuo
projectPath = currpath + "\\..\\..\\proj.android_" + suffix

def modify_xml():
    xmlpath = projectPath + "\\AndroidManifest.xml"

    readfile = open(xmlpath,"r+")
    xmlcontent = readfile.read()
    readfile.close()

    # print(xmlcontent)
    # modify the xml content
    xmlcontent  = xmlcontent.replace('''1111''','''2222''') # for example

    xmlfile = open(xmlpath,"w+")
    xmlfile.write(xmlcontent)
    xmlfile.close()


def copy_files():
    #删除不需要的文件夹
    if os.path.exists(projectPath+"\\libs\\armeabi"):
        shutil.rmtree(projectPath.replace("\\","/")+"/libs/armeabi")
        print "删除了libs/armeabi".decode('utf-8').encode("gb2312")

    if os.path.exists(projectPath+"\\libs\\x86"):
        shutil.rmtree(projectPath.replace("\\","/")+"/libs/x86")
        print "删除了libs/x86".decode('utf-8').encode("gb2312")

    if os.path.exists(projectPath+"\\libs\\mips"):
        shutil.rmtree(projectPath.replace("\\","/")+"/libs/mips")
        print "删除了libs/mips".decode('utf-8').encode("gb2312")

    #拷贝工程必要文件
    os.system("xcopy copyRes "+projectPath+"\\ /e /q /h /y")

    #移动assets到additional\assets目录
    os.system("xcopy "+projectPath+"\\assets "+projectPath+"\\additional\\assets\\ /e /q /h /y")

    #移动libs到additional\libs目录
    os.system("xcopy "+projectPath+"\\libs\\armeabi-v7a "+projectPath+"\\additional\\libs\\armeabi-v7a\\ /e /q /h /y")

def check_game_res():
    # 到目录\mobile\res\platform
    respath = projectPath+"\\..\\..\\..\\res\\platform"
    if not os.path.exists(respath+"\\"+suffix):
        if os.path.exists(respath+"\\debug"):
            os.system("xcopy "+respath+"\\debug "+respath+"\\"+suffix+"\\ /e /q /h /y")



if __name__ == "__main__":
    copy_files()
    # modify_xml()
    check_game_res()

    pass