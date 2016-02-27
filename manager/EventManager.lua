-- 事件管理器
-- （全局监听）
module("EventManager", package.seeall)

local eventList = {}

-- eventParam
-- @ eventType 事件名
-- @ listener -- 监听函数
-- @ object -- 函数传入的对象
function addListener(eventType, listener, object)
	if eventList[eventType] then
		local isExist = false
		for i, v in ipairs(eventList[eventType]) do
			if v.listener == listener then
				isExist = true
				break
			end
		end

		if not isExist then
			table.insert(eventList[eventType], {listener = listener, object = object})
		else
			Log.e("监听列表中已存在事件 event type = " .. EventTypeName[eventType])
		end
	else
		eventList[eventType] = {}
		table.insert(eventList[eventType], {listener = listener, object = object})
	end
	-- Log.t(eventList)
end

function removeListener(evnetType, listener)
	if eventList[evnetType] then
		for i, v in ipairs(eventList[evnetType]) do
			if v.listener == listener then
				table.remove(eventList[eventType], i)
				break
			end
		end
	end
end

function dispatch(eventType, ...)
	-- Log.i("=====dispatch= evnetType = " .. EventTypeName[eventType])
	if eventList[eventType] then
		for i, v in pairs(eventList[eventType]) do
			if v.object then
				v.listener(v.object, ...)
			else
				v.listener(...)
			end
		end
	else
		Log.i("事件没有监听 eventType = " .. EventTypeName[eventType])
	end
	-- Log.t(eventList)
end
