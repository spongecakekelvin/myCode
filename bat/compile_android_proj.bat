@echo off

::echo %cd%
::echo %~dp0
if not {%1}=={} (
	set tips=%1
)else (
	set tips=be ready to compile projects...
)
::echo %tips%
cd %~dp0\runtime-src

set /p var="## please fill in proj.android_jooyuu_[ ... ] :"
echo you will compile proj.android_jooyuu_%var%
pause

cocos compile -p android --ap 20 -g %var%

pause