#coding=utf-8
import sys
import os
import shutil

argLen = len(sys.argv)
if argLen<2:
	print "param is not one"
	sys.exit()
	
platform = sys.argv[1]

projectPath = "..\\sdks\\proj.android_"+platform
#拷贝工程必要文件
os.system("xcopy copyRes "+projectPath+" /e /q /h /y")

#移动assets到additional目录
os.system("xcopy "+projectPath+"\\assets "+projectPath+"\\additional\\assets /e /q /h /y")
shutil.rmtree(projectPath.replace("\\","/")+"/assets")

#删除不需要的文件夹
if os.path.exists(projectPath+"\\libs\\armeabi"):
	shutil.rmtree(projectPath.replace("\\","/")+"/libs/armeabi")

#调整libs以防被cocos打包脚本删除。
os.system("xcopy "+projectPath+"\\libs "+projectPath+"\\additional\\libs /e /q /h /y")
shutil.rmtree(projectPath+"\\libs")
os.system("md "+projectPath+"\\libs")


#改文件
manifestFiew = open(projectPath+"/AndroidManifest.xml")
manifestContent = manifestFiew.read()
manifestFiew.close()
#是qq平台时，需要另外加一些配置。
try:
	sdkName = platform.split('_')[1]
except Exception as e:
	sdkName = None
	
if sdkName and sdkName == 'qq':
	manifestContent = manifestContent.replace("<manifest",'''<manifest 
    xmlns:tools="http://schemas.android.com/tools"''')
	manifestContent = manifestContent.replace("</application>",'''	<activity android:name="org.cocos2dx.lua.AppActivity"
                  android:label="@string/app_name"
                  android:screenOrientation="portrait"
                  android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
                  android:configChanges="orientation"
                  tools:merge="override">
			<intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
			<intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
        
        <activity
            android:name="com.jooyuu.fusionsdk.SDKLaunchActivity"
            android:configChanges="keyboardHidden|orientation|screenSize"
            android:screenOrientation="landscape"
            android:theme="@android:style/Theme.NoTitleBar.Fullscreen" 
            tools:merge="override">
            
        </activity>
    </application>''')

manifestContent = manifestContent.replace('''<application''','''<uses-feature android:glEsVersion="0x00020000" />

	<application''')
confile = open(projectPath+"/AndroidManifest.xml","w")
manifestContent = confile.write(manifestContent)
confile.close()




