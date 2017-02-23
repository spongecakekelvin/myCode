module("SdkLuaMsg", package.seeall)

local msgQ = {}
local isPause = false
local pauseHandler
local resumeHandler
local loopHandleMessage
local scheduleId

function init()
     Dispatcher.addEventListener(EventType.ANDROID_ON_PAUSE, pauseHandler, self)
     Dispatcher.addEventListener(EventType.ANDROID_ON_RESUME, resumeHandler, self)
end

function enter(msg)
    gprint("enter when isPause: ", isPause)
    if not isPause then
        doHandle(msg)
    else 
        table.insert(msgQ, msg)        
    end
end

function pauseHandler()
    gprint("call pauseHandlerß")
    isPause = true
end

function resumeHandler()
    gprint("call resumeHandler")
    isPause = false
    TimerManager.clearTimeOut(scheduleId)
    scheduleId = TimerManager.addTimeOut(function() 
        gprint("start loopHandleMessage")
		loopHandleMessage()
	end, 2)
end

function loopHandleMessage()
    if isPause then 
        return
    end
    for i=1, #msgQ do 
        doHandle(msgQ[i])
    end
    msgQ = {}
end

function doHandle(valueStr)
    -- local temp = Helper.strToTabBySep(valueStr, "#")
    -- local funcType =  temp[1]
    -- local code =  temp[2]
    -- local str = temp[3]
    -- if #temp > 3 then
    --  for i = 4, #temp do
    --      str = str + "#" + temp[i]
    --  end
    -- end
    
    -- local msg = string.sub(str,2,string.len(str) - 1)
    local funcType, code, msg = doParse(valueStr)
    local handleFun = SdkLuaInterface[funcType]
    if handleFun and type(handleFun) == "function" then
        handleFun(code, msg)
    else
        print("SdkLuaInterface not implented func" .. funcType)        
    end    
end

function doParse(str)
    local func, code, argsStr
    local index = string.find(str, "#")
    if not index then
        gprint("invalid msg from java/ios(check func)", str)
        return
    end
    
    func = string.sub(str, 1, index-1)
    
    local index2 = string.find(str, "#", index+1)
    if not index2 then 
        gprint("invalid msg from java/ios(check code)", str)
        return
    end
    code = tonumber(string.sub(str, index+1, index2-1)) or 0
    
    argsStr = string.sub(str, index2+2, string.len(str)-1)
    return func, code, argsStr
end

----解析login返回的参数
----"key:val#key:val#"
function doParseLogin(str)
    -- local tmp = {}
    -- for k, v in string.gmatch(str, "(%w+):(%w+)") do 
    --     tmp[k] = v 
    -- end
    -- return tmp
    local tmp = {}
    local spos = 1
    local epos = 0
    while true do
        epos = string.find(str, "#", spos)
        if not epos then break end 
        local s = string.sub(str, spos, epos-1)
        
        local tmppos = string.find(s, ":")
        if not tmppos then 
            tmp[s] = false
        else 
            tmp[string.sub(s, 1, tmppos-1)] = string.sub(s, tmppos+1)            
        end
        -- table.insert(tmp, s)
        spos = epos+1
    end
    return tmp    
end