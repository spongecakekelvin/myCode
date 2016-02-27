--------------------------
-- 动画管理器
--------------------------
module("AnimManager", package.seeall)

local timerId = nil
local loopList = {}
local frameLoopFunc

function init()
	if timerId then
		TimeManager.removeTimer(timerId)
	end
	timerId = TimeManager.addTimer(frameLoopFunc, setting.fps)
	-- timerId = TimeManager.addTimer(frameLoopFunc, 0.5)
end


function addToLoopList(animNode)
	table.insert(loopList, animNode)
end

-- 动画帧循环函数, 根据当前状态和下一帧状态执行
function frameLoopFunc()
	for i, animNode in ipairs(loopList) do
		animNode:updateFrame()
	end
end