# encoding: UTF-8
#Timer（定时器）是Thread的派生类，
#用于在指定时间后调用一个方法。

import os
import sys
import urllib
import urllib2
reload(sys)
sys.setdefaultencoding("utf-8")
# import simplejson as json
import json
import platform
import datetime

currpath = os.getcwd() #当前目录

API_KEY = '1147521808'
KEYFORM = 'KelvinDemo-001'


def GetTranslate(txt):
    url = 'http://fanyi.youdao.com/openapi.do'
    data = {
    'keyfrom': KEYFORM,
    'key': API_KEY,
    'type': 'data',
    'doctype': 'json',#json jsonp xml 
    'version': 1.1,
    'q': txt
    }
    data = urllib.urlencode(data)
    url = url+'?'+data
    req = urllib2.Request(url)
    response = urllib2.urlopen(req)
    result = json.loads(response.read())
    return result


def Sjson(json_data):
    basic = json_data.get('basic','')
    log_word_explains = ''
    # 更多释义
    if basic:
        explains = basic.get('explains',[])
        for obj in explains:
            log_word_explains = obj
            break
    return log_word_explains


class translateUtils:

    def init():

    def tanslate(txt):
        return Sjson(GetTranslate(txt))


translateUtils.init()
