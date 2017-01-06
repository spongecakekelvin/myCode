------------------------------------------------------
--作者:	余振健
--日期:	2013年12月13日
--描述:	剧情文字表现界面
------------------------------------------------------
DramaWordView = CCclass("DramaWordView", BaseLayer)

require "DialogHelper"

local fontSize = 20
local throwFontSize = GameConfig.getAutoSizeFont(35)
local fontName = getDefaultFontName()

-- 震屏
local shakeScene
-- 创建背景(黑或不黑)
local createBlackScene

--------------------------------------
-- 需要调用淡出fadeOut函数
--------------------------------------
	-- 淡入淡出显示
local showDialog
	--- 逐字显示
local showDialogOneByOne
	--- 抛出文字 
local throwDialog
	--- 播放幻灯片
local playSlide
--------------------------------------

-- 淡出
local fadeOut


function DramaWordView:onTouchBegan(x, y)
--	local ret = BaseLayer.onTouchBegan(self, x, y)
	if not self.clickedOnce then
		if self.showWord and type(self.showWord) == "function" then 
			self.showWord(false)
			self.clickedOnce = true
		end
	end
	return true
end

---new的时候会调用这个方法
function DramaWordView:init(model, showType)
	BaseLayer.init(self)
	
	self.model = model
--调试用	
	if showType then
		self.model.showType = showType	
	end

	self.clickedOnce = false
	
	-- 对话索引
	self.index = 1
	
	self.priority = -2
end


---addChild()的时候会调用这个方法
function DramaWordView:onEnter()
    BaseLayer.onEnter(self)
    
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.5, 0.5))
    
	local contentSize = self:getContentSize()
	self.pos = ccp(contentSize.width * 0.5, contentSize.height * 0.5)
	

	local actArray = CCArray:create()
    -- 震屏
	if self.model.isShake then
		actArray:addObject(shakeScene())
	end
	-- 黑屏
	actArray:addObject(createBlackScene(self))
	
	self:runAction(CCSequence:create(actArray))

end



--震屏
function shakeScene(target, shakeCount, perTime, range)
	return CCCallFunc:create(
		function()	
			target = target or GameView.sceneLayer 
			local originPos = ccp(target:getPosition()) or ccp(0, 0)
			-- 默认值
			local shakeCount = shakeCount or 10
			local perTime = perTime or 0.05
			local range = range or 5
			-- 
			local duration = shakeCount * perTime
			local min, max = duration * 9000, duration * 15000
			local time, count = 0, 0			
			local array = CCArray:create()
			while true do
				local dura = math.random(9, 13) * 0.1 * perTime
				local posX = math.random(-range, range)
				local posY = math.random(-range, range)
				local moveBy = CCMoveBy:create(dura, ccp(posX, posY))
				array:addObject(moveBy)
				time = dura + time
				count = count + 1
				if time > duration or count >shakeCount then 
					break
				end
			end
			array:addObject(CCMoveTo:create(perTime, originPos))
			target:runAction(CCSequence:create(array))
		end
	)
end


--黑屏
function createBlackScene(self)
	return CCCallFunc:create(
		function()
			if self.model.isBlack then 
				self.bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
			else
				self.bgLayer = CCLayer:create()
			end
			self.bgLayer:setAnchorPoint(ccp(0, 0))
		    self:addChild(self.bgLayer)
		    
			local actArray = CCArray:create()
			
			-- 显示对话
			if self.model.showType == 1 then
				local showAction
				-- 和背景同时淡入
				if self.model.fadeIn and self.model.fadeIn ~= 0 then
					showAction = CCSpawn:createWithTwoActions(CCFadeIn:create(self.model.fadeIn), showDialog(self))
				else
					showAction = showDialog(self)
				end
				
				actArray:addObject(showAction)
				
			else
				-- 背景最先淡入
				if self.model.fadeIn and self.model.fadeIn ~= 0 then
					actArray:addObject(CCFadeIn:create(self.model.fadeIn))
				end
				-- 提交任务
				if self.model.showType == 2 then
					actArray:addObject(throwDialog(self))
				elseif self.model.showType == 0 then
					actArray:addObject(showDialogOneByOne(self))
				else
					actArray:addObject(CCCallFunc:create(function()
							fadeOut(self)
						end))
				end
			end
			
			local action = CCSequence:create(actArray)
			self.bgLayer:runAction(action)
			
		end
	)
end

--------------------------------------
-- 全部显示对话
--------------------------------------
function showDialog(self)
	local dialogAction = CCCallFunc:create(function()
			if not tolua.isnull(self.wordLabel) then
				self.wordLabel:removeFromParentAndCleanup(true)
			end
			
			self.wordLabel = CCLabelTTF:create(self.model.dialog[self.index], fontName, throwFontSize)
			self.wordLabel:setPosition(self.pos)
			
--			if self.model.fadeIn and self.model.fadeIn ~= 0 then
				self.wordLabel:runAction(CCFadeIn:create(self.model.fadeIn))
--			end
			
			self.bgLayer:addChild(self.wordLabel)
		end)
		
	local array = CCArray:create()
	array:addObject(dialogAction)
	
	local delay = self.model.duration --string.len(self.model.dialog[self.index]) * self.model.dialogSpeed + 
	array:addObject(CCDelayTime:create(delay))
	
	
	array:addObject(CCCallFunc:create(function()
				fadeOut(self)
			end))
	
	return CCSequence:create(array)
end


