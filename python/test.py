# -*- coding: utf-8 -*-
print (not '')
print (not [])
#False

import urllib
url = 'http://fanyi.youdao.com/openapi.do'
data = {
'keyfrom': 10000,
'key': 222222,
'type': 'data',
'doctype': 'json',
'version': 1.1,
'q': 'qqq'
}
data = urllib.urlencode(data)
url = url+'?'+data
print url

# print u'\uc560' #编码问题 会报错

code = '你好'
utf8code = code.decode('utf-8').encode('gb2312')
print code, type(code), repr(code), utf8code, repr(utf8code)
print type(str(123))
print str([1,2,3,5,7])
print str({'apple','banana','canada'})
print str(('apple','banana','canada'))
print type(('apple','banana','canada'))
print type({'apple','banana','canada'})
print type(repr([1,2,3,5,7])), type([1,2,3,5,7])