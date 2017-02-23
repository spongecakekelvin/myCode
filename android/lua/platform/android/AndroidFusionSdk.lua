------------------------------------------------------
--作者: Yzj
--日期: 2016年4月15日
--描述: 融合sdk
------------------------------------------------------
local BaseClass = require "gamecore/platform/android/SdkInterface"
local AndroidFusionSdk = class("AndroidFusionSdk", BaseClass)


local succLoginListener
local succInitListener
local succLogoutListener

local gameEnter
local roleLevelChangedHandler

local isInit = false
local isLogout = false

local reLoginSchduleId

function AndroidFusionSdk:ctor()
    self:init()
    Dispatcher.addEventListener(EventType.GAME_ENTER, gameEnter, self)
    Dispatcher.addEventListener(EventType.ROLE_LEVEL_CHANGED, roleLevelChangedHandler, self)
end



function AndroidFusionSdk:init()
    -- 在java oncreate中调用
end

function AndroidFusionSdk:isInit()
    return isInit
end


--------------------------------------
-- 登陆
--------------------------------------
local loginToken = ""
local loginAccountName = ""
local platformUid = ""
local platformName = ""

local lastLoginName = ""

function AndroidFusionSdk:login(sdk_name)
    sdk_name = sdk_name or "qq" -- "weixin" -- 只用于ysdk区分qq和weixin，其余平台会根据fssdk_config配置正常运行
    local loginParam = {platform_name = sdk_name}
    lastLoginName = sdk_name

    self:callJavaWithJsonStr("login", loginParam)
end


function AndroidFusionSdk:setLoginCallback(succCallback)
    succLoginListener = succCallback
end

function AndroidFusionSdk:setInitCallback(succCallback)
    succInitListener = succCallback
end

function AndroidFusionSdk:setLogoutCallback(succCallback)
    succLogoutListener = succCallback
end


--------------------------------------
-- 获取登录信息
--------------------------------------
function AndroidFusionSdk:getLoginToken()
    yzjprint("== getloginTOken= ", loginToken)
    return loginToken
end

function AndroidFusionSdk:getUserName()
    yzjprint("==  getUserName() ", loginAccountName)
    return loginAccountName
end

function AndroidFusionSdk:getPlatformUid()
    yzjprint("==  getPlatformUid() ", platformUid)
    return platformUid
end

function AndroidFusionSdk:getPlatformName()
    yzjprint("==  getPlatformName() ", platformName)
    return platformName
end



--------------------------------------
-- 下线
--------------------------------------
function AndroidFusionSdk:logout()
    yzjprint("AndroidFusionSdk:logout()")
    -- kkuu 浮窗
    self:callJavaWithJsonStr("showFloatView", {is_show = "false"})

    self:callJavaWithJsonStr("logout", {})
end

function AndroidFusionSdk:setLoginoutCallback()
    yzjprint("还没有实现接口")
end

--------------------------------------
-- 充值
--------------------------------------
function AndroidFusionSdk:pay(proto, recordPrice, goldRate, pay_type_fusion)
    local cp_order_id = tostring(proto.order_id)
    local cp_notify_url = ""
    if proto.pay_conf_list[1] then
        cp_notify_url = proto.pay_conf_list[1].callback_url
    end
    local cp_ext = ""
    -- local zoneId = "1"
    local is_sandbox = "0"
    local pay_gold_rate = goldRate or 100
    local pay_type = pay_type_fusion or 0  -- 充值类型
    -- define( "PAY_TYPE_JOOYUU", 1 ); // 甲游自己的支付 
    -- define( "PAY_TYPE_YSDK", 2 );   //YSDK支付
    -- 默认0 就是SDK管理后台控制
    local ext = ""


    local args = {}
    args.pay_money = tostring(recordPrice)
    args.goods_name = "钻石"
    args.goods_desc = "充值" .. recordPrice .. "元，获得" .. (recordPrice*pay_gold_rate) .. "钻石"
    args.cp_notify_url = cp_notify_url
    args.cp_order_id = cp_order_id
    args.cp_ext = cp_ext
    args.exchange_gold_rate = tostring(pay_gold_rate)
    args.pay_type = tostring(pay_type)
    -- define( "PAY_TYPE_JOOYUU", 1 ); // 甲游自己的支付 
    -- define( "PAY_TYPE_YSDK", 2 );   //YSDK支付
    -- 默认0 就是SDK管理后台控制
    args.is_sandbox = is_sandbox

    args.role_id = tostring(myRole.role_id)
    args.role_name = myRole.role_name
    args.role_level = tostring(myRole.level)
    args.server_id = tostring(GameGlobal.real_server_id)
    args.vip_level = tostring(myRole.super_vip_level)

    -- args.setGoodsId("1");
    -- args.setFamilyName("");
    -- args.setCoinNum("0");
    printTable(args, yzjprint)
    local isok, ret = self:callJavaWithJsonStr("pay", args)
    if isok then
        gprint("fusionPay succ")
    else
        gprint("fusionPay fail")
    end   
