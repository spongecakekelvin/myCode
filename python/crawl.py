# -*- coding: utf-8 -*-
# Description:  test
# Author：yzj 2015.11.20

import urllib
import sys
import os
# import os.path
# import xlrd
# import fileinput
import re

reload(sys)
sys.setdefaultencoding('utf-8')


def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html

def doTest():
    url = "http://www.cnblogs.com/fnng/archive/2013/05/20/3089816.html"
    # html = getHtml("https://www.baidu.com/")
    filename = url.split("/")[-1]
    filename = filename.split('.')[0]
    filename = filename+ ".txt"
    print filename
    html = getHtml(url)
    
    destContent = html.decode('utf-8').encode('gb2312')

    destfilestream = open(filename, 'wb')
    destfilestream.write(destContent)
    destfilestream.close()

    # reg = r'src="(.+?\.png).+">'
    # imgre = re.compile(reg)
    # imglist = re.findall(imgre,html)
    # print imglist

def main():
    doTest()
    print "=================END ======================================="
    pass

if __name__=="__main__":
  
    main()



