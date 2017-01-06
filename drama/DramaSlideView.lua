------------------------------------------------------
--作者:	YuZhenJian
--日期:	2014年1月22日
--描述:	剧情动画 (Drama Slide)
------------------------------------------------------
DramaSlideView = CCclass("DramaSlideView", BaseLayer)

require "DramaActionFactory"



-- 测试用
--local dontShow = true



local leftBottom =  VisibleRect:leftBottom()

local contentSize = CCSizeMake(960, 640)
local scheduleId
local sharedScheduler = CCDirector:sharedDirector():getScheduler()


local startPlaying

local fadeAction

-- 计时
local tickTock = 0
-- 动作持续时间
local actionDuration

local clickable = false

local spriteTable = {}
local spriteIndex = 1

function DramaSlideView:init(slideModel)
	BaseLayer.init(self)
	self.priority = -2
	
--	printTable(slideModel)
	self.id = slideModel.id
	self.slideInfo = slideModel.slideInfo or {}
	
--	printTable(self.slideInfo)
	--播放进度
	self.progress = 0
	self.maxProgress = slideModel.maxProgress
	self.contentType = slideModel.contentType
	actionDuration = slideModel.actionDuration
	
	if self.contentType == 1 then
	-- 文字
		self.playNext = self.playNextWord
	else
	-- 动画
		self.playNext = self.playNextSlide
	end
	
	self.lastStyle = 1
	self.nextStyle = 1
	
	
	-- 点击跳到下一步
	self.clicked = false

	-- 2s播一帧
	self.playingGap = slideModel.playingGap
		--可以手动
		self.autoPlaying = true
	
	-- 手动后4s转回自动
	self.autoGap = 0
		--可以转自动
		self.autoAuto = false
		
	tickTock = self.playingGap
	
	self.endPlaying = false
	
	clickable = false
	
	spriteTable = {}
	spriteIndex = 1
	
end


function DramaSlideView:onTouchBegan(x, y)
	self.clicked = true
--	self.autoPlaying = false
--	self.autoBtn:runAction(CCMoveTo:create(1, ccp(x, y)))
	return true
end 

function DramaSlideView:onTouchEnded(x, y)
	if self.clicked then
		self.clicked = false
		
		if clickable then 
			clickable = false
			
			tickTock = 0
			self:playNext(self.lastStyle, self.nextStyle)
			
			if self.autoPlaying then
--				self.autoPlaying = false
			end
		end
	end
end


function DramaSlideView:onEnter()
	BaseLayer.onEnter(self)
	Log.info("DramaSlideView on ENTER!!")
	
	scheduleId = sharedScheduler:scheduleScriptFunc(function() startPlaying(self, 0.01) end, 0.001, false)
	
	self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.5, 0.5))
	
	if self.contentType == 1 then
	-- 文字 黑底
		self.bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
--		self.bgLayer = CCLayer:create() 
	else
	-- 动画 白底
		self.bgLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
	--	self.bgLayer = CCLayer:create()
		
		local closeButton = CTButton.new("", 5)
		closeButton.priority = -2
		
		self.clickedOnce = false
		closeButton:setCallback(self, function()
				if self.clickedOnce then
					return
				end
				self.clickedOnce = true
				if scheduleId then
					sharedScheduler:unscheduleScriptEntry(scheduleId)
					scheduleId = nil
				end
				
				for i, spr in pairs(spriteTable) do
					if not tolua.isnull(spr) then
						spr:runAction(fadeAction(spr, false, 1))
					end
				end
--				printTable(spriteTable)
				self.bgLayer:runAction(fadeAction(self, false, 2))
				self:runAction(fadeAction(self, false, 2))
				self:runAction(CCSequence:createWithTwoActions(
					CCDelayTime:create(1),
					CCCallFunc:create(function()
						TipMessage.show("欢迎来到口袋武动苍穹2Online")
					end)
					))
--				self:removeFromParentAndCleanup(true)
			end)
		local closePos = ccpAdd(VisibleRect:leftBottom(), ccp(40, 40))
		closeButton:setPosition(closePos)
		self:addChild(closeButton, 20)
	end
	
	self:addChild(self.bgLayer)
	
	
	local scale = 640 / VisibleRect:getVisibleRect().size.height
	self.bgLayer:setScaleX(scale)
	

	local array = CCArray:create()
