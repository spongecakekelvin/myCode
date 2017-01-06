------------------------------------------------------
--作者:	YuZhenJian
--日期:	2013年12月30日
--描述:	剧情副本界面
------------------------------------------------------
DramaCopyView = CCclass("DramaCopyView", BaseLayer)

require "DramaCopyManager"
require "DramaCopyHelper"

local firstSceneId = DramaDataCenter.firstSceneId

local forwardExecution
local stateCheck
local afterwardExecution

local sharedScheduler = CCDirector:sharedDirector():getScheduler()
local scheduleId

function DramaCopyView:onTouchBegan(x, y)
	
	if self.dramaOn or self.blackHole then
		return true
	else
		if self.manager.finger and not self.skillFinger then
    		self.manager:setGuidance(false)
    	end
	end
	return false
end


function DramaCopyView:init(dramaCopyModel, mapId)
	BaseLayer.init(self)
	
	self.model = dramaCopyModel.actionSequence
	self.mapId = dramaCopyModel.mapId

	self.dramaOn = true
	
	self.manager = DramaCopyManager.new(self.model, mapId)
	self.manager:start(self)
	
	self.condIndexTable = {}
	
	self.skillBtns = {}
	
	self.manager.finger = false
	
	self.skillFingerPos = ccp(VisibleRect:rightBottom().x - 113, VisibleRect:rightBottom().y + 121)
	
	self.skillDuration = nil
end

function forwardExecution(self, delay)
	
	local action = CCSequence:createWithTwoActions(
		CCDelayTime:create(delay or 0),
		CCCallFunc:create(function()
			DramaCopyHelper.currentStep = DramaCopyHelper.currentStep + 1
			local dramaAction = self.model[DramaCopyHelper.currentStep]
			if dramaAction then
				if dramaAction[1] == 11 then
					-- 剧情开始
					for index, v in pairs(dramaAction[2]) do
						self.condIndexTable[index] = v
					end
					local valueTable = dramaAction[3]
					local valueIndex = 1
					for _, condInx in pairs(self.condIndexTable) do
						DramaCopyHelper.dramaOnValue[condInx] = valueTable[valueIndex]
						valueIndex  = valueIndex + 1
					end
					-- 剧情状态检测
					self.stateChecking = true
					scheduleId = sharedScheduler:scheduleScriptFunc(function() stateCheck(self, 0.01) end, 0.01, false)
					
				elseif dramaAction[1] == 13 then
					-- 延时
					forwardExecution(self, dramaAction[2])		
				else
					-- 剧情动作
					self.manager:runDramaIndexed(DramaCopyHelper.currentStep)
					forwardExecution(self)
				end
			else
				Log.info("剧情的先行步骤出现nil的错误,剧情不能继续")
			end
		end)
	)
	
	self:runAction(action)
end

local halfSec = 0

function stateCheck(self, dt)
	-- 
	if halfSec == 25 then
		
		local logStr = "触发条件"
		for _, condInx in pairs(self.condIndexTable) do
			logStr = logStr .. "(" .. condInx .. ")" .. DramaCopyHelper.condiction[condInx] .. "/" .. DramaCopyHelper.dramaOnValue[condInx] .. ",  " 
		end
		Log.info(logStr)
		
		local str = ""
		for i, cond in ipairs(DramaCopyHelper.condiction) do
			str = str ..i .."(" .. cond .. "),"
		end
		Log.info("所有条件：" .. str)
		
		halfSec = 0
	end
	
	DramaCopyHelper.condiction[2] = DramaCopyHelper.condiction[2] + dt
	
	if myRole then
		DramaCopyHelper.condiction[5] = myRole.model.tileX
		DramaCopyHelper.condiction[6] = myRole.model.tileY
	end
	
	halfSec = halfSec + 1
	
--	if self.mapId == 10003 then
--		if not self.clickOnce and DramaCopyHelper.condiction[2] > 0.4 and not self.fingerOnce then
--			self.fingerOnce = true
--			self.manager:setGuidance(true, ccp(600, 320), "点击地面移动人物")
--		end
--	end
	
	-- 达到触发条件，剧情开始
	if self.stateChecking then
--		Log.info("---->>>>>>> STATE CHECKING....")
		for _, condIndx in pairs(self.condIndexTable) do
			if condIndx == 1 or condIndx == 6 then
				if DramaCopyHelper.condiction[condIndx] <= DramaCopyHelper.dramaOnValue[condIndx] then
					self.stateChecking = false
					afterwardExecution(self)
					break
				end
			elseif DramaCopyHelper.condiction[condIndx] >= DramaCopyHelper.dramaOnValue[condIndx] then
--			if DramaCopyHelper.condiction[condIndx] > DramaCopyHelper.dramaOnValue[condIndx] then
				self.stateChecking = false
				afterwardExecution(self)
				break
			end
		end
	end
