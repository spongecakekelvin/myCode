--------------------------
-- YuZhenjian
-- 2015年7月7日
-- 语音控制器
--------------------------
module("VoiceController", package.seeall)
local voiceView
local isPlaying
local isInitialized
local luaj
if GameGlobal.isAndroid then
    luaj = require("luaj")
end
local center = VisibleRect:center()
local isStop = true
function init()
     isPlaying = false

    isInitialized = false --初始化SpeechUtility
     initAndroidVoiceManagement()
     ProtoManager.addListenServer(ccprotoName.chat_req_voice, m_chat_req_voice_toc)
     ProtoManager.addListenServer(ccprotoName.chat_auth, m_chat_auth_toc)
end

-- 由java初始化语音sdk时调用
function initAndroidVoiceManagement()
    -- -- 没有调用java的代码 所以不需要此限制了
    if not GameGlobal.isAndroid  or not VoiceData.isAndroidVersionSupported() then
        gprint("initAndroidVoiceManagement -- 不支持")
        return
    end

    if  isInitialized then
        -- gprint("initAndroidVoiceManagement -- VoiceManager已经初始化")
        return
    end
     isInitialized = true

--    VoiceData.setWritePath()
    VoiceData.setAndoirdWritePath()
end

function setAccessToken(accessToken)
    isStop = true
    VoiceData.setAccessToken(accessToken)
end

function openView()
    if not isStop then
        --ccprint("上一次的语音对话还未结束")
        return
    end
    local lastspeaktime = VoiceData.getLastSpeakingTime()
    local intervaltime = GameGlobal.serverTime - lastspeaktime
    if intervaltime < 5 then
        ui.showTip("5秒之内不能重复发言，请稍候！")
        return
    end
    if tolua.isnull(voiceView) then
--        isStop = false
        voiceView = (require "gamecore/modules/voice/VoiceView").new({})
        voiceView:setPosition(center.x, center.y - 100)
        ui.addChild(LayerManager.alertLayer, voiceView)
    end
end

local voiceani
function closeView(exitCallbackType)
    if not tolua.isnull(voiceView) then
        voiceView:closecallback(exitCallbackType)
        ui.removeSelf(voiceView)
    
        local voicetime = VoiceData.getVoiceTime()
        if voicetime <= 1 and not ui.isExist(voiceani) then
            voiceani = ui.newSpr("moduleImgs/chatVoice/anjianshuohua.png")
            ui.addChild(LayerManager.alertLayer, voiceani, center.x, center.y - 100, 0.5, 0)       
            voiceani:runAction(cc.Sequence:create(
                cc.FadeOut:create(0.5),
                cc.CallFunc:create(function()
                    ui.removeSelf(voiceani)
                end)
            ))
        end
    end
end


function changeSpeakingState(isSpeaking)
    if not tolua.isnull( voiceView) then
        voiceView:changeSpeakingState(isSpeaking)
    end
end


function isBlock()
    if not VoiceData.isVoiceSupported() or
     not VoiceData.isVoiceExecutable() then
        return true
    end
    return false
end


-- //请求语音聊天
-- message m_chat_req_voice_tos{
--     optional string          local_voice_id     = null;//本地的语音文件ID
-- }
function requestVoiceInfo(localVoiceId)
    if not localVoiceId then
        return
    end
    if type(localVoiceId) ~= "string" then
        localVoiceId = tostring(localVoiceId)
    end

    local msg = ccproto:m_chat_req_voice_tos()
    msg.local_voice_id = localVoiceId
    ProtoManager.send(msg)

end


-- message m_chat_req_voice_toc{
--     required bool            succ               = true;//成功失败标记
--     optional string          reason             = null;//失败原因
--     optional string          local_voice_id     = null;//本地的语音文件ID
--     optional string          voice_guid         = null;//聊天内容
--     optional int32           tstamp             = 0;//时间戳
--     optional string          sign               = null;//验证签名
-- }
function m_chat_req_voice_toc(msg)
    --printTable(msg)
    if msg.succ then
        -- 保存数据并 上传录音文件
        VoiceData.saveCurrentVoiceInfo(msg)
    end
end


function m_chat_auth_toc(msg)
    --printTable(msg)
    --gprint("==== accessToken === ")
    if not msg.chat_tokens then
        return
    end
    local accessToken = msg.chat_tokens[1]
    if accessToken and accessToken ~= "" then
         initAndroidVoiceManagement()
         setAccessToken(accessToken)
    end
end

-- 开始录音
function startRecord()
    if  isBlock() then
        return
    end

    if not isStop then
        return
    end


    local localVoiceId = VoiceData.genLocalVoiceId()
    -- NotifyOnScreen.add("录制voiceid = " .. localVoiceId)
    VoiceData.saveRecognizeVoiceId(localVoiceId)
    isStop = false
    local args = {VoiceData.getAbsFileUrl(localVoiceId)} --录音文件id， 是否自动播放"true" / "false"
    luaj.callStaticMethod("com/jooyuu/GameUtil", "startRecord", args,"(Ljava/lang/String;)V")

    return localVoiceId
