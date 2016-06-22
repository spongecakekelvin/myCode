  # -*- coding: utf-8 -*-
# Author:xiaohei
# CreateTime:2014-10-25
#
# All file operations are defined here
import sys
import os
import os.path
import file_utils
import xmltodict
import json
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import SubElement
from xml.etree.ElementTree import Element
from xml.etree.ElementTree import ElementTree

def xmltojson(xmlStr):
    convertedDict = xmltodict.parse(xmlStr);
    return json.dumps(convertedDict);

def getAllChannels():
    """
        get all channels
    """
    configFile = file_utils.getFullPath("channels_config.xml")
    try:
        tree = ET.parse(configFile)
        root = tree.getroot()
    except Exception as e:
        print("can not parse channes_config.xml.path:%s", configFile)
        return None

    channelsNode = root.find('channels')
    if channelsNode == None:
        return None

    channels = channelsNode.findall('channel')

    if channels == None or len(channels) <= 0:
        return None
    
    return channels

def genChannelParamsXml(node):  
    import xml.dom.minidom  
    impl = xml.dom.minidom.getDOMImplementation()  
    dom = impl.createDocument(None, 'xml', None)  
    root = dom.documentElement    
    channel = dom.createElement('channel')  
    root.appendChild(channel)  
    for attr in node.attrib: #属性
        #属性名全部小写
        channel.setAttribute( attr.lower(), node.get(attr))

    params = node.findall("param")
    for cParam in params:
        key = cParam.get('name').lower() #参数名统一为小写
        val = cParam.get('value')
        nameE = dom.createElement(key)  
        nameE.appendChild(dom.createTextNode(val))
        channel.appendChild(nameE)
    
#     channel.childNodes[0].txt
    
    return channel
  
