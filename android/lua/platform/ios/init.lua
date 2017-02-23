-------初始化sdk相关的模块
require "gamecore/platform/ios/SdkLuaInterface"
require "gamecore/platform/ios/SdkLuaMsg"
require "gamecore/platform/ios/SdkLuaUtil"

function callSdkGlobalFun(valueStr)
	gprint("callSdkGlobalFun: ", valueStr)
    SdkLuaMsg.enter(valueStr)
end