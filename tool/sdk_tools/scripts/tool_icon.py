# -*- coding: utf-8 -*-

import sys
import file_utils
import config_utils
import os
import os.path
import time
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import SubElement
from xml.etree.ElementTree import Element
from xml.etree.ElementTree import ElementTree
import xml.dom.minidom  
import subprocess

androidNS = 'http://schemas.android.com/apk/res/android'
def getAppIconName(dir):

    manifestFile = dir + "/AndroidManifest.xml"
    manifestFile = file_utils.getFullPath(manifestFile)
    ET.register_namespace('android', androidNS)
    tree = ET.parse(manifestFile)
    root = tree.getroot()

    applicationNode = root.find('application')
    if applicationNode is not None:
        return "icon"

    key = '{'+androidNS+'}icon'
    iconName = applicationNode.get(key)

    if not iconName:
        return "icon"

    name = iconName[10:]

    file_utils.printF("The game icon name is now %s", name)
    return name


def appendChannelIconMark(gameIconName, channelIconName, demoPath):
    from PIL import Image

    gameIconPath = file_utils.getFullPath('_icon/game_icon/' + gameIconName + '.png')
    if not os.path.exists(gameIconPath):
        file_utils.printF("Can not find game icon : %s", gameIconPath)
        return 1

    gameIcon = Image.open(gameIconPath)
    rlImg = gameIcon

    channelIconPath = file_utils.getFullPath('_icon/channel_icon/' + channelIconName + '.png')
    if os.path.exists(channelIconPath):
        markIcon = Image.open(channelIconPath)
        rlImg = appendIconMark(gameIcon, markIcon, (0, 0))

    # rlImg.show()

    drawbleSize = (48, 48)
    ldpiSize = (36, 36)
    mdpiSize = (48, 48)
    hdpiSize = (72, 72)
    xhdpiSize = (96, 96)
    xxhdpiSize = (144,144)

    drawbleIcon = rlImg.resize(drawbleSize, Image.ANTIALIAS)
    ldpiIcon = rlImg.resize(ldpiSize, Image.ANTIALIAS)
    mdpiIcon = rlImg.resize(mdpiSize, Image.ANTIALIAS)
    hdpiIcon = rlImg.resize(hdpiSize, Image.ANTIALIAS)
    xhdpiIcon = rlImg.resize(xhdpiSize, Image.ANTIALIAS)
    xxhdpiIcon = rlImg.resize(xxhdpiSize, Image.ANTIALIAS)

    sdkResPath = demoPath + '/res/'
    drawblePath = file_utils.getFullPath(sdkResPath + 'drawable')
    ldpiPath = file_utils.getFullPath(sdkResPath + 'drawable-ldpi')
    mdpiPath = file_utils.getFullPath(sdkResPath + 'drawable-mdpi')
    hdpiPath = file_utils.getFullPath(sdkResPath + 'drawable-hdpi')
    xhdpiPath = file_utils.getFullPath(sdkResPath + 'drawable-xhdpi')
    xxhdpiPath = file_utils.getFullPath(sdkResPath + 'drawable-xxhdpi')

    if not os.path.exists(drawblePath):
       os.makedirs(drawblePath)
        
    if not os.path.exists(ldpiPath):
        os.makedirs(ldpiPath)

    if not os.path.exists(mdpiPath):
        os.makedirs(mdpiPath)

    if not os.path.exists(hdpiPath):
        os.makedirs(hdpiPath)       

    if not os.path.exists(xhdpiPath):
        os.makedirs(xhdpiPath)  

    if not os.path.exists(xxhdpiPath):
        os.makedirs(xxhdpiPath)         

    gameIconName = getAppIconName(demoPath) + '.png'
    drawbleIcon.save(os.path.join(drawblePath, gameIconName), 'PNG' ,quality = 95)
    ldpiIcon.save(os.path.join(ldpiPath, gameIconName), 'PNG' ,quality = 95)
    mdpiIcon.save(os.path.join(mdpiPath, gameIconName), 'PNG' ,quality = 95)
    hdpiIcon.save(os.path.join(hdpiPath, gameIconName), 'PNG' ,quality = 95)
    xhdpiIcon.save(os.path.join(xhdpiPath, gameIconName), 'PNG' ,quality = 95)
    xxhdpiIcon.save(os.path.join(xxhdpiPath, gameIconName), 'PNG' ,quality = 95)

    return 0

def appendIconMark(imgIcon, imgMark, position):
    from PIL import Image
    if imgIcon.mode != 'RGBA':
        imgIcon = imgIcon.convert('RGBA')

    markLayer = Image.new('RGBA', imgIcon.size, (0,0,0,0))
    markLayer.paste(imgMark, position)

    return Image.composite(markLayer, imgIcon, markLayer) 

def doAppendIcon():
    
    
    #复制icons中的图片到game_icon中
    if os.path.exists(os.path.dirname(file_utils.curDir) + '/icons'):
        file_utils.copy_files(os.path.dirname(file_utils.curDir) + '/icons', file_utils.getFullPath('_icon/game_icon'))
    
    configFile = file_utils.getFullPath("channels_config.xml")
    dom = xml.dom.minidom.parse(configFile)  
    root = dom.documentElement
    channellist = root.getElementsByTagName('channel')
       
     #icon处理    
    for channel in channellist:
        
        #获取sdk_name和fs_app_id
        params = channel.getElementsByTagName("param")
        sdk_name = ""
        fs_app_id = ""
        for param in params:
            if "sdk_name" == param.getAttribute("name"):
                sdk_name = param.getAttribute("value")
            if "fs_app_id" == param.getAttribute("name"):
                fs_app_id = param.getAttribute("value")
        
        #判断是否有sdk对应的game icon
        if os.path.exists(file_utils.getFullPath("_icon/game_icon/" + fs_app_id + ".png")):
            #获取demo的res的path
            sdkDemoPath = channel.getAttribute('path')
            resDir = os.path.dirname(file_utils.curDir) + "/" + sdkDemoPath     
            
            #合并icon并存到res中
            if os.path.exists( resDir ):
                file_utils.printF("icon fusion : channel_icon:%s, game_icon:%s \r\n", fs_app_id, sdk_name)
                appendChannelIconMark(fs_app_id, sdk_name, resDir)
            # else:
                # file_utils.printF("can not find dir: %s", resDir)    
        
    
def installPIL():
     # 检查PIL安装了没
    pyScriptPath = file_utils.pythonDir + '/Scripts'
    if not os.path.exists(file_utils.pythonDir + '/Lib/site-packages/PIL'):
        file_utils.copy_files( file_utils.curDir + '/scripts/Lib_Pillow', pyScriptPath)      
        #安装 Pillow
        os.chdir(pyScriptPath)
        os.system('pip install ' + pyScriptPath + '/Pillow-3.0.0-cp27-none-win32.whl')
        
    #检查环境变量
    pathV = os.environ["PATH"]
    if not pyScriptPath in pathV:
        os.environ["PATH"]= pyScriptPath + ';' + os.environ["PATH"]
        
def main():
    
    file_utils.printF("-------------------------icon fusion start------------------------")
    #检查并安装PIL
    installPIL();
    #icon处理
    doAppendIcon();
    
    file_utils.printF("-------------------------icon fusion over------------------------\r\n\r\n")
    
if __name__ == '__main__':
    main()