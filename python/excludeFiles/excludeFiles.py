# -*- coding: utf-8 -*-
# 根据xml文件内容，删除res目录下的文件
# 作者：yzj 2016.1.14

import sys
import os
import os.path
from xml.dom import minidom

reload(sys)
sys.setdefaultencoding('utf-8')

currpath = os.getcwd()

# 被遍历的文件夹
filesDir = currpath + "\\res"
xmlDir = currpath + "\\config\\templet\\exclude10.xml"

excludeFileCache = []

def getXmlContent(fn):
    global excludeFileCache
    excludeFileCache = []
    fn = fn.replace("\\", "/")
    if os.path.exists(fn) and os.path.isfile(fn):
        xmldoc = minidom.parse(fn)
        for node in xmldoc.getElementsByTagName("file"):
            fn = os.path.abspath(node.getAttribute("name"))
            excludeFileCache.append(fn)
    # print excludeFileCache
    return excludeFileCache


def deleteFiles(filesDir):
    for fn in excludeFileCache:
        # print "check file = "+fn
        if os.path.isfile(fn):
           if os.path.exists(fn):
                print "deleted file ===== "+fn
                os.remove(fn)

def main():
    getXmlContent(xmlDir)
    deleteFiles(filesDir)


if __name__=="__main__":
  
    main()



