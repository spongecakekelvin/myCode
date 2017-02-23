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
module("IosInteractive", package.seeall)
local luaoc
if GameGlobal.targetPlatform == cc.PLATFORM_OS_IPHONE or  GameGlobal.targetPlatform == cc.PLATFORM_OS_IPAD then
    luaoc = require("luaoc")
end
function getOneValueFromObjectc(method, args)
    --    local args = { num1 = 2 , num2 = 3 }
    local className = "S3LuaObjectCBridg"
    local ok, ret = luaoc.callStaticMethod(className, method, args)
    if not ok then
        --        Director:getInstance():resume()
        if ccprint then
            ccprint("failed The ret is:", ret)
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


function isWifiConnected()
    local ok, ret = luaoc.callStaticMethod("S3LuaObjectCBridg", "getNetStatus", {})
    if ccprint then
        ccprint("getNetStatus The ret is:", ret)
    end
    local ok, ret = luaoc.callStaticMethod("S3LuaObjectCBridg", "dataNetworkTypeFromStatusBar", {})
    if ccprint then
        ccprint("isWifiConnected The ret is:", ret)
    end
    return ret == 1
end

function getIosUUID()
    local uuid = ""
    uuid = IosInteractive.getOneValueFromObjectc("getSFHFKey",
    {
        username = tostring("username"),
        serviceName = tostring("serviceName"),
    })
    
    return uuid
end


function startMp4(www, hhh)
    local visibleRect = nil
    local args = nil
    local device = cc.Application:getInstance():getTargetPlatform()
    if (device == cc.PLATFORM_OS_IPAD) then

        visibleRect = cc.Director:getInstance():getOpenGLView():getFrameSize()
        --        args = { num1 = visibleRect.width, num2 = visibleRect.height, mpath = "res/startmovie", skipname = "跳过" }
        --        args = { num1 = visibleRect.width*2, num2 = visibleRect.height*2, mpath = "res/startmovie", skipname = "跳过" }
    else
        --        visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
        visibleRect = cc.Director:getInstance():getOpenGLView():getFrameSize()
    end
    if www then
        visibleRect.width = www
    end

    if hhh then
        visibleRect.height = hhh
    end
    args = { num1 = visibleRect.width, num2 = visibleRect.height, mpath = "res/startmovie", skipname = "跳过" }

    --    local visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
    --    local visibleRect = cc.Director:getInstance():getOpenGLView():getFrameSize()
    --    local args = { num1 = visibleRect.width*2, num2 = visibleRect.height*2, mpath = "res/startmovie", skipname = "跳过" }

    if ccprint then
        ccprint(visibleRect.width, visibleRect.height)
    end


    local ok, ret = luaoc.callStaticMethod("S3LuaObjectCBridg", "startMovieMp4", args)
    if not ok then
        --        Director:getInstance():resume()
        if ccprint then
            ccprint("startMp4 failed The ret is:", ret)
        end

    else
        if ccprint then
            ccprint("startMp4 The ret is:", ret)
        end
    end

    local function callback(param)
        if "success" == param then
            if ccprint then
                ccprint("startMp4 object c call back success")
            end
        end
    end

    luaoc.callStaticMethod(className, "registerScriptHandler", { scriptHandler = callback })
    luaoc.callStaticMethod(className, "callbackScriptHandler")
end


function addReceipt(roleid,receipt)
    if GameGlobal.isDebug  then
    local md5 = require("gamecore/util/md5")
--    receipt = string.trim(receipt)
    local md5key = md5(receipt)


    local key = cc.UserDefault:getInstance():getStringForKey("appstorereceiptkey".. roleid, "")
            if key=="" then
                key =  md5key
                else
                key = key.. "%%" .. md5key
            end
    ccprint(key)

    cc.UserDefault:getInstance():setStringForKey("appstorereceiptkey".. roleid , key)
    cc.UserDefault:getInstance():setStringForKey(md5key, receipt)


    TimerManager.addTimeOut(function()
        ccprint("time out and again")
        validReceiptInfo(receipt)
    end,35)

        end
end

function getCurrentReceiptKey(roleid)
    --         local md5 = require("gamecore/util/md5")
    --         ccprint(md5)
    --        local md5key = md5(receipt)
    if GameGlobal.isDebug  then

    local key = cc.UserDefault:getInstance():getStringForKey("appstorereceiptkey"..roleid, "")
    return string.split(key, "%%")
        end
end

function deleteInvalidKey(roleid,keytable)
    if GameGlobal.isDebug  then
    --         local md5 = require("gamecore/util/md5")
    --         ccprint(md5)
    --        local md5key = md5(receipt)
    local currentkey = getCurrentReceiptKey(roleid)
    local value = nil
    for i = 1, table.getn(keytable) do
        value = keytable[i]
        ccprint(value)
        cc.UserDefault:getInstance():setStringForKey(value, "")
        local currentkeylen = table.getn(currentkey)
        for j = 1, currentkeylen do
            if currentkey[j] == value then
               table.remove(currentkey, j)
                break
            end
        end

        if j == currentkeylen then
            ccprint("error: could not find" .. value)
        end
    end

    local key = ""
    local len = table.getn(currentkey)
    for j = 1, len do
        value = currentkey[j]
        if value then
            local key = cc.UserDefault:getInstance():getStringForKey(value, "")
            if key~="" then
                if j == len then
                    key = key .. value
                else
                    key = key .. value .. "%%"
                end
            end


        end
    end

    ccprint(key)
    cc.UserDefault:getInstance():setStringForKey("appstorereceiptkey"..roleid, key)

    end

end


function requestReceiptInfo(roleid)
    if GameGlobal.isDebug  then
        local vo = ccproto.m_appstore_receipt_info_tos()
        vo.receipts = getCurrentReceiptKey(roleid)
        ProtoManager.send(vo)
    end

end

function validReceiptInfoBymd5(md5str)
    local key = cc.UserDefault:getInstance():getStringForKey(md5str, "")
    if key~="" then
       validReceiptInfo(key)
    else
        ccprint("error:no receipt")
    end

end

function validReceiptInfo(receipt)
    if GameGlobal.isDebug  then


    local md5 = require("gamecore/util/md5")
    local vo = ccproto.m_appstore_receipt_verify_tos()
    vo.md5 = md5(receipt)
    vo.receipt = receipt
    ProtoManager.send(vo)

    end
end