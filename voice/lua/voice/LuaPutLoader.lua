module("LuaPutLoader", package.seeall)
local luaj
if GameGlobal.isAndroid then
	luaj= require("luaj")
end
local putLoader = false
local isInit = false
local putTasks = {}
local curPutTask = false
local getTasks = {}
local curGetTask = false

-- function init()
-- 	if not isInit then
-- 		putLoader = cc.PlFileUploader:getInstance()
-- 		if putLoader then
-- 			putLoader:setPutTimeout(20)
-- 			putLoader:setCallback(onPutCallback, onGetCallback)
-- 			isInit = true
-- 		end
-- 	end
-- end
function init()
end

-------url为拼接之后的url
-------filename为绝对路径
function putFile(url, filename, callback)
	table.insert(putTasks, {url=url, filename=filename, callback=callback})
	startPerformPutTask()
end

-------filename为保存文件的绝对路径
function getFile(url, filename, callback)
	table.insert(getTasks, {url=url, filename=filename, callback=callback})
	startPerformGetTask()
end

local function doGet(url, filename)
	if not GameGlobal.isAndroid then
		gprint("doGet不是android平台")
		return
	end
	gprint("1111111 do get !")
    luaj.callStaticMethod("com/jooyuu/GameUtil", "doGetVoice", {url, filename},"(Ljava/lang/String;Ljava/lang/String;)V")
end

local function doPut(url, filename)
	if not GameGlobal.isAndroid then
		gprint("doPut不是android平台")
		return
	end

	gprint("1111111 do put !")
	luaj.callStaticMethod("com/jooyuu/GameUtil", "doPutVoice", {url, filename},"(Ljava/lang/String;Ljava/lang/String;)V")
end


function startPerformPutTask()
	if #putTasks >= 1 and (curPutTask == false) then
		curPutTask = putTasks[1]
		doPut(curPutTask.url, curPutTask.filename)
		-- putLoader:performUpload(curPutTask.url, curPutTask.filename)
	end
end

-- function onPutCallback(_putLoader, succ, error)
-- 	local url = curPutTask.url
-- 	local filename = curPutTask.filename
-- 	if not succ then
-- 		gprint("put file failed:", url, filename)
-- 	else
-- 		gprint("put file succ:", url, filename)
-- 	end
	
-- 	if type(curPutTask.callback) == "function" then
-- 		curPutTask.callback(succ, url, filename)
-- 	end
-- 	table.remove(putTasks, 1)
-- 	curPutTask = false
-- 	TimerManager.addTimeOut(startPerformPutTask, 0)
-- end

function startPerformGetTask()
	if #getTasks >= 1 and (curGetTask == false) then
		curGetTask = getTasks[1]
		doGet(curGetTask.url, curGetTask.filename)
		-- putLoader:performGetFile(curGetTask.url, curGetTask.filename)
	end
end

-- function onGetCallback(_loader, opType, codeType, length, content)
-- 	local url = curGetTask.url
-- 	local filename = curGetTask.filename
-- 	local succ = true
-- 	if codeType ~= cc.PlFileLoader.CODE_SUCCESS then
-- 		succ = false
-- 	end
-- 	if not succ then
-- 		gprint("get file failed:", url, filename)
-- 	else
-- 		gprint("get file succ:", url, filename)
-- 	end

-- 	if type(curGetTask.callback) == "function" then
-- 		curGetTask.callback(succ, url, filename)
-- 	end	
-- 	table.remove(getTasks, 1)
-- 	curGetTask = false
-- 	TimerManager.addTimeOut(startPerformGetTask, 0)
-- end



function onPutCallback(succ)
	local url = curPutTask.url
	local filename = curPutTask.filename
	if not succ then
		gprint("put file failed:", url, filename)
	else
		gprint("put file succ:", url, filename)
	end
	
	if type(curPutTask.callback) == "function" then
		curPutTask.callback(succ, url, filename)
	end
	table.remove(putTasks, 1)
	curPutTask = false
	TimerManager.addTimeOut(startPerformPutTask, 0)
end

function onGetCallback(succ)
	local url = curGetTask.url
	local filename = curGetTask.filename
	if not succ then
		gprint("get file failed:", url, filename)
	else
		gprint("get file succ:", url, filename)
	end

	if type(curGetTask.callback) == "function" then
		curGetTask.callback(succ, url, filename)
	end	
	table.remove(getTasks, 1)
	curGetTask = false
	TimerManager.addTimeOut(startPerformGetTask, 0)
end