end

function AndroidFusionSdk:setPayCallback()
    hjprint("还没有实现接口")
end




--------------------------------------
-- 获取是否登陆
--------------------------------------
function AndroidFusionSdk:isLogined()
    hjprint("还没有实现接口")
end

local alreadyEnterGame = false
function AndroidFusionSdk:enterGameCallback()
--  hjprint("enter game enter")
    if alreadyEnterGame then
        return
    end
    alreadyEnterGame = true
end

--------------------------------------
-- 是否需要order后端生成orderid
--------------------------------------
function AndroidFusionSdk:isNeedOrderId()
    return true
end

function AndroidFusionSdk:isNeedShowYongfuzhongxin()
    return false
end

function AndroidFusionSdk:enterPlatform()
    -- self:callJavaStaticMethod("org/cocos2dx/lua/AppActivity", "doUserCenter", {})
end

--------------------------------------
-- sdk自定按钮相关接口
--------------------------------------
function AndroidFusionSdk:isNeedShowCustomBtn()
    return false
end

function AndroidFusionSdk:getCustomBtnImg()
    return nil
end

local restartTipPanel
function AndroidFusionSdk:customButtonHandler()
    local msg = msg or "游戏里切换账号需要退出游戏，自动退出后请重新打开游戏"
    if ui.isExist(restartTipPanel) then
        return
    end
    
    local yes =ui.newBlueButton("退出游戏")
    yes:onClick(nil, function()
        self:callJavaWithJsonStr("logout", {})
    end)
    
    restartTipPanel = ui.createAlertView(nil, false, "restart", msg,
    nil, false, true, {
        yes
    })
    restartTipPanel.closeHandler = function(view)
        ui.removeSelf(restartTipPanel)
    end
end

--------------------------------------
-- android接口(监听java回调)
--------------------------------------
function AndroidFusionSdk:sdkJavaListener(funcType, code, msg)
    yzjprint("=============  funcType, code, msg = ", funcType, code, msg)

    if funcType == "init_succ" then
        isInit = true
        if succInitListener then
            succInitListener()
        end

    elseif funcType == "init_fail" then

    elseif funcType == "login_succ" then
        if isLogout then
            isLogout = false
        end
        local param = Helper.strToTabBySep(msg, "|")
        loginToken = param[1] or ""
        loginAccountName = param[2] or ""
        platformUid = param[3] or ""
        platformName = param[4] or ""
        if succLoginListener then
            succLoginListener()
        end
        -- 浮窗
        self:callJavaWithJsonStr("showFloatView", {is_show = "true"})

    elseif funcType == "login_fail" then
        local errTab = Helper.strToTabBySep(msg, "|")
        local errCode = errTab[1] or ""
        local errMsg = errTab[2] or ""
        -- 取消登录
        local needTips = true
        if DataGlobal.isAndroidQQPlatform() and (errCode == "2000" or errCode == "1001") then
            -- 未安装微信、qq, sdk内已有提示“亲，请先安装微信客户端”
            needTips = false
        elseif DataGlobal.isAndroid37wanPlatform() and (errCode == "204") then
            -- 37wan 登录失败, type=2,errCode=204,errMsg=初始化未完成
            needTips = false
        end

        if needTips then
            ui.showTip("登录失败！" .. errMsg)
        end
        gprint("登录失败！" .. errMsg)

    elseif funcType == "pay_succ" then
    elseif funcType == "pay_fail" then
    elseif funcType == "logout_succ" then
        isLogout = true
        if succLogoutListener then
            succLogoutListener()
        end
        if GameGlobal.isLogined then --游戏内重启
            AndroidInteractive.rebootApp()
        else
            if not self:needLoginBtn() then -- 手动点击按钮登录
                if not DataGlobal.isAndroidQQPlatform() then -- qq有登录按钮，不需要自动发起login
                    TimerManager.addTimeOut(function()
                        self:login(lastLoginName)
                    end, 0.1)
                end
            end
        end

    elseif funcType == "logout_fail" then
    elseif funcType == "exit_succ" then
    elseif funcType == "exit_fail" then
    elseif funcType == "SetLoginBtnState" then
        TimerManager.addTimeOut(function()
            Dispatcher.dispatchEvent(EventType.ANDROID_SDK_LOGIN_RESULT,{flag = true})
        end, 0.016 * 4)
    end
