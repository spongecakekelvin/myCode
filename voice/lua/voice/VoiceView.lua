local BaseClass = ui.BaseLayer
local VoiceView = class("VoiceView",BaseClass)

local schedulerEntry = false

function VoiceView:ctor()
    BaseClass.ctor(self,false,false,true)

    self.size = cc.size(150, 200)
    self:setContentSize(self.size)

    self.isSpeaking = true

    --- 关闭回调
    self.exitCallbackType = "stop"
end

function VoiceView:onEnter()
    BaseClass.onEnter(self)

    GameMusicManager.pauseSound() -- 停止声音


    local spr = ui.newSpr("moduleImgs/chatVoice/voiceImg1.png")
    self.stateSpr = spr
    ui.addChild(self, spr, 0, 0, 0.5, 0)

    local countDownTime = VoiceData.getRecordTime()
    
    local label = ui.newLabel(countDownTime,22,ui.color.green)
    label.countDownTime = countDownTime
    self.countDownLabel = label
    ui.addChild(self, label, 0,-50, 0.5, 0)

    local function loopFunc()
        if not tolua.isnull(self.countDownLabel) and self.countDownLabel.countDownTime then

            self.countDownLabel.countDownTime = self.countDownLabel.countDownTime - 1
            self.countDownLabel:setString(self.countDownLabel.countDownTime)

            if self.countDownLabel.countDownTime <= 0 then
                VoiceController.closeView()
            end
        end
    end

    if schedulerEntry then
        TimerManager.unscheduleGlobal(schedulerEntry)
        schedulerEntry = false
    end
    schedulerEntry = TimerManager.scheduleGlobal(loopFunc, 1) 


    local localVoiceId = VoiceController.startRecord()
    self.localVoiceId = localVoiceId or 0
    -- 下面开始倒计时60s
    if self.localVoiceId then
        VoiceData.recordBeganTime(self.localVoiceId)
    end
end


function VoiceView:onExit()
    BaseClass.onExit(self)

    GameMusicManager.resumeSound() -- 继续声音
    VoiceController.stopRecord()
    if self.localVoiceId then
        VoiceData.recordEndedTime(self.localVoiceId)
    end
    local voicetime = VoiceData.getVoiceTime()
    if self.exitCallbackType then
        if self.exitCallbackType == "stop" and voicetime > 1 then
            VoiceController.startBaiduRecognize(self.localVoiceId)
        else 
            VoiceController.deleteFile(VoiceData.getAbsFileUrl(self.localVoiceId))
        end
    end

    if schedulerEntry then
        TimerManager.unscheduleGlobal(schedulerEntry)
        schedulerEntry = false
    end
end

function VoiceView:closecallback(exitCallbackType)
    self.exitCallbackType = exitCallbackType or "stop"
end

function VoiceView:onTouchEnded(touch, event)
--    local isTouch = BaseClass.onTouchEnded(self, touch, event)
    VoiceController.closeView()
end

function VoiceView:changeSpeakingState(isSpeaking)
    if self.isSpeaking == isSpeaking then
        return
    end
    self.isSpeaking = isSpeaking

--    local path = isSpeaking and "#chat/voiceStart.png" or "#chat/voiceCancel.png"
--    if not tolua.isnull(self.stateSpr) then
--        -- voiceCancel
--        ui.changeSpr(self.stateSpr, path)
--    end
--
--    path = isSpeaking and "#chat/voiceTips.png" or "#chat/voiceTips_cancel.png"
--    if not tolua.isnull(self.tipsSpr) then
--        ui.changeSpr(self.tipsSpr, path)
--    end
end




return VoiceView