# -*- coding: utf-8 -*-

import os
# import translateUtils

readmeName = 'readme.txt'
# currpath = os.getcwd() #当前目录
currpath = 'E:\st5_svn\mobile\src'
# currpath = 'I:\Dont.Starve.Shipwrecked.CHS.HD\dont_starve\data\scripts'
fileName = 'graphics_'+os.path.basename(currpath)+'.txt'


def genMultiChar(count):
  tab = []
  for i in range(1, count):
    tab.append('│')
    tab.append('  ')
  tab.append('├')
  tab.append('─')
  # print tab
  tabStr = "".join(tab[0:-1])
  return tabStr.decode('utf-8').encode('gb2312')


def parseDirStr(dirPath):
  level = 1
  lineStr = ''
  readme = ''
  # print dirPath
  dirLevels = {}

  for parent, dirNames, fileNames in os.walk(dirPath): #三个参数：分别返回1.父目录 2.所有文件夹名字（不含路径） 3.所有文件名字
    baseParentName = os.path.basename(parent)
    readme = ''
    for fileName in fileNames:
      if fileName == readmeName:
        filestream = open(parent+'\\'+fileName,"r")
        readme = filestream.read().replace('\n', '')
        filestream.close()

    if not readme:
      readme = baseParentName
      # readme = translateUtils.translate(baseParentName)

    if not baseParentName in dirLevels.keys():
      dirLevels[baseParentName] = level

    for dirName in dirNames:
      if not dirName in dirLevels.keys():
        dirLevels[dirName] = dirLevels[baseParentName] + 1

    lineStr = lineStr + genMultiChar(dirLevels[baseParentName]) + baseParentName + '\n' # + '\t#' + readme+ '\n'
    print "----------------------------------",baseParentName, dirLevels[baseParentName]

    if len(fileNames) > 0 :
      filesChars = genMultiChar(dirLevels[baseParentName]+1) 
      limitCount = 0
      for fileName in fileNames:
        limitCount = limitCount + 1
        if limitCount>3:
          lineStr = lineStr + filesChars + '...' + '\n'
          break
        else:
          lineStr = lineStr + filesChars + fileName + '\n'

  print lineStr
  # print dirLevels
  return lineStr





def makeGraphics():
  contentStr = parseDirStr(currpath)
  filestream = open(fileName,"w")
  filestream.write(contentStr)
  filestream.close()
  pass

if __name__ == '__main__':
	makeGraphics()