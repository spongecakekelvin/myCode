--------------------------
-- 资源管理器
--------------------------
module("ResManager", package.seeall)


-- 更大的资源放前面
local resMap = {
    "res/plist/jianshi.plist",
}

-- 加载资源
-- TODO： 增加LoadingView ，逐帧加载进入游戏后用到的资源等
function loadAll()
	local timerId
	local resCount = 1
	local resNum = #resMap

	
	local function loadFunc()
		Log.i(resCount, resNum)
		if resCount > resNum then
			TimeManager.removeTimer(timerId)
			timerId = nil
			return
		end

		local count = 0
    	for i = resCount, resNum do
	        -- Log.i("loading key = " .. i .. ", path = " .. resMap[i])
	        helper.addPlist(resMap[i])

	        count = count + 1
	        if count >= 10 then
	        	break
	        end
	    end
	    resCount = resCount + count
	end
	
	timerId = TimeManager.addTimer(loadFunc, 0)
end