--	self:setScale(0.0)
--	array:addObject(CCScaleTo:create(1, 1.0))
	array:addObject(CCDelayTime:create(0.2))

	-- 测试代码
	if dontShow then
	
		array:addObject(CCCallFunc:create(function()
			EffectFactory.shakeScreen()
			local emitter = createAnimation("flyMagicSkill/blackHurt/%05d.png", 7, 0.5, true, 0, true)
			local pos = ccp(200, 200)
			emitter:setPosition(pos)
			self:addChild(emitter)
			
			local emitter = CCParticleSystemQuad:create("particles/bloodShed.plist")
			emitter:setDuration(-1)
			emitter:setZOrder(255)
		--	emitter:setPositionType(kCCPositionTypeRelative)
			emitter:setPosition(200, 400)
			self:addChild(emitter)
			
			local label  = ComponentFactory.createLabel("KelvinDesus", 35)
			label:setPosition(480, 530)
			LabelFactory.shineLabel(label, ccc3(0, 0, 0))
			self:addChild(label)
			
			local label  = ComponentFactory.createLabel("KelvinDesus", 35)
			label:setPosition(280, 530)
			self:addChild(label)
		end))
		
		self.autoBtn = CTButton.new("自动自动/", 1)
		self.autoBtn:setCallback(self, function()
				tickTock = 0
				if self.autoPlaying then
					self.autoPlaying = false
					TipMessage.show("手动自动")
				else
					self.autoPlaying = true
					TipMessage.show("自动自动")
				end
				
			end)
		self.autoBtn:setPosition(160, 42)
		self:addChild(self.autoBtn)
		
		self.autoBtn2 = CTButton.new("自动自动/手动自动", 1)
		self.autoBtn2:setCallback(self, function()
				tickTock = 0
				if self.autoAuto then
					self.autoAuto = false
					TipMessage.show("手动自动")
				else
					self.autoAuto = true
					TipMessage.show("自动自动")
				end
			end)
		self.autoBtn2:setPosition(310, 42)
		self:addChild(self.autoBtn2)
	end
	
	
	local action = CCSequence:create(array)
	self:runAction(action)
	
end

local timeCount = 0
function startPlaying(self, dt)
	
	timeCount = timeCount + dt
	
	tickTock = tickTock + dt
	--
	if timeCount > 0.5 then
		timeCount = 0
		Log.info(tickTock .. "       " .. (self.autoPlaying and "(true)" or "(false)") .. "         " .. self.playingGap)
		
		Log.info("progress: " .. self.progress .. ", maxProgress: " .. self.maxProgress )
	end
	
	if self.autoPlaying then
		-- 两秒播放一次
		if tickTock >= self.playingGap then
			tickTock = 0
			self:playNext(self.lastStyle, self.nextStyle)
		end
	elseif self.autoAuto then
		--	四秒转回自动
		if tickTock >= self.autoGap then
			tickTock = 0
			self.autoPlaying = true
		end
	end
end


local function scaleAction(target, switch, dt)
	if switch then
		target:setScale(0.0)
		return CCSequence:createWithTwoActions(
			CCScaleTo:create(dt, 1.0),
			CCCallFunc:create(function()
				clickable = true
			end))
	else
		target:setScale(1.0)
		return CCSequence:createWithTwoActions(
			CCScaleTo:create(dt, 0.0),
			CCCallFunc:create(function()
				target:removeFromParentAndCleanup(true)
			end))
	end
end

--style 1 重影 2 渐变
function fadeAction(target, switch, dt, style)
	if switch then
		return CCSequence:createWithTwoActions(
			CCFadeIn:create(dt),
			CCCallFunc:create(function()
				clickable = true
			end))
	else
		clickable = false
		
		local action
		
		if style == 1 then
			action = CCSpawn:createWithTwoActions(
	        	CCCallFunc:create(function()
        			EffectFactory.shakyGhosts(target, dt * 0.5, 10, nil)
	        	end),
		        CCDelayTime:create(dt))
		else
			action = CCSequence:createWithTwoActions(
	       		CCFadeOut:create(dt),
	        	CCCallFunc:create(function()
					target:removeFromParentAndCleanup(true)
				end))
		end
		
		return action
	end
