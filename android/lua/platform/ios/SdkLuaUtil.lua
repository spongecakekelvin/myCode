module("SdkLuaUtil", package.seeall)

succLoginListener = false
reLoginSchduleId = false
--------------------------------------
-- 获取用户uid
--------------------------------------
local loginUid = "noNeed"

NOTIFY_ATTR_ROLEINFO_OTHER = 0
NOTIFY_ATTR_ROLEINFO_LOGIN = 1
NOTIFY_ATTR_ROLEINFO_REGISTER = 2
NOTIFY_ATTR_ROLEINFO_LOGINOUT = 3
NOTIFY_ATTR_ROLEINFO_NEWROLE= 4
NOTIFY_ATTR_ROLEINFO_ROLEUPLEVEL = 5

IS_QQ_OR_WEIXIN = "qq"

SDK_KEYS = {
    [600] = "com.aifeng.tiantangrongyao.ttry.6",
    [1800] = "com.aifeng.tiantangrongyao.ttry.18",
    [3000] = "com.aifeng.tiantangrongyao.ttry.30",
    [9800] = "com.aifeng.tiantangrongyao.ttry.98",
    [12800] = "com.aifeng.tiantangrongyao.ttry.128",
    [19800] = "com.aifeng.tiantangrongyao.ttry.198",
    [32800] = "com.aifeng.tiantangrongyao.ttry.328",
    [64800] = "com.aifeng.tiantangrongyao.ttry.648",
}

SDK_KEYS_PRODUCTNAME = {
    [600] = "600钻石",
    [1800] = "至尊神兵宝箱",
    [3000] = "3000钻",
    [9800] = "9800钻石",
    [12800] = "12800钻石",
    [19800] = "19800钻石",
    [32800] = "32800钻石",
    [64800] = "64800钻石",
}

--0渠道号#其他
function getInitExtraParams(javaClassName)
	ccprint("getInitExtraParams",javaClassName)
    SdkLuaInterface.callJavaStaticMethod(javaClassName, "setExtraParams", {tostring(ChannelNumber)})
end

function setUid(uid)
    if GameGlobal.isLogined then
        if loginUid and loginUid ~= uid then
            TimerManager.clearTimeOut(reLoginSchduleId)
            reLoginSchduleId = TimerManager.addTimeOut(function()
                exitGame()
            end, 2)
        end
    else
        loginUid = uid
    end
end

function getUid()
    if loginUid then
        gprint("loginUid === " .. loginUid)
    end
    return loginUid
end

--------------------------------------
-- 用户token
--------------------------------------
local loginToken = ""

function setToken(token)
    loginToken = token
end

function getToken()
    if loginUid then
        gprint("loginToken === " .. loginToken)
    end
    return loginToken
end

--------------------------------------
--  角色升级
--------------------------------------
function roleLevelChangedHandler(self, eventParam)
    SdkLuaInterface.notifyAttrRoleInfo(NOTIFY_ATTR_ROLEINFO_ROLEUPLEVEL)
end

--------------------------------------
-- 充值数量
--------------------------------------
local payNumber = 1
function setNum(number)
    payNumber = number
end

function getNum()
    return payNumber
end

--------------------------------------
-- 是否需要order后端生成orderid
--------------------------------------
function isNeedOrderId()
    return true
end

--------------------------------------
--  支付预留
--------------------------------------
function getPaymentExtendParam(param)
    plat = DataGlobal.gamePlatForm 

    local extendParam = ""

    if GameGlobal.iosPlat then
        extendParam = ""
    else
        --qq包强制切换为甲游支付。
        -- if "qq" == DataGlobal.gamePlatForm then
        --     if DataGlobal.isQQYSDKPlatform() then
        --         param.pay_type = 0
        --     elseif DataGlobal.isFusion2YsdkPlatform() then
        --         param.pay_type = 1
        --     end
        -- end
        
        --做参数拼接，用‘#’做分隔符
        extendParam = string.format("%s", ""..myRole.account_name.."#"..(param.accessKey or "").."#"..(param.pay_type or "").."#") --sdk_uid
    end
    
    return extendParam
end

--------------------------------------
--  用户信息预留
--------------------------------------
function getRoleInfoExtendParam()
    local extendParam = ""

	--做参数拼接，用‘#’做分隔符
    extendParam = string.format("%s", ""..myRole.silver.."#"..myRole.create_time.."#")

    return extendParam
end

--------------------------------------
-- 设备id
--------------------------------------
function getDeviceId()
    local facNo = ""
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform ==cc.PLATFORM_OS_ANDROID then
        facNo = getAndroidFacNo()
    else
        
    end
    
    return facNo
end

