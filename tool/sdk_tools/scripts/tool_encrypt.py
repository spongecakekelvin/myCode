# -*- coding: utf-8 -*-
# Author:xiaohei
# CreateTime:2014-10-25
#
# The main operation entry for channel select and one thread.
#

import sys
import config_utils
import file_utils
import os
import os.path
import time
import AzDG

try: input = raw_input
except NameError: pass

def main():
    
    file_utils.printF("-------------------------encrypt config start------------------------")
    channels = config_utils.getAllChannels()
   
   # 循环获取每个channel,将每个channel的属性经过AzDG加密,输出为以channel_name为名的xml文件,并复制该xml文件到path属性下
    for channel in channels:    
        chnXml = config_utils.genChannelParamsXml(channel)
        sdkDemoPath = chnXml.getAttribute("path")
        chnXml.removeAttribute("path") ##不传递给sdk代码
        
        azdg = AzDG.AzDG()
        jsonStr = config_utils.xmltojson(chnXml.toprettyxml().encode())
        m = azdg.encode(jsonStr)  # 存储加密后的json文本
        
        fileDir = os.path.dirname(file_utils.curDir) + "\\" + sdkDemoPath
        if os.path.exists( fileDir ):
            path = fileDir + "\\assets\\" + "fssdk_config"
            file_utils.setFileContent(m, path)
            file_utils.printF("* save encrypt config : %s", sdkDemoPath + "\\assets\\")

            path = fileDir + "\\additional\\assets\\" + "fssdk_config"
            file_utils.setFileContent(m, path)
            file_utils.printF("* save encrypt config : %s", sdkDemoPath + "\\additional\\assets\\")
                
                # 解密
                # content = azdg.decode(m)
                # file_utils.setFileContent(content, file_utils.curDir + "\\" + param.getAttribute("value") + ".txt")

    file_utils.printF("-------------------------encrypt config over------------------------\r\n\r\n")
    
if __name__ == '__main__':
    main()