end


function afterwardExecution(self)
	
	self.manager:setGuidance(false)
	
	
	self:stopAllActions()
--	myRole:stopAllActions()
--	SceneDataCenter.setLockElement(myRole)
	myRole:stopMove()
	myRole:stopWatch()
--	myRole:closeAutoFight()
	myRole.model.isCanFighting = false
	myRole:stopAttack()
	
	SceneDataCenter.setLockElement(false)
--	myRole:stopActionByTag(nextFightTag)
	
	self.manager:runNextDrama()
	
--	sharedScheduler:unscheduleScriptEntry(scheduleId)
end



function DramaCopyView:onEnter()
	BaseLayer.onEnter(self)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("images/drama/drama.plist")

	
	Log.info("DramaCopyView on ENTER!!")

	self.bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 0))
	self:addChild(self.bgLayer)
	self.dramaOn = false
	
	if self.mapId == firstSceneId then
		addPlistQ("images/mainUI/mainUI.plist")
		
--		self:addStateLayer(function()
--    		-- 初始执行
--    		forwardExecution(self, 0)
--    	end)
--	else
	end
		-- 初始执行
		forwardExecution(self, 0)
--	end
	
	
	self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.5, 0.5))
	
		
	
	
	-- 退出剧情
	local closeButton = CTButton.new("", 255)
	closeButton:setCallback(self, function()
			
			self:stopAllActions()
			if myRole then
				myRole:stopAllActions()
--					myRole:stopMove()
--				--	myRole:closeAutoFight()
				myRole.model.isCanFighting = false
--					myRole:stopAttack()
			end
			
			DramaCopyHelper.initAllStates()
			
			self.manager:setGuidance(false)
			
			if scheduleId then
				sharedScheduler:unscheduleScriptEntry(scheduleId)
				scheduleId = nil
			end
			
			self.manager:completeDramaCopyHandler()
			
		end)
	closeButton:setPosition(ccpAdd(VisibleRect:rightTop(), ccp(-40, -42)))
	self:addChild(closeButton, 1)
	
	if closeButton.buttonImg then
    	local spr = CCSprite:create("images/jumpExit.png")
    	spr:setPosition(ccp(closeButton.buttonImg:getPosition()))
    	closeButton:addChild(spr)
	end
end


local maxCount = 2 
local imgPathTable = {
	[1] = "drama/1.png",
	[2] = "drama/2.png",
}
local hintTable = {
	[1] = "点击地面，将会移动到此方向",
	[2] = "人物移动时，会自动攻击附近的敌人",
}
function DramaCopyView:addStateLayer(callback)
	local clickCount = 1
	local msgView
	local stateImg
	local hintLabel
	local pageLabel
	local function onMsgButtonClickedHandler(tSelf, button)
		local tag = button:getTag()
		if tag == 3 then
			local nowCount = clickCount + 1
			
			if nowCount > maxCount then
				tSelf:removeFromParentAndCleanup(true)
				if callback then
					callback()
				end
			else
				if clickCount == maxCount - 1 then
					if not tolua.isnull(msgView.buttons[3]) then
    					msgView.buttons[3]:setLabel("关闭")
    				end
				end
				-- 切换图片
				stateImg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgPathTable[nowCount]))
				hintLabel:setString(hintTable[nowCount])
				pageLabel:setString(nowCount .. "/".. maxCount)
			end
			
			clickCount = nowCount
		end
	end
	
	msgView = MessageBoxView.new(nil, "", {nil, nil, "继续"}, onMsgButtonClickedHandler, true)
	self:addChild(msgView, 2)
	
	local w, h = msgView.size.width * 0.5, msgView.size.height
	stateImg = CCSprite:createWithSpriteFrameName(imgPathTable[clickCount])
	stateImg:setPosition(w, h - 200)
	msgView:addChild(stateImg)
	
	hintLabel = ComponentFactory.createLabel(hintTable[clickCount], 23)
	hintLabel:setColor(ccc3(0, 0, 0))
	hintLabel:setPosition(w, h - 65)
	msgView:addChild(hintLabel)
	
	pageLabel = ComponentFactory.createLabel(clickCount .. "/" .. maxCount, 19)
	pageLabel:setColor(UIColor.coffee)
	pageLabel:setPosition(w, 60)
	msgView:addChild(pageLabel)
	
	msgView.backGround:setScale(1.1)
end