--------------------------------------
-- 获取ios设备令牌
--------------------------------------
function getDeviceToken()
    local deviceToken = "noNeed"
    if GameGlobal.isAndroid then
        deviceToken = "noNeed"
    elseif GameGlobal.iosPlat then
        
    elseif GameGlobal.isWindows then

    end
    return deviceToken
end

--------------------------------------
-- 扩展参数列表
--------------------------------------
local extraParams = {}

function setExtraParams(extra)
    extraParams = extra
    extraParams[2] = "fusion"
    extraParams[3] = "version|"..tostring(DataGlobal.getCppVersion())
end

function getExtraParams()
    return extraParams
end

--------------------------------------
-- 进入游戏
--------------------------------------
local alreadyEnterGame = false
function enterGameCallback()
    if alreadyEnterGame then
        return
    end
    alreadyEnterGame = true

    if GameGlobal.isNewRole then
        SdkLuaInterface.notifyAttrRoleInfo(NOTIFY_ATTR_ROLEINFO_NEWROLE)
    end
    
    SdkLuaInterface.notifyAttrRoleInfo(NOTIFY_ATTR_ROLEINFO_LOGIN)
end

--------------------------------------
-- loginView界面登陆成功回调处理
--------------------------------------
function setLoginCallback(succCallback)
    succLoginListener = succCallback
end

restartTipPanel = false
function exitGame(msg)
    msg = msg or "游戏里切换账号需要退出游戏，自动退出后请重新打开游戏"
    if GameGlobal.isAndroid then
        if GameGlobal.isLogined then
            if ui.isExist(restartTipPanel) then
                return
            end

            local yes =ui.newBlueButton("退出游戏")
            yes:onClick(nil, function()
                SdkLuaInterface.callJavaStaticMethod("org.cocos2dx.lua.AppActivity", "restartGame", {})
            end)

            restartTipPanel = ui.createAlertView(nil, false, "restart", msg,
            nil, false, true, {
                yes
            })
            restartTipPanel.close:setVisible(false)
            restartTipPanel.closeHandler = function(view)
            end
        else
            if SdkLuaInterface.isInit then
                SdkLuaInterface.doLogin()
            end
        end
    elseif GameGlobal.iosPlat then
        if GameGlobal.isLogined then
            if ui.isExist(restartTipPanel) then
                return
            end

            local yes =ui.newBlueButton("退出游戏")
            yes:onClick(nil, function()
                SdkLuaInterface.callObjectcMethod("S3LuaObjectCBridg", "exitApplication", {})
            end)

            restartTipPanel = ui.createAlertView(nil, false, "restart", msg,
                nil, false, true, {
                    yes
                })
            restartTipPanel.close:setVisible(false)
            restartTipPanel.closeHandler = function(view)
            end
        else
            if SdkLuaInterface.isInit then
                SdkLuaInterface.doLogin()
            end
        end
    elseif GameGlobal.isWindows then
    end
end

--------------------------------------
-- 统计到账接口
--------------------------------------
function payResultInfo(serverInfos)
    local orderId = serverInfos.order_id
    local price = serverInfos.price

    if GameGlobal.isAndroid then
    elseif GameGlobal.iosPlat then
        if DataGlobal.isShengliAppstoreAhqshPlatform() then
            SdkLuaInterface.callObjectcMethod("SDKInterface", "notifyPaySuccessInfo", 
                {
                    price = tostring(price * 100),
                    roleId = tostring(myRole.role_id),
                    orderId = tostring(orderId)
                }
            )
        else
            SdkLuaInterface.callObjectcMethod("SDKInterface", "notifyPaySuccessInfo", 
                {
                    price = tostring(price),
                    roleId = tostring(myRole.role_id),
                    orderId = tostring(orderId)
                }
            )
        end
    end
end

--------------------------------------
-- 网络变化接口 0:没有网络 1:wifi 2:3G
--------------------------------------
function netChange(code)
    -- gprint("网络状态改变为 --- " .. code)
    -- 0:没有网络 1:wifi 2:3G
    if code == 1 then
        GameGlobal.msd:setSegLoaderStatus(true)
    else
        GameGlobal.msd:setSegLoaderStatus(false)
    end
end

--------------------------------------
-- iosIDFA
--------------------------------------
function getIDFA()
    local idfa = ""
    if GameGlobal.iosPlat then
        local rrr = SdkLuaInterface.callObjectcMethod("S3LuaObjectCBridg", "getDeviceInfo", {})
        if rrr then
            local curIDFA = ""

            for k,v in pairs(rrr) do
                if k == "IDFA" then
                    curIDFA = v
                end
            end

            idfa = curIDFA
        end
    end

    return idfa
end

function getIEMI()
    local iemi = ""
    if GameGlobal.isAndroid then
        iemi = GameGlobal.msd:getPhoneIMEI()
    end

    gprint("iemi === " .. iemi)
    return iemi
end