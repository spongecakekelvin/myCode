@echo off

:: src
"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\src" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/src" /closeonend:2

:: runtime-src
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\frameworks\runtime-src" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/frameworks/runtime-src" /closeonend:2

:: java
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\frameworks\cocos2d-x\cocos\platform\android\java" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/frameworks/cocos2d-x/cocos/platform/android/java" /closeonend:2

:: res
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\res\platform" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/res/platform" /closeonend:2

:: sdk
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\sdk" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/sdk" /closeonend:2

::tools\cfg_generater
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\tools\cfg_generater" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/tools/cfg_generater" /closeonend:2

:: config
::"F:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:checkout /path:"J:\st5_b1\branch\code\0.2.8\config" /url:"http://st5b1.svn.com:8888/st5b1/release/branch/code/0.2.8/config" /closeonend:2

::cd "G:\arpg_s3\mobile\tools\cfg_generater\"
::"mobile_arpg.exe" 123456 
