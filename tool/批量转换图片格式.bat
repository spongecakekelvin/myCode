
@echo off
set TPPath="C:\Program Files (x86)\CodeAndWeb\TexturePacker\bin"
set SAVE_NAME=test
set PIXEL_FORMAT=RGB565
set IMG_PATH=C:\Users\Administrator\Desktop\tools\
set IMG_TYPE=jpg

set str=%IMG_PATH%
set cdto=%str:~0,2%
echo changeto:%cdto%
%cdto%
cd %IMG_PATH%

for /r "%IMG_PATH%\" %%a in (*.%IMG_TYPE%) do (
echo %%a
%TPPath%\TexturePacker --format cocos2d --data %%a.plist --sheet %%a.pvr.ccz --opt %PIXEL_FORMAT% --max-width 8192 --max-height 8192 --border-padding 0 --shape-padding 0 --premultiply-alpha %%a
)

pause