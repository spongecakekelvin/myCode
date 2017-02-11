#coding=utf-8

import sys
import os

def doConfig(platform,versionCode):

    #更新svn.
    os.system("svn up -q currentandroid.xml platstartversion.xml")

    #读curtandroid文件
    pffile = open("currentandroid.xml")
    curAndroid = pffile.read()
    pffile.close()

    #判断是否已经添加过。
    if curAndroid.find(platform) <> -1:
        print "is all ready ,do not add again!!!"
        return False
        
    str = '''<file name="%s" cmd = "%swaiwangpublish.sh"/>
    </root>'''%(platform,platform)
    curAndroid = curAndroid.replace("</root>",str)

    confile = open("currentandroid.xml","w")
    contentlist = confile.write(curAndroid)
    confile.close()



    #读platstartversion文件
    pffile = open("platstartversion.xml")
    curAndroid = pffile.read()
    pffile.close()

    str = '''<file name="%s" version="%s" mainver="1.0.1"/>
    </root>'''%(platform,versionCode)
    curAndroid = curAndroid.replace("</root>",str)

    confile = open("platstartversion.xml","w")
    contentlist = confile.write(curAndroid)
    confile.close()

    #提交svn
    os.system("svn ci -m "+platform+" currentandroid.xml platstartversion.xml")

if __name__ == '__main__':
    if len(sys.argv)<2:
        print "param should more then two"
        sys.exit()
    
    platform = sys.argv[1]
    vcode = "1.0.1.22620"
    if len(sys.argv)>2:
        vcode = sys.argv[2]
    doConfig(platform,vcode)