------------------------------------------------------
--作者:	余振健
--日期:	2013年12月13日
--描述:	剧情特效表现控制器
------------------------------------------------------
DramaController = class("DramaController", Controller)

require "DramaDataCenter"
require "DramaWordView"
require "DramaCopyView"
require "DramaSlideView"


local userData = CCUserDefault:sharedUserDefault()

local commitTaskDramaHandler
local sceneChangedDramaHandler
local dramaWordEndHandler
local dramaSlideEndHandler

local createDramaWordView
local dramaCopyStartHandler

function DramaController:init()
	--监听事件
	self:initListener()
end


--监听事件
function DramaController:initListener()
	--------------------------------------
	-- 以下是普通事件监听
	--------------------------------------

	--出生的剧情表现
--	EventDispatcher.addEventListener(EventType.SCENE_CHANGED, sceneChangedDramaHandler, self)
	--任务触发的剧情表现
	EventDispatcher.addEventListener(EventType.COMMIT_TASK, commitTaskDramaHandler, self)
	
	
	-- 剧情副本开始事件
	EventDispatcher.addEventListener(EventType.SCENE_CHANGED, dramaCopyStartHandler, self)
	
	-- 剧情文字表现结束
	EventDispatcher.addEventListener(EventType.DRAMA_WORD_END, dramaWordEndHandler, self)
	
	-- 剧情过场动画结束
	EventDispatcher.addEventListener(EventType.DRAMA_SLIDE_END, dramaSlideEndHandler, self)
	
	--------------------------------------
	-- 以下是协议监听
	--------------------------------------
	

end

--------------------------------------
-- 剧情文字表现
--------------------------------------

--场景改变后出现
function sceneChangedDramaHandler(self, param)
	--第一次出生
	if not self.once and param.oldValue == 0 and param.newValue == 10240 and myRole.model and myRole.model.level == 1 then
		local newBorn = userData:getBoolForKey("newBorn" .. myRole.model.name)
--		if true then
		if not newBorn then
			userData:setBoolForKey("newBorn" .. myRole.model.name, true)
--			-- 进入萧薰儿剧情副本
--			local eventParam = EventParam.create()
--			eventParam.isGlobal			= true
--			eventParam.newValue			= DramaDataCenter.firstSceneId
--			EventDispatcher.dispatchEvent(EventType.ENTER_QUIT_COMMON_COPY, eventParam)
 			-- 开场动画				
			local dramaSlideModel = DramaDataCenter.getDramaSlideById(2)
			if dramaSlideModel then
				local slideView = DramaSlideView.new(dramaSlideModel)
				slideView:setPosition(VisibleRect:center())
				GameView.tipLayer:addChild(slideView)
			end
		else
			Log.info("虽然你是1级，但是你已经进入过出生的剧情了，userdata里面都有你出生的记录！")
		end
		self.once = true
	end
end

-- 提交任务后出现
--{operaType = nowOpera, npcId = self.npcModel.id, taskId = self.taskModel.id}
function commitTaskDramaHandler(self, param)
	local msg = param.newValue
	local dramaModel = DramaDataCenter.getDramaById(msg.taskId)
	local dramaCopyModel = DramaDataCenter.getDramaCopyByTaskId(msg.taskId)
	
	--- 剧情表现
	if dramaModel and dramaModel.type == msg.operaType then
		createDramaWordView(self, dramaModel)
		
	--- 剧情副本
	elseif dramaCopyModel and dramaCopyModel.taskState == msg.operaType then
		local eventParam = EventParam.create()
		eventParam.isGlobal			= true
		eventParam.newValue			= dramaCopyModel.mapId
		EventDispatcher.dispatchEvent(EventType.ENTER_QUIT_COMMON_COPY, eventParam)
	end
end


-- 创建剧情表现层
function createDramaWordView(self, dramaModel, showType)
	local dramaView = DramaWordView.new(dramaModel, showType)
	dramaView:setPosition(VisibleRect:center())
	GameView.tipLayer:addChild(dramaView, 999)
end


--------------------------------------
-- 剧情副本
--------------------------------------

-- 进入剧情副本
function dramaCopyStartHandler(self, param)
	local mapId = param.newValue
	Log.info("地图ID==============" .. mapId or "没有")
	
	local dramaModel = DramaDataCenter.getDramaCopyByMapId(mapId)
	if dramaModel then
		local dramaCopyView = DramaCopyView.new(dramaModel)
		dramaCopyView:setPosition(VisibleRect:center())
		GameView.tipLayer:addChild(dramaCopyView)
	end
end


-- 剧情文字表现结束
function dramaWordEndHandler(self, param)
	local slideId = param.newValue
	if slideId then
		Log.info("剧情文字表现结束" .. slideId)
--		if slideId == 0 then
	--		TipMessage.show("剧情文字变现结束")
			-- 播放过场动画
			local slideModel = DramaDataCenter.getDramaSlideById(slideId)
			if slideModel then
				local slideView = DramaSlideView.new(slideModel)
				slideView:setPosition(VisibleRect:center())
				GameView.tipLayer:addChild(slideView)
				
			end
--		end
	end
end

-- 过场动画结束
function dramaSlideEndHandler(self, param)
	local id = param.newValue
	if not id then
		Log.info("id == nil ")
		return
	end
	Log.info("过场动画结束，在DramaController中, id == " .. id)
	
	if id == 0 then
	-- 开场剧情副本
		local dramaModel = DramaDataCenter.getDramaCopyByMapId(DramaDataCenter.firstSceneId)
		if dramaModel then
			local dramaCopyView = DramaCopyView.new(dramaModel)
			dramaCopyView:setPosition(VisibleRect:center())
			GameView.tipLayer:addChild(dramaCopyView)
			
--			EventDispatcher.removeEventListener(EventType.DRAMA_SLIDE_END, dramaSlideEndHandler, self)
		end
	end
end


return DramaController