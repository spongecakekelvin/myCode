------------------------------------------------------
--作者:	lqk
--日期:	2015年1月27日
--描述:	Android端调用Lua的全局函数接口
------------------------------------------------------
local luaj 

if GameGlobal.targetPlatform == cc.PLATFORM_OS_ANDROID then luaj = require("luaj") end 

require "gamecore/platform/android/Sdk"

local platform
local qqopenId 
local qqpf  
local qqpfKey
local qqaccessToken
local loginPlatformInJava
local payToken


--@brief 设置QQ平台id 
function SetQqopenId(sString)
	qqopenId = sString
end 

--@breif 取得QQ平台Id
function GetQqopenId()
	local sdk = Sdk.getCurSdk()
	if sdk then
		return sdk:getUserName()
	end
end 


function SetQqpf(sString)
	qqpf = sString
end 


function GetQqpf()
	return  qqpf
end 



function SetQqpfKey(sString)
	qqpfKey = sString
end 


function invalidlocalinfo(sString)
--    NotifyOnScreen.add("本地权限失效，请重新登陆",nil, nil,LayerManager.alertLayer)
end


function GetQqpfKey()
	return  qqpfKey 
end 

function SetQqaccessToken(sString)
	qqaccessToken = sString
end 


function GetQqaccessToken()
	local sdk = Sdk.getCurSdk()
	if sdk then
		return sdk:getLoginToken()
	end
end 

function SetLoginPlatformInJava(sString)
	loginPlatformInJava = sString
end 

function controWaitingInLua(value)
--    ccprint("controWaitingInLua = " .. value)
--    NotifyOnScreen.add("controWaitingInLua = " .. value,nil, "other/tishitiaoBJ.png",LayerManager.alertLayer)
    if value=="open" then
    MsdkController.startWaiterEffect()
    else
        MsdkController.stopWaiterEffect()
    end

end


function GetLoginPlatformInJava()
	local p = DataGlobal.gamePlatForm
	local sdk = Sdk.getCurSdk()
	if sdk then
		return sdk:getPlatformName()
	end
   	return p
end 


function SetPayToken(sString)
	payToken = sString
end 


function GetPayToken()
	return payToken 
end 



--@breif 设置登陆状态的函数 
function SetLoginBtnState(sString)
	TimerManager.addTimeOut(function()
		Dispatcher.dispatchEvent(EventType.ANDROID_SDK_LOGIN_RESULT,{flag = true})
	end, 0.016 * 4)
end 


--@brief 调用登陆接口
function SetLoginPlat(sPhonePlatForm)
	--ui.createAlertView({{" ", nil},{" ",nil}},false,"sureBtn","取得权限?" .. (nPhonePlatForm or "error") , nil, true)
end

function javaCallLuaGlobalFun(valueStr)
	--	if hjprint then
	--	   hjprint(valueStr)
	--	end
	AndroidMessageQueue.enqueue(valueStr)
end

--@brief  取得登陆平台
function GetPhonePLatForm()

	return DataGlobal.gamePlatForm
end 


--breif 打印提示
function AlerView(text)   
	if not ui.addPlist("allPlist/common.plist") then return end
	local size = cc.Director:getInstance():getWinSize()
	local node = ui.newLayer(cc.size(800,80),cc.c4b(255, 255, 255,255))
	ui.addChild(LayerManager.alertLayer,node,100,size.height-100,0,10)
	local nodeSize = cc.size(800,80)
	local lbl = ui.newLabel(text,22,ui.color.red)
	ui.addChild(node,lbl,nodeSize.width/2,0,0.5,0)
	LayerManager.alertLayer:setGlobalZOrder(2000)
	lbl:setDimensions(800,400)
	local btn = ui.UIButton.new({
        images = {normal= "#common/2.png",pressed = "#common/2.png",disabled= "#common/2.png"},
    })
	ui.addChild(node,btn,nodeSize.width,nodeSize.height,1,1)
	btn:onClick(nil,function()  ui.removeSelf(node,true) end)
end



--
--function androidOnResume()
--	ccprint("androidOnResume")
--
--	NetManager.removeReconnectPanelAndConnect()
--end
--
--
--function androidOnPause()
--	ccprint("androidOnPause")
--end


---------
-- kk游戏盒子安装成功
---------
function onGameBoxHanlder(parm)
	param = tostring(parm)
    gprint(" funciotn onGameBoxHanlder ===== parm = " .. parm)
	if param == "installed" then
	    cc.UserDefault:getInstance():setBoolForKey("isInstalledGameBox", true)

	    require ("gamecore/modules/gameBox/GameBoxController")
	    GameBoxController.m_role2_kkapk_tos()
	    Dispatcher.dispatchEvent(EventType.INTALLED_GAME_BOX, {})
	    Dispatcher.dispatchEvent(EventType.OPEN_CLOSE_GAMEBOX_VIEW, {tag="close"})
	elseif param == "removed" then

	end
end


--function javaCallLuaShareSucc(platform)
--    hpprint("--------shareSucc")
--    ShareController.shareSucc(platform)
--end