end	


local function createStyledAction(style)

end

function DramaSlideView:playNextSlide()
	self.progress =(self.progress + 1)
	
	if self.progress > self.maxProgress then
		self:endPlayingSlide()
		return
	end
	
--	[1] = {inStyle = 1, inTime = 1, keepStyle = 2, keepTime = 1, outStyle = 1, outTime = 1,
--		inPos = ccp(480, 320), outPos = ccp(480, 320), playingGap = 3,
	local actionInfo = self.slideInfo[self.progress]

	if actionInfo then
--		printTable(actionInfo)
		-- 播放下一帧的间隔
		local duration = actionInfo.duration or 0
		self.playingGap = duration
		
		if actionInfo.noSlide then
			local inStyle = actionInfo.inStyle
			local inTime = actionInfo.inTime or 0.01
			local inPos = actionInfo.inPos
			local inFactor = actionInfo.inFactor 
			
			if inStyle == 1 then
			-- 变黑
--				self.bgLayer:setColor(ccc3(0, 0, 0))
--				self.bgLayer:setOpacity(255)
				self.bgLayer:runAction(CCTintTo:create(inTime, 0, 0, 0))
--				self.bgLayer:runAction(CCFadeOut:create(inTime))
			elseif inStyle == 2 then
--				self.bgLayer:runAction(CCFadeIn:create(inTime))
				self.bgLayer:runAction(CCTintTo:create(inTime, 255, 255, 255))
			elseif inStyle == 3 then
				self.bgLayer:runAction(CCFadeOut:create(inTime))
			elseif inStyle == 4 then
				TipMessage.show("欢迎来到口袋武动苍穹2Online") 
			elseif inStyle == 5 then
				local array = CCArray:create()
				local scaleFadeOut = DramaActionFactory.createAction(86, inTime, nil, nil, inFactor)
				local spawnAction = CCSpawn:createWithTwoActions(
						scaleFadeOut,
						CCMoveTo:create(inTime, inPos)
					)
				array:addObject(scaleFadeOut)
				array:addObject(CCDelayTime:create(1))
				array:addObject(CCCallFunc:create(function()
--					self:setOpacity(255)
					self:setScale(1)
					self:setPosition(ccp(480, 320))
				end))
				
				self:runAction(CCSequence:create(array))
--				self.bgLayer:runAction(CCScaleTo:create(inTime, inFactor))
			elseif inStyle == 6 then
				DramaActionFactory.Thunder(self, inPos, inTime, inFactor)
			end
		else
			
			-- 动作类型和时间
			local inStyle = actionInfo.inStyle
			local inTime = actionInfo.inTime
			local midStyle = actionInfo.midStyle
			local midTime = actionInfo.midTime
			local outStyle = actionInfo.outStyle
			local outTime = actionInfo.outTime
			
			-- 坐标向量
	--		local inPos = ccpAdd(leftBottom, actionInfo.inPos)
			local inPos = actionInfo.inPos
			local midPos = actionInfo.midPos
			local outPos = actionInfo.outPos
			
			local inFactor = actionInfo.inFactor
			local midFactor = actionInfo.midFactor
			local outFactor = actionInfo.outFactor
			
			local inFactor2 = actionInfo.inFactor2
			local midFactor2 = actionInfo.midFactor2
			local outFactor2 = actionInfo.outFactor2
			
			local inDelay = actionInfo.inDelay
			local midDelay = actionInfo.midDelay
			local outDelay = actionInfo.outDelay
			
			-- 额外的属性
			local opacity = actionInfo.opacity
			local zOrder = actionInfo.zOrder
			local scale = actionInfo.scale
			local scaleX = actionInfo.scaleX
			local scaleY = actionInfo.scaleY
			local extraDelay = actionInfo.extraDelay
			local tag = actionInfo.tag
			local parentTag = actionInfo.parentTag
			local gray = actionInfo.gray
			
			local tableLen = #actionInfo
			for i = 1, tableLen, 2 do
				
				local picPath = "images/drama/" .. actionInfo[i]  --.. ".png"
				local initPos = actionInfo[i + 1]
				-- 动作起始位置
				local fromPos = initPos
				
				local newSprite 
				if gray then 
					newSprite = CTGraySprite:create(picPath)
				else
					newSprite = CCSprite:create(picPath)
				end
				newSprite:setPosition(initPos)
				spriteTable[spriteIndex] = newSprite
				
				
				if opacity then
					newSprite:setOpacity(opacity)
				end
				
				if zOrder then
					newSprite:setZOrder(zOrder)
				end
				
				-- 缩放
				if scale then
					newSprite:setScale(scale)
				else
					if scaleX then
						newSprite:setScaleX(scaleX)
					end
					
					if scaleY then
						newSprite:setScaleY(scaleY)
					end
				end
				
				-- 有标记
				if tag then
					newSprite:setTag(tag)
				end
				
				-- 有父标记（需要加到父图片上）
				local parent = nil
				if parentTag then
					parent = self:getChildByTag(parentTag)
				end
				if parent then
					Log.info("ParentTag:" .. parentTag .. "-----init Pos:(" .. initPos.x .. "," .. initPos.y .. ")")
					local pos = parent:convertToNodeSpace(initPos)
					Log.info("--------parent Pos:(" .. pos.x .. "," .. pos.y .. ")")
					newSprite:setPosition(pos)
					parent:addChild(newSprite, 1000)
				else
					self:addChild(newSprite)
				end
				
				
				local array = CCArray:create()
				
				-- 进入动作
				if inStyle then
					local haveActionSix = ((inStyle % 10) == 6) 
					if haveActionSix then
						newSprite:setOpacity(0)
					end
					local inAction = DramaActionFactory.createAction(inStyle, inTime, fromPos, inPos, inFactor, inFactor2)
					if inAction then
						if inDelay then
							array:addObject(CCDelayTime:create(inDelay))
						end
						array:addObject(inAction)
					end
	
					if inPos then
						fromPos = inPos
					end
				end
				
				-- 中间动作
				if midStyle then
					local midAction = DramaActionFactory.createAction(midStyle, midTime, fromPos, midPos, midFactor, midFactor2)
					if midAction then
						if midDelay then
							array:addObject(CCDelayTime:create(midDelay))
						end
						array:addObject(midAction)
					end
					
					if midPos then
						fromPos = midPos
					end
				end
				
				-- 退出动作
				if outStyle then
					local outAction = DramaActionFactory.createAction(outStyle, outTime, fromPos, outPos, outFactor, outFactor2)
					if outAction then
						if outDelay then
							array:addObject(CCDelayTime:create(outDelay))
						end
						array:addObject(outAction)
					end
				end
				
				if extraDelay then
					array:addObject(CCDelayTime:create(extraDelay))
				end
				
				local index = spriteIndex
				array:addObject(CCCallFunc:create(function()
					if newSprite then
						spriteTable[index] = nil
						newSprite:removeFromParentAndCleanup(true)
					end
				end))
				spriteIndex = spriteIndex + 1	
						
				newSprite:runAction(CCSequence:create(array))
				
			end -- for 多张图片
--			printTable(spriteTable)
		end	-- if not actionInfo.noSlide then
		
	end -- if actionInfo then
	
end

function DramaSlideView:endPlayingSlide()
	Log.info("播放幻灯片完成")
	
	if scheduleId then
		sharedScheduler:unscheduleScriptEntry(scheduleId)
		scheduleId = nil
	end
		
--	local array = CCArray:create()
--	
--	
--	array:addObject(CCCallFunc:create(function()
--
--			if self.id == 2 then
--				-- do nothing
--			end
--			
			self:removeFromParentAndCleanup(true)
--		end))
--	self:runAction(CCSequence:create(array))

--	self.progress = 0
--	tickTock = self.playingGap
-- 	Log.info("最后一张，准备重新播放")
end

function DramaSlideView:playNextWord()
	
	self.progress =(self.progress + 1)
				
	if self.progress > self.maxProgress then
		self:endPlayingWord()
		return
	end
	
	local words = self.slideInfo[self.progress]
--	printTable(self.slideInfo)
	
	Log.info("progress: " .. self.progress .. ", maxProgress: " .. self.maxProgress )
	
	if words then
		
--		TipMessage.show("play next slide !!" )
		local inStyle = words.inStyle
		local inTime = words.inTime
		local outStyle = words.outStyle
		local outTime = words.outTime
		
		local fontSize = words.fontSize or 35
		
		
		local array = CCArray:create()
		
		if self.lastWords then
			local outStyle = self.lastWords.outStyle
			local outTime = self.lastWords.outTime
			
			array:addObject(CCCallFunc:create(function()
				
				for _, word in ipairs(self.wordsTable) do					
					word:runAction(fadeAction(word, false, outTime, outStyle))
				end
			end))
			array:addObject(CCDelayTime:create(outTime))
		end
		
		array:addObject(CCCallFunc:create(function()
				
				local originX, originY, offsetY = contentSize.width * 0.5 , contentSize.height * 0.5 + 110, 60
--				local totalNum = #words
--				originY = originY + (totalNum > 1 and -80 or 0)
				
				local allWordsLabel = CCLayerColor:create(ccc4(0, 0, 0, 255))
				allWordsLabel:setAnchorPoint(ccp(0.5, 0))
				allWordsLabel:setPosition(ccp(0, 0))
				
				
				self.wordsTable  = {}
				
				for _, word in ipairs(words) do
					local wordLabel = ComponentFactory.createLabel(word, fontSize)
					wordLabel:setAnchorPoint(ccp(0.5, 0.5))
					wordLabel:setPosition(ccp(originX, originY))
					wordLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
					originY = originY - offsetY
					
					wordLabel:runAction(fadeAction(wordLabel, true, inTime, inStyle))
					allWordsLabel:addChild(wordLabel)
					self.wordsTable[#self.wordsTable + 1] = wordLabel
				end
				
				self:addChild(allWordsLabel)
				
				if self.lastWords then
					self.lastWords:removeFromParentAndCleanup(true)
				end
				self.lastWords = allWordsLabel
				self.lastWords.outStyle = outStyle
				self.lastWords.outTime = outTime
				
			end))
		array:addObject(CCDelayTime:create(inTime))
		
		local action = CCSequence:create(array)
		self:runAction(action)
	end
	
	
end

function DramaSlideView:endPlayingWord()
	Log.info("播放幻灯片完成")
	
	if scheduleId then
		sharedScheduler:unscheduleScriptEntry(scheduleId)
		scheduleId = nil
	end
		
	local array = CCArray:create()
	
	if self.lastWords then
		local outStyle = self.lastWords.outStyle
		local outTime = self.lastWords.outTime or actionDuration
				
		array:addObject(CCCallFunc:create(function()
				if self.contentType == 1 then
					
					for _, word in ipairs(self.wordsTable) do					
						word:runAction(fadeAction(word, false, outTime, outStyle))
					end
				elseif self.contentType == 2 then
					self.lastSlide:runAction(CCFadeOut:create(outTime))
				end
				self.bgLayer:runAction(CCFadeOut:create(outTime))
			end))
		array:addObject(CCDelayTime:create(outTime))
	end
	
	
	array:addObject(CCCallFunc:create(function()
	
			if self.id == 0 then
			-- 发送事件
				local eventParam = EventParam.create()
				eventParam.isGlobal = true
				eventParam.newValue = self.id
				EventDispatcher.dispatchEvent(EventType.DRAMA_SLIDE_END, eventParam)
			elseif self.id == 1 then	
			-- 清除剧情副本场景
				local eventParam = EventParam.create()
				eventParam.clear = true
				EventDispatcher.dispatchEvent(EventType.SIMULATE_MAP_ENTER_TOC, eventParam)
			else
			-- do nothing
			end
			
			self:removeFromParentAndCleanup(true)
		end))
--	array:addObject(CCCallFunc:create(function()
--			
--		end))
	self:runAction(CCSequence:create(array))
	
--				 	self.progress = 1
--				 	Log.info("最后一张，准备重新播放")
end



function DramaSlideView:onExit()
	BaseLayer.onExit(self)
end