local rotGap = 120
local onClickedFastButton
-- 初始化技能快捷键按钮
function DramaCopyView:initFastButtons()
	if tolua.isnull(self.apLayer) then
		
		local layerPos = ccp(VisibleRect:rightBottom().x - 45, VisibleRect:rightBottom().y + 55)
		local apLayer = CCLayer:create()
		apLayer:setContentSize(CCSizeMake(1, 1))
		apLayer:setPosition(layerPos)
		self:addChild(apLayer)
		self.apLayer = apLayer
		
	    --初始化技能快捷键按钮
	    local btnCount = 3
	    local startRot = 135
	    local radius = 100
		
		local ox, oy = 0, 0 --VisibleRect:rightBottom().x - 45, VisibleRect:rightBottom().y + 55
	    for i = 1, btnCount do
	        local skillBtn = CTButton.new("", 255)
	        skillBtn:setSize(50, 50)--为了碰撞区域小一些
	        skillBtn:setCallback(self, onClickedFastButton)
	        skillBtn.id = false
	        skillBtn.clickCount = false
	        skillBtn.canClick = false
	        skillBtn.index = i
	        local dirPos = ccpMult(ccpForAngle(math.rad(startRot + (i - 1) * rotGap)), radius)
	        skillBtn:setPosition(dirPos)
--	        skillBtn.pos = ccpAdd(layerPos, dirPos)
	        self.apLayer:addChild(skillBtn)
			
	        addPosToQ(newSprQ("#mainUI/sankongjianBJ.png"), skillBtn)
	        self.skillBtns[i] = skillBtn
	    end
	else
		runActionsQ(self.apLayer, {
			CCRotateBy:create(0.5, rotGap),
		})
--		CCEaseBackOut:create(CCRotateBy:create(1, rotGap))
	end
end

local skillReleaseTable = {
	[1] = {6,{1,nil,1,0.5}, "冰封地狱", 1.5},
	[2] = {6,{1,nil,2,0.5},"血煞毒雨",1.3},
	[3] = {6,{1,nil,3,0.5},"魔灵法球",3},
	[4] = {6,{1,nil,4,0.5},"爆炸➹",1.3},
	[5] = {6,{1,nil,5,0.5},"红莲如来",1.5},
	[6] = {6,{1,nil,6,0.5},"火柱", 1.2},
	[7] = {6,{1,nil,7,0.5},"激光", 3},
	[8] = {6,{1,nil,8,0.5},"洗衣机", 3},
}
local cdTable = {[1] = 10, [6] = 7}
--{6,{施法者类型（主角为1，npc4，怪物2） , 施法者ID, 技能ID, 聚气时间},咒语,技能持续时间,{目标的类型ID,...}（0为主角）}
--				ps: 技能ID： 1、冰暴（冰封地狱）2、毒箭 3、法球（持续时间 不能大于怪物消失时间）4、爆炸箭  5、扇形火（红莲如来）,6火柱 7激光，8 洗衣机（X）
local skillImgTag = 95295
function onClickedFastButton(self, btn)
	if btn.canClick and btn.clickCount < 3 and btn.id then
		btn.canClick = false
		btn.clickCount = btn.clickCount + 1
		self.manager:setGuidance(false)
		self.skillFinger = false
		runActionsQ(self, {
			CCCallFunc:create(function()
				self.manager:skillReleaseHandler(skillReleaseTable[btn.id])
				 --冷却时间进度精灵
				if btn.iconPath then
					 --技能图标
				    local icon = btn:getChildByTag(skillImgTag)
				    if not tolua.isnull(icon) then
					    icon = tolua.cast(icon, "CCSprite")
					    icon:setZOrder(2)
					    icon:setOpacity(150)
					    icon:setColor(ccc3(125, 125, 125))--设置为半灰度
					    local coldDownSpr = CCSprite:create(btn.iconPath)
					    local cdProgress = EffectFactory.createProgress(coldDownSpr, cdTable[btn.index] or 10, function()
					        if not tolua.isnull(icon) then
					            icon:setZOrder(1)
					            icon:setOpacity(255)
					            icon:setColor(ccc3(255, 255, 255))--全部设置回来
					        end
					    end, kCCProgressTimerTypeRadial)
						cdProgress:setRotation((btn.index - 1) * -rotGap)
					    cdProgress:setPosition(25, 25)
					    btn:addChild(cdProgress)
					end
				end
			end),
			CCDelayTime:create(skillReleaseTable[btn.id][4] + 0.5),
			CCCallFunc:create(function() 
				self.manager:removeElementHandler({4,true,nil})
				btn.canClick = true
				myRole.model.isPlayingSkillNow = false
			end),
		})
	else
		TipMessage.show("技能冷却中", true)
	end
end


function DramaCopyView:onExit()
	BaseLayer.onExit(self)
	
	DramaCopyHelper.initAllStates()
	
	if scheduleId then
		sharedScheduler:unscheduleScriptEntry(scheduleId)
		scheduleId = nil
	end
	
	reallyRemoveSpriteFramesFromFile("images/drama/drama.plist")

	self.dramaOn = false
	
end