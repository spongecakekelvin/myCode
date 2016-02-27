module("GuideData", package.seeall)

local introConfig = require "config/GuideIntroConfig"

function getIntro(key)
    return introConfig[key]
end

local fistEnterConfig = require "config/GuideFirstEnterConfig"

-- 阶段引导奖励的当前引导奖励id
local periodId = nil
function getCurrentPeriodRewardConfig()
	return fistEnterConfig[periodId]
end

function getCurrentPeriodId()
	return periodId
end


function setPeriodId(id)
	periodId = id + 1
end

function getPeriodId()
	return periodId
end



local isIndexCanDialog
--------------------------------------
-- 逐字显示对话
-- func = showWordOneByOne(label, word, speed, func, ...)
-- func(switch)
-- 参数：
-- 	label 要逐字显示的文本框
-- 	word 文字
-- 	speed 每字速度 （可选）
-- 	func 对话显示完调用的函数 （可选）
-- 	... func的参数 
-- 	switch 开始/关闭 (Boolean)
--------------------------------------
function showWordOneByOne(label, word, speed, func, ...)
	local index = 1
	local len = string.len(word)
	local scheduleId = nil
	local func = func or nil
	local args = {...}
	local delayTime = 0 -- 播放完成延时调用callback
	speed = speed or SystemConfig.dialogSpeed
			
	return function(switch)
		if switch == "on" then
			scheduleId = TimerManager.scheduleGlobal(function()
					local canSub, tempIndex = isIndexCanDialog(word, index)
					
					if canSub then
						index = tempIndex
						local subWord = string.sub(word, 1, index)
						if not tolua.isnull(label) then
							label:setString(subWord)
						end
					elseif string.sub(word, index, index) == "$" then
						index = index + 2
					end
					
					index = index + 1
					if index > len then
						delayTime = delayTime + speed
						if delayTime > 1 then
							if func then
								func(unpack(args))
							end
							index = 1
							TimerManager.unscheduleGlobal(scheduleId)
						end
					end
				end,
				speed
			)
		elseif switch == "off" then
			if func then
				func(unpack(args))
			end
			if scheduleId then 
				TimerManager.unscheduleGlobal(scheduleId)
			end
			index = 1
		elseif switch == "finish" then
			if not tolua.isnull(label) then
				label:setString(word)
				index = len
			end
		end
	end	--return function
end


--------------------------------------
-- 筛选对话框的显示内容
-- 返回  bool, 有效索引
--------------------------------------
function isIndexCanDialog(str, index)
	local byteStr = string.sub(str, index, index)
	local curByte = string.byte(byteStr)
	
	if curByte == nil then---防止空字符串
		return true, index
	end
	
	local lastByte = string.byte(str, index - 1, index - 1)
	
	local newIndex = index
	local isCan = true
	if curByte > 224 then--中文判断
		isCan = false
		newIndex = index - 1
	elseif curByte > 126 and curByte <= 224 then--中文判断
		if lastByte > 224 then
			isCan = false
			newIndex = index - 2
		end
	end
	if byteStr == "$" then return false end
	return isCan, newIndex
end