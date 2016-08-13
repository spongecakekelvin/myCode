--------------------------
-- 场景管理器
--------------------------
module("SceneManager", package.seeall)

local SceneList = {
	["init"] = nil,
	["game"] = nil,
}

-- 初始化函数
local initFunc = {}

-- 场景层
sceneLayer = nil
-- ui层
uiLayer = nil
-- 界面层
windowLayer = nil
-- 提示层
alertLayer = nil


function getScene(sceneName)
	local scene = SceneList[sceneName]
	if not scene then
		scene = cc.Scene:create()
		scene:retain()
	end
	return scene
end


function runScene(sceneName)
	local scene = getScene(sceneName)
	local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene then 
    	-- todo: 切换场景前清空定时器、事件监听等内容
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

    -- 调用对应的初始化函数 只一次
	if not SceneList[sceneName] and initFunc[sceneName] then
		SceneList[sceneName] = scene
		initFunc[sceneName](scene)
	end
end
 


initFunc["init"] = function(scene)
	require "GameInit"

    -- local view = require("SplashView").new()
    -- scene:addChild(view)

    TimeManager.addDelay(function()
    	SceneManager.runScene("game")
	end, 0.5)
end


initFunc["game"] = function(scene)
	local rootLayer = ui.newLayer(cc.c4b(255, 255, 255, 255)) 

	sceneLayer = cc.Layer:create()
	uiLayer = cc.Layer:create()
	windowLayer = cc.Layer:create()
	alertLayer = cc.Layer:create()

    rootLayer:addChild(sceneLayer)
    rootLayer:addChild(uiLayer)
    rootLayer:addChild(windowLayer)
    rootLayer:addChild(alertLayer)

    scene:addChild(rootLayer)

    -- 进入游戏
    EventManager.dispatch(EventType.game_enter)
    EventManager.dispatch(EventType.create_fight_view)
    EventManager.dispatch(EventType.create_main_ui_view)
end

