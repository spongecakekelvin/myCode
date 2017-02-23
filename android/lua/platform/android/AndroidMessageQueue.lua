------------------------------------------------------
--作者:	yhj
--日期:	2015年7月7日
--描述:	android
------------------------------------------------------
module("AndroidMessageQueue", package.seeall)

local curMessageQueue = {}
local delayList = {}

local isPause = false
local activityPauseHandler
local activityResumeHandler
local loopHandleMessage
local initOnce = false
function AndroidMessageQueue:init()
	if not initOnce then
		initOnce = true
		Dispatcher.addEventListener(EventType.ANDROID_ON_PAUSE, activityPauseHandler, self)
		Dispatcher.addEventListener(EventType.ANDROID_ON_RESUME, activityResumeHandler, self)	
	end
end

function activityPauseHandler()
	isPause = true
end

local scheduleId
function activityResumeHandler()
	isPause = false
	TimerManager.clearTimeOut(scheduleId)
	
--	printTable(curMessageQueue)
	scheduleId = TimerManager.addTimeOut(function() 
		loopHandleMessage()
	end, 2)
end

function loopHandleMessage()
	if isPause then
		return
	end
	for i = 1, #curMessageQueue do
		handle(curMessageQueue[i])
	end
	curMessageQueue = {}

	if #delayList > 0 then
		for _, v in pairs(delayList) do
			v.callback(v.param)
		end
		delayList = {}
	end
end


function handle(valueStr)
	local temp = Helper.strToTabBySep(valueStr, "#")
	local funcType =  temp[1]
	local code =  temp[2]
	local str = temp[3]
	if #temp > 3 then
		for i = 4, #temp do
			str = str .. "#" .. temp[i]
		end
	end
	
	local msg = str or ""
	
	hjprint(funcType, code, msg)
	
	local sdk = Sdk.getCurSdk()
	if sdk then
		sdk:sdkJavaListener(funcType, code, msg)
	else
		hjprint("no listener", funcType, code, msg)
	end
end



function enqueue(msg)
	if not isPause then
		handle(msg)
	else
		hjprint("insert~~", msg)
		table.insert(curMessageQueue, msg)
	end
end


function delayCall(callback, param)
	if not isPause then
		callback(param)
	else
		table.insert(delayList, {callback = callback, param = param})
	end
end

