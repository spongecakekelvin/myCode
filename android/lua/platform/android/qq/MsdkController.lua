------------------------------------------------------
--作者:	lqk
--日期:	2015年1月28日
--描述:	腾讯QQ控制器
------------------------------------------------------
module("MsdkController", package.seeall)

local curPath       = "gamecore/plat/"
local luaj
if GameGlobal.targetPlatform == cc.PLATFORM_OS_ANDROID then
	 luaj = require("luaj")
end

local javaClass     = "org/cocos2dx/lua/AppActivity"

------------------------------------------------------------
--		初始化监听
------------------------------------------------------------

------------------------------------------------------------
--		初始化监听
------------------------------------------------------------
function init()
	ProtoManager.addListenServer(ccprotoName.qq_info,m_qq_info_toc)                   --QQ平台
	ProtoManager.addListenServer(ccprotoName.qq_buy_gold,m_qq_buy_gold_toc)           --购买
end


function startzhifubao(title,content,price,url,tradeno,partner,sellerid,key)

    --    local args = nil
    local args ={title,content,price,url,tradeno,partner,sellerid,key}
    local sig ="(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"

    -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","zhifubaopay", args, sig)

    if not ok then
        ccprint("startzhifubao  zhifubaopay  call return error = ", ret )
        return ret
    else
        ccprint("startzhifubao  zhifubaopay  call return succ = ", ret )
        return ret
    end

end

-- --@brief 登陆平台
-- function kkuuToLogin(gameid,cnumber)
    
--     local args ={cnumber,gameid}
--     local sig = "(Ljava/lang/String;I)V"
--      -- 调用方法并获得返回值
--     local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","kkuuInit", args, sig)

--     if not ok then
--          ccprint("kkuuInit    call return error = ", ret )
--         return ret
--     else
--         ccprint("kkuuInit   call return succ = ", ret )
--         return ret
--     end
-- end 


--@brief 登陆平台
-- function kkuuToLoginout()
    
--     local args ={}
--     local sig = "()V"
--      -- 调用方法并获得返回值
--     local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","kkuuLogout", args, sig)

--     if not ok then
--          ccprint("kkuuToLoginout    call return error = ", ret )
--         return ret
--     else
--         ccprint("kkuuToLoginout   call return succ = ", ret )
--         return ret
--     end
-- end 

--@brief 登陆平台
-- function kkuuGetUserName()
--     local args ={}
--     local sig = "()Ljava/lang/String;"
--      -- 调用方法并获得返回值
--     local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","getKKUUUserId", args, sig)

--     if not ok then
--          ccprint("getKKUUUserId    call return error = ", ret )
--         return ""
--     else
--         ccprint("getKKUUUserId   call return succ = ", ret )
--         return ret
--     end
-- end 

