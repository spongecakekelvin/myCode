----sdk全局函数，用于从android和ios调用
-- function callSdkGlobalFun(valueStr)
--     SdkLuaMsg.in(valueStr)
-- end

module("SdkLuaInterface", package.seeall)

isInit = false
--------------------------------------
-- 闪屏
--------------------------------------
function onSplash(retCode, msg)
    if GameGlobal.isAndroid then
        local logoBg = cc.Sprite:create("platform/" .. msg)
        logoBg:setOpacity(0)
        LayerManager.alertLayer:addChild(logoBg)
        local s_visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
        logoBg:setPosition(cc.p(s_visibleRect.x + s_visibleRect.width / 2, s_visibleRect.y + s_visibleRect.height / 2))

        logoBg:runAction(cc.Sequence:create({
            cc.FadeIn:create(0.5),
            cc.DelayTime:create(0.8),
            cc.FadeOut:create(0.3),
            cc.CallFunc:create(function()
                doinit()
            end)
        }))
    end
end

--------------------------------------
-- 初始化init
--------------------------------------
-------lua -> android/ios
function doinit()
    -- self.prox_platform = ....
    -- self.channel = ....
    if GameGlobal.isAndroid then
		callJavaStaticMethod("com/sdk/luaadapter/SDKInterface", "doInit", {})
	elseif GameGlobal.iosPlat then
        -- callObjectcMethod("SDKInterface", "doInit", {})
   	elseif GameGlobal.isWindows then

	end
end

--------android/ios -> lua 
-- function fun(retCode, msg)
--     retCode : 返回状态码
--     msg     : "aa#bb#cc#"
-- end

function onInit(retCode, msg)
    gprint("onInit retCode === " .. retCode)
    gprint("onInit msg === " .. msg)
    local retCode = tonumber(retCode)
    if retCode == 0 then
        isInit = true
    elseif retCode == 1 then
        onSplash(retCode, msg)
    elseif retCode == 2 then
    	ccprint("doInit2")
    	doinit()
    else 
        doinit()
    end
end 


--------------------------------------
-- 登陆login
--------------------------------------
function doLogin()
	if GameGlobal.isAndroid then
        -- callJavaStaticMethod("com/sdk/luaadapter/SDKInterface", "doLogin", {})
	elseif GameGlobal.iosPlat then
    	callObjectcMethod("SDKInterface", "doLogin", 0)
   	elseif GameGlobal.isWindows then

	end
end 

local reLoginSchduleId
function onLogin(retCode, msg)
    gprint("onLogin retCode === " .. retCode)
    gprint("onLogin msg === " .. msg)

    if tonumber(retCode) == 0 then
        for k,v in pairs(SdkLuaMsg.doParseLogin(msg)) do
            if k == "uid" then
                SdkLuaUtil.setUid(v)
            end

            if k == "token" then
                SdkLuaUtil.setToken(v)
            end

            if k == "extenparam" then
                local extraParamsTab = {v}
                SdkLuaUtil.setExtraParams(extraParamsTab)
            end
        end

        if SdkLuaUtil.succLoginListener then
            SdkLuaUtil.succLoginListener()
        end
    else
        TimerManager.clearTimeOut(reLoginSchduleId)
        reLoginSchduleId = TimerManager.addTimeOut(
            function()
                doLogin()
            end, 2
        )
    end
end

--------------------------------------
-- 注销loginout
--------------------------------------
function doLoginout()
    if GameGlobal.isAndroid then
        callJavaStaticMethod("com/sdk/luaadapter/SDKInterface", "doLoginout", {})
    elseif GameGlobal.iosPlat then
        
    elseif GameGlobal.isWindows then

    end
end

function onLoginout(retCode, msg)
    gprint("onLoginout retCode === " .. retCode)
    gprint("onLoginout msg === " .. msg)

    -- 在没有登录游戏之前不需要重启游戏。
    if GameGlobal.isbeforkszz then
        SdkLuaInterface.doLogin()
        return
    end

    if tonumber(retCode) == 0 then
        SdkLuaUtil.exitGame()
    end
end

--------------------------------------
--  支付payment
--------------------------------------


function doPayment(serverInfos, recordPrice, goldRate)
	local orderId = ""
    local url = ""
    local gold = ""
    local accessKey = ""
    local transNo = ""
    orderId = serverInfos.order_id
    url = serverInfos.pay_conf_list[1].callback_url
    gold = serverInfos.pay_gold
	--扩展参数
    accessKey = serverInfos.pay_conf_list[1].args[1]
    transNo = serverInfos.pay_conf_list[1].args[2]




	if GameGlobal.isAndroid then

		callJavaStaticMethod("com/sdk/luaadapter/SDKInterface", "doPayment", 
		{
			tostring(GameGlobal.real_server_id),
            tostring(GameGlobal.server_name),
            tostring(myRole.role_name),
            tostring(myRole.role_id),
            tostring(myRole.level),
            tostring(myRole.vip_level),
            tostring(myRole.gold),
            tostring(myRole.family_name),
            tostring(orderId),
            tostring("元宝"),--goodsName
            tostring("个"),--quantifier
            tostring(string.format("%s元宝", gold)),--goodsDesc

            tostring(gold),
            tostring(gold),--goodsId
            tostring(url),
            tostring(SdkLuaUtil.getPaymentExtendParam(
            {
                gold = gold,
                accessKey = accessKey,
                pay_type = serverInfos.pay_type
            }))--预留自定义
		})
	elseif GameGlobal.iosPlat then
        gprint("doPayment")
    	-- callObjectcMethod("SDKInterface", "doPayment", 0)
        local quantity = SdkLuaUtil.getNum()
        local loginUserId = SdkLuaUtil.getUid()
        local productId = SdkLuaUtil.SDK_KEYS[gold] or SdkLuaUtil.SDK_KEYS[600]
        local productName = SdkLuaUtil.SDK_KEYS_PRODUCTNAME[gold] or SdkLuaUtil.SDK_KEYS_PRODUCTNAME[600]
        local productDescription = "购买" .. productName

        callObjectcMethod("SDKInterface", "doPayment",
            {   
                account = tostring(loginUserId), 
                roleId = tostring(myRole.role_id),
                roleName = tostring(myRole.role_name),
                roleLevel = tostring(myRole.level),
                serverId = tostring(GameGlobal.real_server_id),
                serverName = tostring(GameGlobal.server_name),
                profession = tostring(gameconfig.chineseMapConfig.roleCategoryName),
                vipLevel = tostring(myRole.vip_level),
                balance = tostring(myRole.gold),
                familyName = tostring(myRole.family_name),
                productId = tostring(productId),
                productName = tostring(productName),
                productDescription = tostring(productDescription),
                quantityStr = tostring(quantity),
                isVip = tostring("0"),
                gold = tostring(gold),
                price = tostring(recordPrice),
                orderId = tostring(orderId),
                notifyURL = tostring(url),
                payType = tostring("0"),
                goldRate = tostring(goldRate),
                ext = tostring(SdkLuaUtil.getPaymentExtendParam())
            }
        )
   	elseif GameGlobal.isWindows then

	end
