@echo off
"D:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:update /path:"G:\arpg_s3\mobile" /closeonend:2
"D:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:update /path:"G:\arpg_s3\arpgconfig" /closeonend:2
"D:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:update /path:"G:\arpg_s3\arpgserver" /closeonend:2
"D:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" /command:update /path:"G:\arpg_s3\arpgcehua_neiwang" /closeonend:2
::cd "G:\arpg_s3\mobile\tools\cfg_generater\"
::"mobile_arpg.exe" 123456 
