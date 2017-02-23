------------------------------------------------------
--作者: yhj
--日期: 2015年5月25日
--描述: 所有sdk的接口文件
------------------------------------------------------
local SdkInterface = class("SdkInterface")


function SdkInterface:ctor()
	hjprint("还没有实现接口")
end

function SdkInterface:isInit()
    return false
end
--------------------------------------
-- 扩展参数列表
--------------------------------------
function SdkInterface:getExtraParams()
    return {}
end

--------------------------------------
-- 设备id
--------------------------------------
function SdkInterface:getDeviceId()
    local facNo = ""
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform ==cc.PLATFORM_OS_ANDROID then
        facNo = getAndroidFacNo()
    else
        
    end
    
    return facNo
end

--------------------------------------
-- 登陆
--------------------------------------
function SdkInterface:login()
	hjprint("还没有实现接口")
end

function SdkInterface:setLoginCallback()
	hjprint("还没有实现接口")
end

function SdkInterface:setInitCallback()
	yzjprint("还没有实现接口")
end

function SdkInterface:setLogoutCallback()
	yzjprint("还没有实现接口")
end


--------------------------------------
-- 下线
--------------------------------------
function SdkInterface:logout()
	hjprint("还没有实现接口")
end

function SdkInterface:setLoginoutCallback()
	hjprint("还没有实现接口")
end

--------------------------------------
-- sdk自定按钮相关接口
--------------------------------------
function SdkInterface:isNeedShowCustomBtn()
	return false
end

function SdkInterface:getCustomBtnImg()
	return nil
end

function SdkInterface:customButtonHandler()
	hjprint("还没有实现接口")
end

--------------------------------------
-- 充值
--------------------------------------
function SdkInterface:pay(goodsId, num, money)
	hjprint("还没有实现接口")
end

function SdkInterface:setPayCallback()
	hjprint("还没有实现接口")
end


--------------------------------------
-- 获取ios设备令牌
--------------------------------------
function SdkInterface:getDeviceToken()
	return "noNeed"
end

--------------------------------------
-- 获取是否登陆
--------------------------------------
function SdkInterface:isLogined()
	hjprint("还没有实现接口")
end

function SdkInterface:getLoginToken()
	return "noNeed"
end

function SdkInterface:getUserName()
    hjprint("还没有实现接口")
end

function SdkInterface:getPlatformToken()
    hjprint("还没有实现接口")
end

function SdkInterface:getPlatformUid()
    hjprint("还没有实现接口")
end

--------------------------------------
-- 是否需要order后端生成orderid
--------------------------------------
function SdkInterface:isNeedOrderId()
	return false
end

function SdkInterface:isNeedShowYongfuzhongxin()
	return false
end

--------------------------------------
-- 登陆游戏后，可能需要给运营商提供数据
--------------------------------------
function SdkInterface:enterGameCallback()
	hjprint("没有实现（不需要则不用实现）， enterGameCallback")
end

--------------------------------------
-- 以下是android特殊的接口(监听java回调)
--------------------------------------
if GameGlobal.targetPlatform == cc.PLATFORM_OS_ANDROID then
	require "gamecore/platform/android/AndroidMessageQueue"
	AndroidMessageQueue.init()
	
	function SdkInterface:sdkJavaListener(className, methodName, argTable)
		hjprint("android平台，请实现他")
	end

	local luaj
	luaj = require("luaj")

	--self:callJavaStaticMethod("org/cocos2dx/lua/AppActivity", "login", {"name", age,...})
	function SdkInterface:callJavaStaticMethod(className, methodName, argTable, sig)
		assert(type(argTable) == "table", "调用java参数必须为table")

		local ok, ret = luaj.callStaticMethod(className, methodName, argTable, sig)
		if not ok then
			yzjprint("SDK:lua call java <<" .. methodName ..">>  call return error = ", ret)
			return ret
		else
			yzjprint("SDK:lua call java <<" .. methodName ..">> return succ = ", ret )
			return ret
		end
	end

	function SdkInterface:getStringFromJavaWithEmptyParam(className,methodName)
		local args ={}
		local sig = "()Ljava/lang/String;"

		-- 调用方法并获得返回值
		local ok, ret = luaj.callStaticMethod(className,methodName, args, sig)

		if not ok then
			hjprint("SDK:lua call java <<" .. methodName ..">>  call return error = ", ret)
			return ret
		else
			hjprint("SDK:lua call java <<" .. methodName ..">> return succ = ", ret )
			return ret
		end
	end

	local restartTipPanel
	function SdkInterface:exitGame(msg)
		msg = msg or "游戏里切换账号需要退出游戏，自动退出后请重新打开游戏"
		if ui.isExist(restartTipPanel) then
			return
		end

		local yes =ui.newBlueButton("退出游戏")
		yes:onClick(nil, function()
			self:callJavaStaticMethod("org/cocos2dx/lib/Cocos2dxActivity", "exitGameNow", {})
		end)

		restartTipPanel = ui.createAlertView(nil, false, "restart", msg,
		nil, false, true, {
			yes
		})
		restartTipPanel.close:setVisible(false)
		restartTipPanel.closeHandler = function(view)
		end
	end
	
	local function tab2strBySeq(tab, seq)
		local res = ""
		for i = 1, #tab do
			res = res .. tab[i] .. seq
		end
		hjprint(res)
		return res
	end
	function SdkInterface:payNow(tab, str1, str2)
		self:callJavaStaticMethod("com/jooyuu/sdk/CommonSdk", "pay",{tab2strBySeq(tab, "#"), str1 or "", str2 or  ""})
	end
end


return SdkInterface