end

-- 停止录音
function stopRecord()
    ccprint("stopRecord1")
    if  isBlock() then
        return
    end
    ccprint("stopRecord2")
    isStop = true

    luaj.callStaticMethod("com/jooyuu/GameUtil", "stopRecord", {},"()V")
end



-- 开始识别
function startBaiduRecognize(localVoiceId)
    if  isBlock() then
        return
    end

    ccprint("录制voiceid = " .. localVoiceId)
    VoiceData.saveRecognizeVoiceId(localVoiceId)

    local args = {VoiceData.getAbsFileUrl(localVoiceId)} --录音文件id， 是否自动播放"true" / "false"
    luaj.callStaticMethod("com/jooyuu/GameUtil", "startBaiduRecognize", args,"(Ljava/lang/String;)V")

    return localVoiceId
end


-- -- 停止录音(立刻得到结果)
-- function stopRecognize()
--     if  isBlock() then
--         return
--     end

--     -- NotifyOnScreen.add("停止")
--     luaj.callStaticMethod("com/jooyuu/GameUtil", "stopRecognize", {},"()V")
-- end

-- -- 取消录音
-- function cancelRecognize()
--     if  isBlock() then
--         return
--     end
--     NotifyOnScreen.add("取消")
--     luaj.callStaticMethod("com/jooyuu/GameUtil", "cancelRecognize", {},"()V")
-- end


-- 一下是java调用
function onVoiceBeginOfSpeech()
    -- NotifyOnScreen.add("录音开始了")
end

function onVoiceEndOfSpeech()
    -- NotifyOnScreen.add("录音结束了")
    if not tolua.isnull( voiceView) then
        NotifyOnScreen.add("静音时间过长，录音结束")
        --gprint("被动关掉lll")
        closeView()
    end
end

function onVoiceResult(resultStr)
    resultStr = resultStr or ""
--    NotifyOnScreen.add(resultStr)
    --gprint("onVOiceRsult = " .. resultStr)

    VoiceData.saveResultStr(resultStr)
end

function onVoiceVolumeChanged(volumn) -- int
    -- do nothing
end

function onVoiceError(errStr)
    NotifyOnScreen.add(errStr)
end


local function playVoiceFunc(self, voice_guid)
    if  isPlaying then
        return
    end
    
    local filename = VoiceData.getAbsFileUrl(voice_guid) -- 文件绝对路径名
    if cc.PlFileLoader:getFileLength(filename) > 0 then
         isPlaying = true --播放成功

        GameMusicManager.pauseSound() -- 停止声音

        local args = {filename} --录音文件id， 是否自动播放
        local isOk, ret = luaj.callStaticMethod("com/jooyuu/GameUtil", "playVoice", args,"(Ljava/lang/String;)V")

        VoiceData.setUnread(voice_guid, false)
    end
end

-- 播放本地录音
function playVoice(voice_guid)
    if not voice_guid then
        return
    end

    if  isBlock() then
        return
    end

    if  isPlaying then
        -- NotifyOnScreen.add("正在播放中~~~~~~~~~~~~~~~")
        --gprint("正在播放中~~~~~~~~~~~~~~~")
        return
    end

    local filename = VoiceData.getAbsFileUrl(voice_guid) -- 文件绝对路径名
    local fileLength = cc.PlFileLoader:getFileLength(filename)
    -- gprint("=== cc.PlFileLoader:getFileLength(filename) = " .. fileLength)

    if fileLength > 0 then -- 文件存在 
        -- 播放
        playVoiceFunc(self, voice_guid)
    else
        if not VoiceData.getDownloadingRecord(voice_guid) then
            VoiceData.setDownloadingRecord(voice_guid) -- 下载一次

            VoiceData.getVoiceByLoader(voice_guid, function()
                -- 下载再播放
                playVoiceFunc(self, voice_guid)
            end)
        end
    end
    
end


function onPlayVoiceFinish()
    --NotifyOnScreen.add("播放完成了")
    isPlaying = false
    GameMusicManager.resumeSound() -- 停止声音
end



function renameFile(oldPath, newPath)
    if  isBlock() then
        return
    end
    luaj.callStaticMethod("com/jooyuu/GameUtil", "renameFile", {oldPath, newPath},"(Ljava/lang/String;Ljava/lang/String;)V")
end


function deleteFile(path)
    if  isBlock() then
        return
    end
    luaj.callStaticMethod("com/jooyuu/GameUtil", "deleteFile", {path},"(Ljava/lang/String;)V")
end