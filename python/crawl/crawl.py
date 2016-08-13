# -*- coding: utf-8 -*-
# Description:  test
# Author：yzj 2015.11.20
# http://www.cnblogs.com/fnng/p/3576154.html
'''
func api:
    open(filename, 'wb') .write(destContent) .close() #写入文件
    urllib.urlopen(url).read() #抓取网页的html
    urllib.urlretrieve(imgurl, resPath + '%02d.jpg' % x)  #下载图片到本地
'''


import urllib
import sys
import os
# import os.path
# import xlrd
# import fileinput
import re

reload(sys)
sys.setdefaultencoding('utf-8')
curDir = os.getcwd()


def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html

def getFullPath(filename):
    if os.path.isabs(filename):
        return filename
    currdir = curDir
    filename = os.path.join(currdir, filename)
    filename = filename.replace('\\', '/')
    filename = re.sub('/+', '/', filename)
    return filename


def getImg(imglist):
    resPath = getFullPath('res/')

    if not os.path.exists(resPath):
       os.makedirs(resPath)

    x = 1
    for imgurl in imglist:
        urllib.urlretrieve(imgurl, resPath + '%02d.jpg' % x)
        x+=1


def doTest():
    # url = "http://www.cnblogs.com/fnng/p/3576154.html"
    url = "https://mm.taobao.com/json/request_top_list.htm?page=2"
    # url = "https://www.baidu.com/"
    html = getHtml(url)
    destContent = html.decode('utf-8').encode('gb2312')

    filename = url.split("/")[-1]
    filename = filename.split('.')[0]
    filename = filename+ ".txt"
    print filename
    destfilestream = open(filename, 'wb')
    destfilestream.write(destContent)
    destfilestream.close()

    reg = r'img src="(.+\.png)"'
    imgre = re.compile(reg)
    imglist = re.findall(imgre,html)
    print imglist

    getImg(imglist)


def main():
    doTest()
    print "=================END ======================================="
    pass


if __name__=="__main__":
  
    main()



