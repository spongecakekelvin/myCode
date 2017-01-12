@echo off
::不同项目需要替换的项
::分支svn地址 http://st9.svn.com:8888/st9/release/branch/code/0.0.2
::分支迁出目录 J:\st9\branch\code\0.0.2

:: src
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\src" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/src" /closeonend:2

:: runtime-src
"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\frameworks\runtime-src" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/frameworks/runtime-src" /closeonend:2

:: res\platform
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\res\platform" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/res/platform" /closeonend:2

:: java
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\frameworks\cocos2d-x\cocos\platform\android\java" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/frameworks/cocos2d-x/cocos/platform/android/java" /closeonend:2

:: sdk
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\sdk" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/sdk" /closeonend:2

::tools\cfg_generater
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\tools\cfg_generater" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/tools/cfg_generater" /closeonend:2

:: config
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st9\branch\code\0.0.2\config" /url:"http://st9.svn.com:8888/st9/release/branch/code/0.0.2/config" /closeonend:2

::cd "G:\arpg_s3\mobile\tools\cfg_generater\"
::"mobile_arpg.exe" 123456 