end 

function onPayment(retCode, msg)
    gprint("onPayment retCode === " .. retCode)
    gprint("onPayment msg === " .. msg)
end

--------------------------------------
--  角色相关信息roleInfo 
--  retCode 0:其它 1:登陆 2:注册 3:登出 4:创建角色 5:角色升级
--------------------------------------
function notifyAttrRoleInfo(retCode)
    if GameGlobal.isAndroid then
        callJavaStaticMethod("com/sdk/luaadapter/SDKInterface", "notifyAttrRoleInfo",
        {
            tostring(retCode),
            tostring(GameGlobal.real_server_id),
            tostring(GameGlobal.server_name),
            tostring(myRole.role_name),
            tostring(myRole.role_id),
            tostring(myRole.level),
            tostring(myRole.vip_level),
            tostring(myRole.gold),
            tostring(myRole.family_name),
            tostring(SdkLuaUtil.getRoleInfoExtendParam())
        })
    elseif GameGlobal.iosPlat then
        SdkLuaInterface.callObjectcMethod("SDKInterface", "notifyAttrRoleInfo", 
            {
                retCode = tostring(retCode),
                serverId = tostring(GameGlobal.real_server_id),
                serverName = tostring(GameGlobal.server_name),
                roleId = tostring(myRole.role_id),
                roleName = tostring(myRole.role_name),
                roleLevel = tostring(myRole.level),
                vipLevel = tostring(myRole.vip_level),
                gold = tostring(myRole.gold),
                familyName = tostring(myRole.family_name),
                account = tostring(SdkLuaUtil.getUid()),
                createTime = tostring(myRole.create_time),
                balance = tostring(myRole.gold),
                ext = tostring(SdkLuaUtil.getRoleInfoExtendParam())
            }
        )
    elseif GameGlobal.isWindows then

    end
end


--0渠道号#其他
function getInitExtraParams(code,msg)
	ccprint("getInitExtraParams")
    SdkLuaUtil.getInitExtraParams(msg)
end

function exit( code,msg )
    cc.Director:getInstance():endToLua()
end

--------------------------------------
-- 网络变化接口 0:没有网络 1:wifi 2:3G
--------------------------------------
if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPAD then
    function onNetChange(retCode, msg)
        gprint("onNetChange retCode === " .. retCode)
        gprint("onNetChange msg === " .. msg)
        SdkLuaUtil.netChange(msg)
    end
end


---------util func
if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
	local luaj
	luaj = require("luaj")

	--self:callJavaStaticMethod("org/cocos2dx/lua/AppActivity", "login", {"name", age,...})
	function callJavaStaticMethod(className, methodName, argTable)
		assert(type(argTable) == "table", "调用java参数必须为table")

		local ok, ret = luaj.callStaticMethod(className, methodName, argTable)
		if not ok then
			gprint("SDK:lua call java <<" .. methodName ..">>  call return error = ", ret)
			return ret
		else
			gprint("SDK:lua call java <<" .. methodName ..">> return succ = ", ret )
			return ret
		end
	end

	function getStringFromJavaWithEmptyParam(className,methodName)
		local args ={}
		local sig = "()Ljava/lang/String;"

		-- 调用方法并获得返回值
		local ok, ret = luaj.callStaticMethod(className,methodName, args, sig)

		if not ok then
			gprint("SDK:lua call java <<" .. methodName ..">>  call return error = ", ret)
			return ret
		else
			gprint("SDK:lua call java <<" .. methodName ..">> return succ = ", ret )
			return ret
		end
	end
end

if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPAD then
    local luaoc
    luaoc = require("luaoc")
    
    function callObjectcMethod(className, method, args)
        --    local args = { num1 = 2 , num2 = 3 }
        local ok, ret = luaoc.callStaticMethod(className, method, args)
        if not ok then
            --        Director:getInstance():resume()
            if ccprint then
                ccprint("failed The ret is:", ret, method)
            end

        else
            if ccprint then
                ccprint("The ret is:", ret)
            end
        end

    --    local function callback(param)
    --        if "success" == param then
    --            if ccprint then
    --                ccprint("object c call back success")
    --            end
    --        end
    --    end
    --
    --    luaoc.callStaticMethod(className, "registerScriptHandler", { scriptHandler = callback })
    --    luaoc.callStaticMethod(className, "callbackScriptHandler")
        return ret
    end
end


