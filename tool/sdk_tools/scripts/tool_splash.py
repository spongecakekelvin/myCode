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
import shutil

def copyAndRenameImg(demoName, demoDir):
    splashDir = file_utils.curDir + '/_splashes/' + demoName
    demoResDir = demoDir + '/res/drawable-hdpi'
    #找图片,重命名,复制到destDir
    for i in range(1, 6):
        splashFullPath = demoResDir + '/' + 'game_splash_' + str(i) + '.png'
        if os.path.exists(splashFullPath):
            os.remove(splashFullPath)
            
        img_path = splashDir + '/' + str(i) + '.png'
        if os.path.exists(img_path):
            if not os.path.exists(demoResDir):
                os.makedirs(demoResDir)
            
            shutil.copy(img_path, splashFullPath)
            file_utils.printF("copy splash : %s", demoName + ': game_splash_' + str(i))   

def main():
    
    file_utils.printF("-------------------------copy splashes start------------------------")
    configFile = file_utils.getFullPath("channels_config.xml")
    dom = xml.dom.minidom.parse(configFile)  
    root = dom.documentElement
    channellist = root.getElementsByTagName('channel')
       
    for channel in channellist:

        sdk_name = ""
        params = channel.getElementsByTagName("param")
        for param in params:
            if "sdk_name" == param.getAttribute("name"):
                sdk_name = param.getAttribute("value")
                break
            
        demoDir = os.path.dirname(file_utils.curDir) + "/" + channel.getAttribute('path')            
        if os.path.exists( demoDir ):
            copyAndRenameImg(sdk_name, demoDir)
        #else:
        #    file_utils.printF("can not find dir: %s", demoDir)
            
    file_utils.printF("-------------------------copy splashes over------------------------\r\n\r\n")

    
if __name__ == '__main__':
    main()