--------------------------------------
-- 逐字显示对话
--------------------------------------
function showDialogOneByOne(self)
	local dialogAction = CCCallFunc:create(function()
			
			if tolua.isnull(self.wordLabel) then
				self.wordLabel = CCLabelTTF:create("", fontName, throwFontSize)
				self.wordLabel:setPosition(self.pos)
				self:addChild(self.wordLabel)
			end
			--逐字显示
			self.showWord = showWordOneByOne(
				self.wordLabel, 
				self.model.dialog[self.index], 
				self.model.dialogSpeed, 
				function()
					if not tolua.isnull(self.wordLabel) then
--						self.wordLabel:removeFromParentAndCleanup(true)
					end
					fadeOut(self)
				end
			)
			self.showWord(true)
		end)
	
	local array = CCArray:create()
	array:addObject(dialogAction)
	
	local delay = string.len(self.model.dialog[self.index]) * self.model.dialogSpeed * 2 + self.model.duration
	array:addObject(CCDelayTime:create(delay))
	
	return CCSpawn:create(array)
end

--------------------------------------
-- 扔出对话框
--------------------------------------
function throwDialog(self)
	local throwShow = CCCallFunc:create(function()
			if not tolua.isnull(self.wordLabel) then
				self.wordLabel:removeFromParentAndCleanup(true)
			end
			
			self.wordLabel = CCLabelTTF:create(self.model.dialog[self.index], fontName, throwFontSize)
			self.wordLabel:setPosition(self.pos)
			
			self.index = self.index + 1
			
			self.wordLabel = CCSprite:createWithTexture(self.wordLabel:getTexture())
			self.wordLabel:setScale(6.0)
			self.wordLabel:setPosition(self.pos)
			self.wordLabel:setVisible(false)
				
			-- 扔出
			local actionThrow = CCSpawn:createWithTwoActions(
					CCScaleTo:create(self.model.dialogSpeed, 1),
					shakeScene(self.wordLabel, 10, self.model.dialogSpeed * 0.1, 1))
			-- 缓动
			local actitonEase = CCSpawn:createWithTwoActions(
					CCEaseOut:create(CCScaleTo:create(self.model.duration, 1.05), 1.01),
					CCDelayTime:create(self.model.duration)
				)
			
			local actionArr = CCArray:create()
			actionArr:addObject(CCDelayTime:create(0.5))
			actionArr:addObject(CCCallFunc:create(function()
					self.wordLabel:setVisible(true)
				end))
			actionArr:addObject(actionThrow)
			actionArr:addObject(actitonEase)
			actionArr:addObject(CCCallFunc:create(function()
				fadeOut(self)
			end))
			local action = CCSequence:create(actionArr)
			
			self.wordLabel:runAction(action)
			self:addChild(self.wordLabel)
			
		end)
	
	return throwShow
end


--淡出
function fadeOut(self)
	if tolua.isnull(self.wordLabel) then
		local throwFontSize = throwFontSize
		if fontScale == 5.6 then
			throwFontSize = 35
		end
	end
	 
--	EffectFactory.showRectangleEffect(self.wordLabel, self.wordLabel:getContentSize())
	
	--------------------------------------
	-- 停止当前动作, 进行下一动作
	--------------------------------------
	
	self.bgLayer:stopAllActions()
	
	local actArray = CCArray:create()
		
		
	local spawnArr = CCArray:create()
-- 文字淡出
	if self.wordLabel then
		local labelFadeOut = CCCallFunc:create(function()
				self.wordLabel:runAction(CCFadeOut:create(self.model.fadeOut))
			end)
		spawnArr:addObject(labelFadeOut)
	end
-- 背景淡出	
	local layerFadeOut = CCCallFunc:create(function()
			self.bgLayer:runAction(CCFadeOut:create(self.model.fadeOut))
		end)
		
--	if self.model.id == 0 then
--		-- 进入第一个剧情副本
--		actArray:addObject(CCCallFunc:create(function()
--			local eventParam = EventParam.create()
--			eventParam.isGlobal			= true
--			eventParam.newValue			= 10001
--			EventDispatcher.dispatchEvent(EventType.ENTER_QUIT_COMMON_COPY, eventParam)
--		end))
--		actArray:addObject(CCDelayTime:create(0.7))
--	end
	spawnArr:addObject(layerFadeOut)
	spawnArr:addObject(CCDelayTime:create(self.model.fadeOut))

	actArray:addObject(CCSpawn:create(spawnArr))
--	if self.model.id == 0 then
--		actArray:addObject(CCCallFunc:create(function()
--				local eventParam = EventParam.create()
--				eventParam.isGlobal = true
--				eventParam.newValue = 0
--				EventDispatcher.dispatchEvent(EventType.DRAMA_WORD_END, eventParam)
--				
--  			  	Log.info("DRAMA_WORD_END.剧情副本.....")
--				playSlide(self)
--			end))
--	end
	
-- 关闭面板
	
	actArray:addObject(CCCallFunc:create(function()
		self:removeFromParentAndCleanup(true)
	end))
	
	if self.model.id == 0 then
		actArray:addObject(CCCallFunc:create(function()
			local dramaModel = DramaDataCenter.getDramaCopyByMapId(10003)
			if dramaModel then
				local dramaCopyView = DramaCopyView.new(dramaModel)
				dramaCopyView:setPosition(VisibleRect:center())
				GameView.tipLayer:addChild(dramaCopyView)
			end
		end))
	end

	local action = CCSequence:create(actArray)	
	
	self.bgLayer:runAction(action)
end

-- 播放幻灯片
function playSlide(self)


end


function DramaWordView:onExit()
	BaseLayer.onExit(self)
end