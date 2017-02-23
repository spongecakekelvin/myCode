--
-- Created by IntelliJ IDEA.
-- User: chengshitian
-- Date: 2015-01-06
-- Time: 11:16
-- To change this template use File | Settings | File Templates.
--

--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--             佛祖保佑       永无BUG             --
module("AndroidInteractive", package.seeall)

local luaj
if GameGlobal.targetPlatform== cc.PLATFORM_OS_ANDROID then
    luaj = require("luaj")
end

function callJavaMethod(className, methodName, argTable)
	-- 调用方法并获得返回值
	local ok, ret = luaj.callStaticMethod(className, methodName, argTable)
	if not ok then
		hjprint("SDK:lua call java <<" .. methodName ..">>  call return error = ", ret)
		return ret
	else
		hjprint("SDK:lua call java <<" .. methodName ..">> return succ = ", ret )
		return ret
	end
end

--isNetConnected
function getBooleanFromJavaWithEmptyParam(method)

--    local args = nil
    local args ={}
    local sig = "()Z"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("getBooleanFromJavaWithEmptyParam  " .. method .."  call return error = ", ret )
        return false
    else
        ccprint("getBooleanFromJavaWithEmptyParam  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function getIntFromJavaWithEmptyParam(method)

--    local args = nil
    local args ={}
    local sig = "()I"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("getIntFromJavaWithEmptyParam  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("getIntFromJavaWithEmptyParam  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function getStringFromJavaWithEmptyParam(method)

    local args ={}
    local sig = "()Ljava/lang/String;"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("getStringFromJavaWithEmptyParam  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("getStringFromJavaWithEmptyParam  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function getVoidFromJavaWithEmptyParam(method)

    local args ={}
    local sig = "()V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity",method, args, sig)

    if not ok then
        ccprint("getVoidFromJavaWithEmptyParam  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("getVoidFromJavaWithEmptyParam  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function sina17gOpenBindPanel()

    local args ={}
    local sig = "()V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("com/jooyuu/GameUtil","initBindAccountEvent", args, sig)

    if not ok then
        ccprint("sina17gOpenBindPanel  initBindAccountEvent  call return error = ", ret )
        return ret
    else
        ccprint("sina17gOpenBindPanel  initBindAccountEvent  call return succ = ", ret )
        return ret
    end

end

--function getLongFromJavaWithEmptyParam(method)
--
----    local args = nil
--    local args ={}
--    local sig = "()J"
--
--    -- 调用方法并获得返回值
--    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)
--
--    if not ok then
--        ccprint("getLongFromJavaWithEmptyParam  " .. method .."  call return error = ", ret )
--return ret
--    else
--        ccprint("getLongFromJavaWithEmptyParam  " .. method .."  call return succ = ", ret )
--        return ret
--    end
--
--end

function rebootApp()
    local args ={}
    local sig = "()V"
    
    local    url = "org/cocos2dx/lib/Cocos2dxActivity"
    local    methodName = "rebootApp"
--    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "restartGame", args, sig)
    local ok, ret = luaj.callStaticMethod(url, methodName, args, sig)

    if not ok then
         ccprint("rebootApp  call return error = ", ret )
        return ret
    else
        ccprint("rebootApp  call return succ = ", ret )
        return ret
    end
end 

function rebootApp1()
    local args ={}
    local sig = "()V"
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","restartGame", args, sig)

    if not ok then
         ccprint("rebootApp1  call return error = ", ret )
        return ret
    else
        ccprint("rebootApp1  call return succ = ", ret )
        return ret
    end
end



function uploadLogFile()
    if DataGlobal.gamePlatForm~="all" then
        return
    end

    local args ={}
    local sig = "()V"
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","uploadLogFile", args, sig)

    if not ok then
        ccprint("uploadLogFile  call return error = ", ret )
        return ret
    else
        ccprint("uploadLogFile  call return succ = ", ret )
        return ret
    end
end


function manulAndroidCrash()
    local test  = cc.Scale9Sprite:create("")
    test:haha()
    ui.addChild(LayerManager.topLayer,test)
--    local args ={}
--    local sig = "()V"
--    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","xxxxxxx", args, sig)
--
--    if not ok then
--        ccprint("xxxxxxx  call return error = ", ret )
--        return ret
--    else
--        ccprint("xxxxxxx  call return succ = ", ret )
--        return ret
--    end
end

function setCallbackForJava(method,fun)

    --    local args = nil
    local args ={fun}
    local sig = "(I)V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("setCallbackForJava  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("setCallbackForJava  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function get_file_md5(filepath)

    --    local args = nil
    local args ={filepath}
    local sig = "(Ljava/lang/String;)Ljava/lang/String;"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","getFileMD5", args, sig)

    if not ok then
        ccprint("get_file_md5   call return error = ", ret )
        return ret
    else
        ccprint("get_file_md5   call return succ = ", ret )
        return ret
    end

end



function setStringParamToJava(method,str)

    --    local args = nil
    local args ={str}
    local sig = "(Ljava/lang/String;)V"
--    selfsetRequestedOrientation
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("setStringParamToJava  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("setStringParamToJava  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function getStringByStringParamToJava(method,str)

    --    local args = nil
    local args ={str}
    local sig = "(Ljava/lang/String;)Ljava/lang/String;"
--    selfsetRequestedOrientation
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("setStringParamToJava  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("setStringParamToJava  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function setIntParamToJava(method,intParam)

    --    local args = nil
    local args ={intParam}
    local sig = "(I)V"
--    selfsetRequestedOrientation
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity",method, args, sig)

    if not ok then
        ccprint("setIntParamToJava  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("setIntParamToJava  " .. method .."  call return succ = ", ret )
        return ret
    end

end

function setPushMessage(title,message, delalt, key, repeats)

    --    local args = nil
    local args ={title,message, delalt, key, repeats}
    local sig = "(Ljava/lang/String;Ljava/lang/String;III)V"
--    selfsetRequestedOrientation
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","addNoticfy", args, sig)

    if not ok then
        ccprint("setPushMessage  addNoticfy  call return error = ", ret )
        return ret
    else
        ccprint("setPushMessage  addNoticfy  call return succ = ", ret )
        return ret
    end

end





function androidOnResume()
    ccprint("androidOnResume")

    NetManager.removeReconnectPanelAndConnect()
    
    Helper.throwEvent(EventType.ANDROID_ON_RESUME, {})
end


function androidOnPause()
    ccprint("androidOnPause")
    Helper.throwEvent(EventType.ANDROID_ON_PAUSE, {})
end

function registerToJava()
    setCallbackForJava("registerLuaCallbackOnPause",androidOnPause)
    setCallbackForJava("registerLuaCallbackOnResume",androidOnResume)

end

function netMonitor(status)
    ccprint("netMonitor" .. status)
end

local function calSize(size) 	
    if size >=1024 then
        return string.format("%.2fG", size/1024)
    else
        return string.format("%.2fM", size)
    end
end

--function getDeviceInf()
--    local result = getStringFromJavaWithEmptyParam("getDeviceInf")
--    ccprint (result)
--end

function test()

    local size = nil
    setCallbackForJava("registerNetMonitor",netMonitor)
    ccprint("bool")

    ccprint(GameGlobal.msd:isNetConnected("isNetConnected"))
    ccprint(GameGlobal.msd:isNetConnected("isWifiConnected"))
    ccprint(GameGlobal.msd:isNetConnected("isMobileConnected"))
    ccprint(GameGlobal.msd:isNetConnected("ExistSDCard"))

    ccprint(GameGlobal.msd:getMobileSubType())
    ccprint(GameGlobal.msd:getConnectedType())


    ccprint("int")
    size = GameGlobal.msd:jniReturnIntNoParam("getExternalStorageAvailableSize")
    ccprint(size)
    if size>=0 then
        ccprint(calSize(size))
    end
    size = GameGlobal.msd:jniReturnIntNoParam("getInternalStorageAvailableSize")
    ccprint(size)
    if size>=0 then
        ccprint(calSize(size))
    end
--    ccprint(GameGlobal.msd:jniReturnIntNoParam("getExternalStorageAvailableSize"))
--    ccprint(GameGlobal.msd:jniReturnIntNoParam("getInternalStorageAvailableSize"))


    getBooleanFromJavaWithEmptyParam("isNetConnected")
    getBooleanFromJavaWithEmptyParam("isWifiConnected")
    getBooleanFromJavaWithEmptyParam("isMobileConnected")
    getBooleanFromJavaWithEmptyParam("ExistSDCard")


    getIntFromJavaWithEmptyParam("getMobileSubType")
    getIntFromJavaWithEmptyParam("getConnectedType")
    getIntFromJavaWithEmptyParam("getDisplayRotation")
    size = GameGlobal.msd:jniReturnIntNoParam("getDisplayRotation")
    ccprint(size)

--    getIntFromJavaWithEmptyParam("getSDFreeSize")
--    getIntFromJavaWithEmptyParam("getSDAllSize")
      size= getIntFromJavaWithEmptyParam("getExternalStorageAvailableSize")
    if size>=0 then
        ccprint(calSize(size))
        end
    size = getIntFromJavaWithEmptyParam("getInternalStorageAvailableSize")
    if size>=0 then
        ccprint(calSize(size))
    end


    setIntParamToJava("selfsetRequestedOrientation",6)

end

function scanQrCode(  accountName, platformName,  loginForwardUrl,  ext,  loginApiUrl, signKey,gameID,serverID,callbackid)
    local args ={accountName, platformName,  loginForwardUrl,  ext,  loginApiUrl, signKey,gameID,serverID,callbackid}
    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;III)V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","scanQrCode", args,sig)

    if not ok then
        ccprint("scanQrCode call return error = ", ret )
        return false
    else
        ccprint("scanQrCode call return succ = ", ret )
        return ret
    end
end

function startScanQRLogin()
    local args ={}
    local sig = "()V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","startScanQRLogin", args, sig)

    if not ok then
        ccprint("startScanQRLogin call return error = ", ret)
        return false
    else
        ccprint("startScanQRLogin call return succ = ", ret)
        return ret
    end
end