--@brief 登陆平台
function LoginPlatFormJava(method)
	local args ={}
    local sig = "()V"
     -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod(javaClass,method, args, sig)

    if not ok then
 		 ccprint("LoginPlayForm  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("LoginPlayForm  " .. method .."  call return succ = ", ret )
        return ret
    end
end 


function doShare(method,sTitle,sContentTitle,sHttp,sUrlImgIcon)
    local args = {sTitle or " ",sContentTitle or " ",sHttp or " ",sUrlImgIcon or " "}
    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
     -- 调用方法并获得返回值
   local ok, ret = luaj.callStaticMethod(javaClass,method, args, sig)

    if not ok then
         ccprint("doShare  " .. method .."  call return error = ", ret )
        return ret
    else
        ccprint("doShare  " .. method .."  call return succ = ", ret )
        return ret
    end
end 


function isHaveShare(method)
    return false

--   local args = {}
--   local sig = "()Z"
--     -- 调用方法并获得返回值
--   local ok, ret = luaj.callStaticMethod(javaClass,method, args, sig)
--
--    if not ok then
--         ccprint("doShare  " .. method .."  call return error = ", ret )
--        return ret
--    else
--        ccprint("doShare  " .. method .."  call return succ = ", ret )
--        return ret
--    end
end 


--@breif 平台登陆
function loginConnect(nameQQ)

    ccprint(nameQQ)
	-- if GameGlobal.targetPlatform ~= cc.PLATFORM_OS_ANDROID then return end 
	
    local msg = ccproto:m_qq_auth_tos()

    -- msg.account_name = GetQqopenId() or "-1" --用户名
    
    msg.imei = Helper.getPhoneIMEI()
    msg.qq_token = {
    				pf = GetQqpf() or "-1",
    				pfkey = GetQqpfKey() or "-1",
    				pay_token = GetPayToken() or "-1",
    				access_token = GetQqaccessToken() or "-1"
    			}
    msg.brand = Helper.getDeviceInfByKey("MODEL")
    msg.brand_type = Helper.getDeviceInfByKey("SYSTEM_INF")
        
    
--     if DataGlobal.useLocalToQQPlat then
-- msg.os_type        = 3
--     msg.login_platform =  "qq"
-- else
--     msg.os_type        = GameGlobal.targetPlatform
--     msg.login_platform =  ccarpg.MessageDispatcher:getInstance():callBackForLua(2,"")
--     end
if GameGlobal.isWindows then

 msg.account_name = string.trim(nameQQ)
else
 msg.account_name = GetQqopenId() or "-1" --用户名
end

    msg.os_type        = GameGlobal.targetPlatform
    -- msg.login_platform =  ccarpg.MessageDispatcher:getInstance():callBackForLua(2,"")
    local realplatform = DataGlobal.gamePlatForm
    if  DataGlobal.manulSelectPlatform then
      realplatform= DataGlobal.manulSelectPlatform
    end

    if GameGlobal.isWindows then
       msg.login_platform =  realplatform
    else
        msg.sdk_channel = Helper.getRoleAuthSdkChannel()
--        msg.login_platform =  realplatform --GetLoginPlatformInJava() -- 返回qq weixin

        local pfa = string.split(realplatform,"_")
        local qqweixin = GetLoginPlatformInJava()
        if #pfa ==3 and ( qqweixin=="qq" or qqweixin=="weixin") then

            msg.login_platform = pfa[1] .. "_" .. qqweixin .. "_"  .. pfa[3]
        else
            msg.login_platform = realplatform
        end

    end

    -- ccprint(GameGlobal.targetPlatform)
    -- ccprint(msg.login_platform)
--    msg.login_platform =  GetLoginPlatformInJava()
    
    msg.client_version = currentVersion
    msg.server_id = tonumber(CommonConfig.serverId) or 0
    msg.fac_no = getAndroidFacNo()

    if  ChannelNumber ~= "arpg" then
        msg.channel_tag = ChannelNumber
    else
--        msg.channel_tag = msg.login_platform
        msg.channel_tag = DataGlobal.gamePlatForm
    end
--    msg.channel_tag = GetLoginPlatformInJava()

    msg.extra_params = {}
    msg.netstatus =  GameGlobal.get_net_status()
    ccprint(msg.channel_tag)
   	ProtoManager.send(msg,true)

    printTable(msg, yzjprint)
end


--@brief 重启游戏平台
function reStartPlat(method)
	local args ={}
    local sig = "()V"
     -- 调用方法并获得返回值
    local ok, ret = luaj.callStaticMethod(javaClass,method, args, sig)

    if not ok then
 		 lqkprint("LoginPlayForm  " .. method .."  call return error = ", ret )
        return ret
    else
        lqkprint("LoginPlayForm  " .. method .."  call return succ = ", ret )
        return ret
    end
end



-----------------------------------------------------------
--收到协议-------------------------------
------------------------------------------------------------
function m_qq_info_toc(msg)
	local isSucc = Helper.errorHandler(msg.err_code)
	if msg and msg.zone_id then 
		local RechargeModel = require("gamecore/modules/recharge/RechargeModel").getInstance() 
		RechargeModel:setZoneId(msg.zone_id)
	end 
end

local waiterview = nil

function stopWaiterEffect()
    if waiterview then
        waiterview:stopWaiterEffect()
        waiterview:removeFromParent(true)
        waiterview = nil
        end
end


function startWaiterEffect()
    if not waiterview then
        local waiting = require("gamecore/common/WaitingView")
        waiterview = waiting.create()
                local s_visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
        waiterview:setPosition({ x = s_visibleRect.x + s_visibleRect.width / 2, y = s_visibleRect.y + s_visibleRect.height / 2 })
        LayerManager.alertLayer:addChild(waiterview)
    end
    waiterview:startWaiterEffect()

end

--local waiterqq = nil
--local waiteractionto = nil
--function stopWaiterEffect()
----    ccprint("stoptWaiterEffect")
----    NotifyOnScreen.add("stoptWaiterEffect = " ,nil, "other/tishitiaoBJ.png",LayerManager.alertLayer)
--    if waiterqq then
--        if waiteractionto then
--            waiterqq:stopAction(waiteractionto)
--            waiteractionto = nil
--        end
--        waiterqq:removeFromParent(true)
--        waiterqq = nil
--    end
--end
--
--
--function startWaiterEffect()
----    ccprint("startWaiterEffect")
----    NotifyOnScreen.add("startWaiterEffect = ",nil, "other/tishitiaoBJ.png",LayerManager.alertLayer)
--    if not waiterqq then
--        waiterqq = cc.Sprite:create("other/waiterqq.png")
--        LayerManager.alertLayer:addChild(waiterqq)
--        --       self.waiterqq:setLocalZOrder(10000)
--            local s_visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
--            waiterqq:setPosition({ x = s_visibleRect.x + s_visibleRect.width / 2, y = s_visibleRect.y + s_visibleRect.height / 2 })
--    end
--    --    local seq = cc.Sequence:create(cc.RotateTo:create(0.8, 180),cc.CallFunc:create(handler(self, self.checksomething)),cc.Sequence:create(cc.RotateTo:create(0.8, 180),cc.CallFunc:create(handler(self, self.checksomething))))
--    --    local actionto = cc.RepeatForever:create(seq)
--    --    self.waiterqq:runAction(actionto)
--    if waiteractionto then
--        waiterqq:stopAction(waiteractionto)
--        waiteractionto = nil
--    end
--    waiteractionto = cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(0.8, 180), cc.RotateTo:create(0.8, 360)))
--    waiterqq:runAction(waiteractionto)
--end



--@breif 充值
function m_qq_buy_gold_tos(parame)
	local msg          = ccproto:m_qq_buy_gold_tos()
	msg.result_code    = parame.result_code     --人民币
	msg.pay_channel    = parame.pay_channel     --支付渠道
	msg.pay_state      = parame.pay_state       --支付状态
	msg.provider_state = parame.provider_state  --发货状态
	msg.save_num       = parame.save_num        --下单成功时购买的数量
	msg.result_msg     = parame.result_msg      --返回信息
	msg.extend_info    = parame.extend_info     --扩展信息
	ProtoManager.send(msg) 
end 


--@breif QQ购买
function m_qq_buy_gold_toc(msg)
	NotifyOnScreen.add("充值成功")
	lqkprint("QQ购买成功")
	--printTable(msg,lqkprint)
end 


return MsdkController
