# -*- coding: utf-8 -*-
# 替换目录下所有文件的关键字
# 作者：yzj 2015.11.20

import sys
import os
import os.path
import xlrd
import fileinput
import re

reload(sys)
sys.setdefaultencoding('utf-8')

currpath = os.getcwd()

# 被遍历的文件夹
# rootdir = currpath + "\\..\\..\\src" 
rootdir = currpath + "\\..\\..\\"

wordMap = []
gIndex = 1

def getWordMapFromExcel(fileName = "excelFile.xlsx"):
    try:
        data = xlrd.open_workbook(filename = currpath + "\\" + fileName, encoding_override="utf-8")
        table = data.sheet_by_name("Sheet1")
        nrows = table.nrows #行数 
        global wordMap
        wordMap = []

        for rownum in range(1, nrows): #跳过第一行 ，ps:从0开始
            row = table.row_values(rownum)
            wordMap.append([row[0], row[1]])

    except Exception,e:
        print str(e)


def checkWord(parent, fileName):
    isSucc = False
    # for line in fileinput.input(parent + "\\" + fileName, inplace=False):
    #     line2 = line.decode('utf-8')
    #     for data in wordMap:
    #         srcWord = data[0].decode('utf-8')
    #         if line2.find(srcWord) != -1 :
    #             isSucc = True
    #             break
    #     if isSucc:
    #         break

    f = open(parent + "\\" + fileName, "r")  
    while True:  
        line = f.readline()  
        if line:  
            pass    # do something here 
            line2 = line.decode('utf-8', 'ignore')
            for data in wordMap:
                srcWord = data[0].decode('utf-8', 'ignore')
                if line2.find(srcWord) != -1 :
                    isSucc = True
                    break
            if isSucc:
                break
        else:  
            break

    f.close()
    if isSucc:
        replaceWord(parent, fileName)


def replaceWord(parent, fileName):
    print parent + "\\" + fileName
    record = []
    #替换
    # inplace=True 重定向, print将输出到文件流中
    lineIndex = 1
    for line in fileinput.input(parent + "\\" + fileName, inplace=True):
        line = line.decode('utf-8', 'ignore')

        for data in wordMap:
          srcWord = data[0].decode('utf-8', 'ignore')
          if line.find(srcWord) != -1 :
              line = line.replace(srcWord, data[1].decode('utf-8', 'ignore'))
              # isSucc = True
              record.append([data[0], data[1], lineIndex])

        print line.encode('utf-8', 'ignore'), #输出到文件中
        lineIndex = lineIndex + 1

    # 打印替换信息
    global gIndex
    print "(" + str(gIndex) + ")========" +fileName+ "中匹配成功，替换关键字:".decode('utf-8').encode('gb2312')
    gIndex = gIndex + 1

    for data in record:
        print "\t" + str(data[2]) + "、 " + data[0] + "\t===> " + data[1]


def searchDir(dirPath):
    for parent, dirNames, fileNames in os.walk(dirPath):    #三个参数：分别返回1.父目录 2.所有文件夹名字（不含路径） 3.所有文件名字
          # print "===============正在搜索".decode('utf-8').encode('gb2312') + parent + "\n"
          for fileName in fileNames:
              # print (fileName)
              if os.path.splitext(fileName)[1] == '.lua':
              # if fileName == 'EventType.lpua':
                  checkWord(parent, fileName)

def main():
    global gIndex
    gIndex = 1
    getWordMapFromExcel()
    
    searchDir(rootdir + 'src')
    searchDir(rootdir + 'config')


if __name__=="__main__":
  
    main()



