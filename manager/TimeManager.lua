--------------------------
-- 时间管理器
-- 定时调用、延时调用
--------------------------
module("TimeManager", package.seeall)

local MAX = 2 * 32
local scheduleId = nil

local KEY_TIMER = 1
local KEY_DELAY = 2

local ID = {}
ID[KEY_TIMER] = 0
ID[KEY_DELAY] = 0 

-- [id] = {callback = function, loopTime = 0.016, curTime = 0}
local loopList = {}
loopList[KEY_TIMER] = {}
loopList[KEY_DELAY] = {}

-- 生成计时器唯一id
local generateId

function init()
	if scheduleId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
		scheduleId =  nil
	end

	ID[KEY_TIMER] = 0
	ID[KEY_DELAY] = 0

	cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		for k, v in pairs(loopList[KEY_TIMER]) do
			if v.curTime >= v.maxTime then
				v.curTime = 0
				v.callback(dt)
			else
				v.curTime = v.curTime + dt
			end
		end

		for k, v in pairs(loopList[KEY_DELAY]) do
			if v.curTime >= v.maxTime then
				v.callback()
				removeDelay(k)
			else
				v.curTime = v.curTime + dt
			end
		end
	end, 0, false)
end


-- 添加定时器调用
function addTimer(callback, dt)
	local key = generateId(KEY_TIMER)
	dt = dt or 0
	loopList[KEY_TIMER][key] = {callback = callback, maxTime = dt, curTime = dt}
	return key
end

-- 添加延迟调用
function addDelay(callback, dt)
	local key = generateId(KEY_DELAY)
	dt = dt or 0
	loopList[KEY_DELAY][key] = {callback = callback, maxTime = dt, curTime = 0}
	return key
end



  
function removeTimer(key)
	if key then
		loopList[KEY_TIMER][key] = nil
	end
end

function removeDelay(key)
	if key then
		loopList[KEY_DELAY][key] = nil
	end
end


-- 生成计时器唯一id
function generateId(key)
	local id = ID[key]
	while loopList[key][id] do
		if id == MAX then
			Log.e("timer id 溢出")
			id = 0
			break
		end
		id = id + 1
	end
	ID[key] = id
	return id
end