end


-- 需要登录按钮
function AndroidFusionSdk:needLoginBtn()
    return not(DataGlobal.isAndroidQQPlatform() or DataGlobal.isAndroidHongguanPlatform())
    -- return (DataGlobal.isAndroidTanwanPlatform()
    --     or DataGlobal.isAndroidToutiaoPlatform()
    --     or  DataGlobal.isAndroidBaiduPlatform()
    --     or DataGlobal.isAndroidUCPlatform()
    --     or DataGlobal.isAndroidChuyinPlatform()
    --     or DataGlobal.isAndroidKKUUPlatform())
end

function AndroidFusionSdk:exitSDK()
    local succ = false
    local isok, ret = self:callJavaWithJsonStr("doSDKExit", {}, "()Z")
    if isok then
        succ = ret
    end

    return succ
end

function AndroidFusionSdk:submitGameRoleInfo(param)
    local args = {}
    args.coin_num = "0"
    args.create_role_time = tostring(myRole.create_time)
    args.data_type = "3" -- 0 选择服务器  1 创建角色  2 角色升级 3 角色登录  4 角色登出 5 账号注册
    args.extras = ""
    args.family_name = ""
    args.game_name = ""
    args.level_up_time = tostring((GameGlobal.last_levelup_time or "-1"))
    args.role_category = tostring(myRole.category)
    args.role_id = tostring(myRole.role_id)
    args.role_level = tostring(myRole.level)
    args.role_name = myRole.role_name
    args.server_id = tostring(GameGlobal.real_server_id)
    args.server_name = GameGlobal.server_name-- tostring("S" .. GameGlobal.real_server_id)
    args.vip_level = tostring(myRole.super_vip_level)

    -- 保留传入参数的值
    if param then
        for k, v in pairs(args) do
            if not param[k] then
                param[k] = v
            end
        end
    else
        param = args
    end
    self:callJavaWithJsonStr("submitGameRoleInfo", param)
end

function gameEnter(self, eventParam)
    -- local argTab = {tostring(GameGlobal.real_server_id)}
    -- self:callJavaStaticMethod("org/cocos2dx/lua/AppActivity", "doSdkExtend", argTab)
end

function roleLevelChangedHandler(self, eventParam)
    -- 2 角色升级
    self:submitGameRoleInfo({level_up_time = tostring(GameGlobal.serverTime), data_type = "2"})
end

function AndroidFusionSdk:callJavaWithJsonStr(methorName, argsTab, argsType)
    local jsonStr = require("json").encode(argsTab)
    local isok, ret = require("luaj").callStaticMethod("com/jooyuu/sdk/FusionSdkUtils", methorName, {jsonStr}, argsType or "(Ljava/lang/String;)V")
    return isok, ret
end


return AndroidFusionSdk