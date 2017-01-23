
----------------------------------------
-- lihaifei
-- 2014年10月16日
-- 主界面
----------------------------------------


local tClass = class("MainUIView", cls.LayerBase)

require "modules/chat/ChatFactory"

local schedulerEntry
local scheduler = cc.Director:getInstance():getScheduler()

local createRoleHead
local createChatBtn
local createChatBoard
local updateChatBoard
local createScheduler

local createChangeBtn
local updateChangeItemPos
local outChangeItemPos

--local updateBottomBlack

local newItem
local createAllItem

local updatePos
local updateAllPos

local updatePosNoAction
local updateAllPosNoAction

local itemHandel

local updateExpTimer

-- 开始坐标
local startPosTab


local updateMaxPassIdFB
local updatePetBarGuideN
local updatePetJinHuaGuideN
local updatePetHelpGuideN


-- 按钮间隔
local itemGap = {
	cc.p(92, 100),-- 下面
	cc.p(10, 100),-- 左面
	cc.p(92, 100),-- 上面
	cc.p(100, 90),-- 右面
}

-- 计算坐标的函数
local getPosFuncTab = {
    [1] = function(i) return cc.p(startPosTab[1].x - i * itemGap[1].x, startPosTab[1].y) end,
    [2] = function(i) return cc.p(startPosTab[2].x + (i-1) * itemGap[2].x, startPosTab[2].y) end,
    [3] = function(i) return cc.p(startPosTab[3].x - (i-1) * itemGap[3].x, startPosTab[3].y) end,
    [4] = function(i) return cc.p(startPosTab[4].x, startPosTab[4].y + i * itemGap[4].y) end,
}


local changeTime = 0.5


function tClass:ctor(mainUIState)
	tClass.super.ctor(self)
	self:setNodeEvent()
	
	-- 在主城中 true
    gData.MainUIData.mainUIState = true
	if mainUIState ~= nil then
        gData.MainUIData.mainUIState = mainUIState
    end
	
--	local tLayer = ui.newLayer(cc.c4b(0, 255, 0, 200))
--	ui.addPosTo(tLayer, self)
	
	local autoSizes = ui.autoSizes
	startPosTab = {
		-- 下面
		cc.p(autoSizes.x1- 52, autoSizes.y0+60),
		-- 左面
		cc.p(autoSizes.x0 + 54, autoSizes.y0 + 420),
		-- 上面
		cc.p(autoSizes.x1-190, autoSizes.y1-76),
		-- 右面
        cc.p(autoSizes.x1-52, autoSizes.y0+68),
	}
	
	-- 保存所有按钮
    self.itemTab = {} -- tag
    
	-- 根据位置保存按钮
	self.itemPlaceTab = {}
	
	-- 最终需要release的
	self.needRemoveTab_ = {}
	
--    local spr = ui.newSpr("#mainUI/bottomBlack.png")
--    spr:setLocalZOrder(-2)
--    spr:setScaleX(self:getContentSize().width / spr:getContentSize().width)
--    ui.addChildEx(spr, self, 0, ui.autoSizes.y0, cc.p(0, 0))
--    self.bottomBlack = spr
    
	local expBgSpr = ui.newSpr("#mainUI/expBg.png")
    self.expBgSpr = expBgSpr
	ui.addPosTo(expBgSpr, self, cc.p(0.5, 0), cc.p(0, ui.autoSizes.y0))
	
--	local proTimer = ui.newProTimerL({img="#mainUI/exp.png"})
--	ui.addPosTo(proTimer, expBgSpr, cc.p(0.5, 0.5), cc.p(0, 0))
    updateExpTimer(self)
	
--	local expGapSpr = ui.newSpr("#mainUI/expGap.png")
--	ui.addPosTo(expGapSpr, expBgSpr)
	
	local percentLabel = gui.newLabel("", ui.color.white, 16)
	percentLabel:setLocalZOrder(2)
	ui.addPosTo(percentLabel, expBgSpr, cc.p(0.5, 0.5), cc.p(0, 0))
	
--	self.expProTimer = proTimer
	self.expPercentLabel = percentLabel
	
	self.lastExpLevel = gData.RoleData.model.level
	self:update_exp_()
	
	
	self:updateMissionBtn()
    createChangeBtn(self)
	createRoleHead(self)

    self.chatStyle = self.chatStyle or 2
    createChatBoard(self, self.chatStyle)
    createChatBtn(self)
	
    self:createActiveItem()
	
	createAllItem(self)
    updateAllPosNoAction(self)
    
	self:updateBagGuide()
	
	createScheduler(self)
	
	self:update_vip_level_()
	
	self:updateFightAnim(false)
	
	
	self:updateChangeMap()
	
    self:VisUpView(gData.MainUIData.mainUIState)
    
--    local petBarInfo = gData.PetBarData.getPetBarInfo()
--	if petBarInfo and petBarInfo.type1_nextTimes  <= 0 then
--		updatePetBarGuideN(self, true)
--	end
	
end

function tClass:onEnter()
    tClass.super.onEnter(self)
    local playerModel_ = gData.RoleData.model
    playerModel_:removeCb(self)
    playerModel_:addCb(self, {"fightPower", "petFightPower"}, self.update_fightPower_)
    playerModel_:addCb(self, {"level", "vip_level"})
    playerModel_:addCb(self, "updateExp_ui", self.update_exp_)
    playerModel_:addCb(self, "jingjie", self.update_jingjie_)
    
    gEvent:add(EventType.u_open_barrier, self, handler(self, updateMaxPassIdFB))
    gEvent:add(EventType.u_pet_bar_update_guide_n, self, handler(self, updatePetBarGuideN))
    gEvent:add(EventType.u_update_ishave_pet_isCanJinHua, self, handler(self, updatePetJinHuaGuideN))
    
    gEvent:add(EventType.u_update_pet_topButton_guide_n, self, handler(self, updatePetHelpGuideN))
    
    GuideManager.register(self)
end


function tClass:onExit()
    tClass.super.onExit(self)
    local playerModel_ = gData.RoleData.model
    if playerModel_ then
        playerModel_:removeCb(self)
    end
    gEvent:remove(EventType.u_open_barrier, self)
    gEvent:remove(EventType.u_pet_bar_update_guide_n, self)
    gEvent:remove(EventType.u_update_ishave_pet_isCanJinHua, self)
    gEvent:remove(EventType.u_update_pet_topButton_guide_n, self)
    
    if schedulerEntry then
        TimerManager.unscheduleGlobal(schedulerEntry)
        schedulerEntry = nil
    end
    
    for _, v in pairs(self.needRemoveTab_) do
		if nonull(v) and v:getReferenceCount() > 1 then
			v:release()
		end
	end
    GuideManager.unregister(self)
end

function createScheduler(self)
    if schedulerEntry then
        TimerManager.unscheduleGlobal(schedulerEntry)
        schedulerEntry = nil
    end
    
    local loopTime = 0
    local dt = 1
    local function viewLoop()
        loopTime = loopTime + dt
        
        if loopTime > 10000 then
            loopTime = 0
        end
        
        updateChatBoard(self)
    end
    -- 定时器
    -- schedulerEntry = scheduler:scheduleScriptFunc(viewLoop, dt, false) 
    schedulerEntry = TimerManager.scheduleGlobal(viewLoop, dt)    
end

function newItem(self, model)
    local item
    if model.rect then
        item = gui.easyBtn(model.text, nil, handler(self, itemHandel), cc.size(model.rect.w, model.rect.h))
        if model.icon then
            local spr = ui.newSpr(model.icon) 
            ui.addChildEx(spr, item)
        end
    else
        item = ui.newButton({img={model.icon}, text=model.text, callback=handler(self, itemHandel)})
    end
	item.model = model
	
	if model.animName then
	    local tAnim = ui.newAnim(model.animName)
        ui.addPosTo(tAnim, item)
	end
	
	item.updateFunc = gData.MainUIData.getUpdateFunc(model.tag)
	if item.updateFunc then
	   item:updateFunc()
    end
--	ui.roundNode(item, 1, cc.c4f(1,0,0,1))
	return item
end

function tClass:updateItem(ctlName)
    local btn = self.itemTab[ctlName]
    if not tolua.isnull(btn) and btn.updateFunc then
        btn:updateFunc()
    end
end

local function createItemActions(item, pos)
	item:stopAllActions()
--    item:runAction(cc.EaseBackOut:create(cc.MoveTo:create(changeTime, pos)))
    ui.runActions(item, {cc.CallFunc:create(function()
        item:setVisible(true)
    end)
    , cc.EaseBackOut:create(cc.MoveTo:create(changeTime, pos))
        , cc.CallFunc:create(function()
            item:setEnabledNoGray(true)
        end),
    cc.CallFunc:create(function()
            if item.callback then
                item.callback()
                item.callback = nil
            end
        end),
    })
end

local function createItemActionsOut(item, pos)
    item:stopAllActions()
--    item:runAction(cc.EaseBackIn:create(cc.MoveTo:create(changeTime, pos)))
    ui.runActions(item, {cc.CallFunc:create(function()
        item:setEnabledNoGray(false)
    end)
    , cc.EaseBackIn:create(cc.MoveTo:create(changeTime, pos))
        , cc.CallFunc:create(function()
            item:setVisible(false)
        end)})
end


function updatePos(self, place)
    place = place or 1
	local tTab = self.itemPlaceTab[place]
	if not tTab then
		return
	end
	local tPos
    local getPosFunc = getPosFuncTab[place]
    if getPosFunc then
    	for i, v in ipairs(tTab) do
            tPos = getPosFunc(i)
    		createItemActions(v, tPos)
    	end
	end
end

local function outPos(self, place)
    place = place or 1
    local tTab = self.itemPlaceTab[place]
    if not tTab then
        return
    end
    local startPos = startPosTab[place]
    if startPos then
        for i, v in ipairs(tTab) do
            createItemActionsOut(v, startPos)
        end
    end
end

function updateAllPos(self, place)
    if place then
        updatePos(self, place)
    else
        for i = 1, 4 do
            updatePos(self, i)
        end
	end
end

function updatePosNoAction(self, place)
    local itemTab = self.itemPlaceTab[place]
    if itemTab then
        local getPosFunc = getPosFuncTab[place]
        if getPosFunc then
            local tPos
            for i, item in ipairs(itemTab) do
                tPos = getPosFunc(i)
                item:stopAllActions()
                item:setPosition(tPos)
            end
        end
    end
    if place == 1 then
        self:visibleChangeBtn(true)
    end
end

function updateAllPosNoAction(self)
    for place = 1, 4 do
        updatePosNoAction(self, place)
    end
end


function updateChangeItemPos(self)
    updatePos(self, 1)
--    updatePos(self, 4)
end

function outChangeItemPos(self)
    outPos(self, 1)
--    outPos(self, 4)
end


local function createAllPlaceItem(self)
	
	self.itemTab = {}
	self.itemPlaceTab = {}
	local tModels = gData.MainUIData.getModels()
	local item
	local tPos
	for place, v in ipairs(tModels) do
		self.itemPlaceTab[place] = {}
		for index, model in ipairs(v) do
			item = newItem(self, model)
			if model.posTab then
				tPos = cc.pAdd(cc.p(ui.autoSizes[model.posTab.x], ui.autoSizes[model.posTab.y]), model.posTab.ajPos)
			else
				tPos = startPosTab[place]
			end
			ui.addToPos(item, self, tPos)
			self.itemPlaceTab[place][index] = item
			
            if model.tag then
                self.itemTab[model.tag] = item
                item:setGuideTag("MainUIView", model.tag)
            end
		end
	end
	
	gData.MainUIData.setItemTab(self.itemTab)
end


function createAllItem(self)
	createAllPlaceItem(self)
end

local function changeBtnHd(self)
--    gprint("旋转按钮")
    local btn = self.changeBtn
    -- 按钮旋转
    local action
    if not btn.showBtn__ then
        action = cc.EaseBackOut:create(cc.RotateTo:create(changeTime, 0))
    else
        action = cc.EaseBackIn:create(cc.RotateTo:create(changeTime, 135))
    end
    btn:setEnabledNoGray(false)
    ui.runActions(self.changeBtn_x, {action
    , cc.CallFunc:create(function()
        self.changeBtn:setEnabledNoGray(true)
    end)})
    
    btn.showBtn__ = not btn.showBtn__
    
    if btn.showBtn__ then
        updateChangeItemPos(self)
    else
        outChangeItemPos(self)
    end
--    gprint("state = === " .. (btn.showBtn__ and "true" or "false"))
--    updateBottomBlack(self, btn.showBtn__)
    
end

--function updateBottomBlack(self, state)
--    if not tolua.isnull(self.bottomBlack) then
--        self.bottomBlack:stopAllActions()
--        if state then
--            self.bottomBlack:runAction(cc.MoveTo:create(changeTime, cc.p(0, ui.autoSizes.y0)))
--        else
--            self.bottomBlack:runAction(cc.MoveTo:create(changeTime, cc.p(0, ui.autoSizes.y0 - 100)))
--        end
--    end
--end

function createChangeBtn(self)
    local btn = ui.newButton({img="#mainUI/jiahao.png", callback=handler(self, changeBtnHd)})
    self.changeBtn = btn
    btn.showBtn__ = true
    btn:setLocalZOrder(2)
    btn:setGuideTag(self.__cname, "change")
    local tPos = startPosTab[1]
    ui.addToPos(btn, self, tPos)
    
    local spr = ui.newSpr("#mainUI/jiahao_1.png")
    self.changeBtn_x = spr
    ui.addPosTo(spr, btn)
end


function itemHandel(self, btn)
	local model = btn.model
    if not model.ctl then
        return
    end
	gprint("主界面按钮回调", model.ctl)
	
	if not model.clickNoRemoveN then
		-- 引导按钮,点击就删除
    	ui.removeNode(btn.guideNode)
        ui.removeNode(btn.guideNodeLoad)
	end
	
	local controller = ctl[model.ctl]
	if controller then
		if model.view then
			local openFunc = controller[model.view]
			if openFunc then
				openFunc(controller)
			end
		else
			controller:openView()
		end
	end
end


function createRoleHead(self)
	local playerModel_ = gData.RoleData.model
    
    
    -- 头像背景	
    local headBgSpr = gui.easyBtn(nil, "#mainUI/touxiang.png", function()
        ctl.RoleInfoController:openView()
    end)
--    ui.newSpr("#mainUI/touxiang.png") 
    self.headBgSpr = headBgSpr
    local tSize = headBgSpr:getContentSize()
    ui.addToPos(headBgSpr, self, cc.p(ui.autoSizes.x0 + tSize.width/2 - 5, ui.autoSizes.y1 - tSize.height/2 - 23))
    
    -- 元宝铜钱等
--    local moneyBlackBg = ui.newSpr("#mainUI/moneyBlackBg.png")
--    ui.addChildEx(moneyBlackBg, app.scene.hudLayer, ui.autoSizes.x0, ui.autoSizes.y1 - 31, cc.p(0, 0), 0, -3)
--    self.moneyBlackBg = moneyBlackBg
    -- 充值
    local moneyNode = gfile.MoneyHUD.new()
--    moneyNode:setScale(0.9)
    ui.addChildEx(moneyNode, app.scene.hudLayer, ui.autoSizes.x0 + 2, ui.autoSizes.y1 - 14, cc.p(0, 0))
    self.moneyNode = moneyNode
    
    
   -- 头像按钮     
    local headBtn = gui.easyBtn(nil, "res/headImages/headImg" .. playerModel_.category .. "_small.png", function()
        ctl.RoleInfoController:openView()
    end)
    ui.addPosTo(headBtn, headBgSpr, cc.p(0, 0), cc.p(13, 15))
    self.headBtn = headBtn
    headBtn:setGuideTag(self.__cname, "RoleInfoController")
    
    -- 等级
    local lvBg = ui.newSpr("#mainUI/dengjikuang.png")
    ui.addChildEx(lvBg, headBgSpr, 2, 15, cc.p(0, 0.5))
    
    local label = gui.newLabel(playerModel_.level, cc.c3b(255, 222, 120))
    ui.addChildEx(label, lvBg, 0.5, 0.5, cc.p(0.5, 0.5), 0, -0)
    self.levelLabel = label
	
	-- 名字
	local label = ui.newLabel({text=playerModel_.name, size=22})
	self.nameLabel = label
    ui.addPosTo(label, headBgSpr, cc.p(0, 0), cc.p(105, 37), cc.p(0, 0.5))
	
	-- 战力
    local spr = ui.newSpr("#mainUI/zhan.png")
    ui.addChildEx(spr, headBgSpr, 120, 83)
    
    local label = ui.newLabelChar({text=playerModel_:getAllFightPower(), file="res/fonts/num_zhanli.png", w=17, h=22, start='0'}) 
    ui.addChildEx(label, spr, 1, 3, cc.p(0, 0))
    self.powerLabel = label
end

function createChatBtn(self)
    local btnLayer = ui.newLayer()
    btnLayer:setContentSize(cc.size(350, 101))
    ui.addChildEx(btnLayer, self, ui.autoSizes.x0 + 0, ui.autoSizes.y0 + 50, cc.p(0, 0))
    self.chatBtnLayer = btnLayer

    local tagBtn = gui.newTagBtn({tag = {{text="聊天"}, {text="战报"}},
        img="#mainUI/chatBtn_1.png", hImg="#mainUI/chatBtn_2.png",
        callback = handler(self, self.updateChatState), 
        arrowImg = "#share/arrowRight2.png",
        idx = gData.MainUIData.getChatState(),
         fsize=22, gap=12})
    tagBtn:setLocalZOrder(3)
    ui.addChildEx(tagBtn, btnLayer, 0.5, 0, cc.p(0.5, 1), 4)
    self.chatTagBtn = tagBtn
    self.chatBtns = tagBtn:getBtns()

    local btn = gui.easyBtn(nil, nil, function(tBtn)
        self.chatStyle = 3 - self.chatStyle
        createChatBoard(self, self.chatStyle)
        ui.changeSpr(tBtn.spr, self.chatStyle == 1 and "#mainUI/downArrow.png" or "#mainUI/upArrow.png")
    end, cc.size(50, 50))
    ui.addChildEx(btn, btnLayer, 0, 0, cc.p(0, 1), 0, 10)
    
    btn.spr = ui.newSpr(self.chatStyle == 1 and "#mainUI/downArrow.png" or "#mainUI/upArrow.png")
    ui.addChildEx(btn.spr, btn)
    
--    self.chatChangeBtn = gui.easyBtn(nil, self.chatStyle == 1 and "#mainUI/downArrow.png" or "#mainUI/upArrow.png", function(tBtn)
--        self.chatStyle = 3 - self.chatStyle
--        createChatBoard(self, self.chatStyle)
--        tBtn:changeImage(self.chatStyle == 1 and "#mainUI/downArrow.png" or "#mainUI/upArrow.png")
--    end)
--    ui.addChildEx(self.chatChangeBtn, btnLayer, 0, 0, cc.p(0, 1))
end

function createChatBoard(self, style)
    
    ui.removeNode(self.chatLayer)
    
    local viewSize, hTab , yTab , fightH, recordNum

    if style == 2 then -- 小
        viewSize = cc.size(350, 111)
        hTab = {[6] = 52, [7] = 52}
        yTab = {[6] = 0, [7] = 59}
        fightH = 59
        recordNum = {[6]=2,[7]=1,[8]=4}
    else
        viewSize = cc.size(350, 187)
        hTab = {[6] = 128, [7] = 52}
        yTab = {[6] = 0, [7] = 135}
        fightH = 135
        recordNum = {[6]=5,[7]=1,[8]=7}
    end
    
    local layer = ui.newLayer(cc.c4b(0, 0, 0, 125))
    layer:setLocalZOrder(-1)
    ui.addChildEx(layer, self, ui.autoSizes.x0 + 0, ui.autoSizes.y0 + 50, cc.p(0, 0))
    self.chatLayer = layer
    
    self.chatNode = {}
    for i = 1, 2 do
        local node = ui.newNode()
        node:setContentSize(viewSize)
        self.chatLayer:addChild(node)
        self.chatNode[i] = node
    end
    
    self.chatCtn = {}
    self.chatScv = {}
    -- 聊天信息
    for i = 6, 7 do
        local h = hTab[i]
        local ctn = ui.newContainer(cc.size(viewSize.width - 12, h), h)
        local scv = ui.newScrollView(cc.size(viewSize.width - 12, h), 1, ctn)
        scv:setTouchEnabled(false)
        ui.addChildEx(scv, self.chatNode[1], 0, yTab[i], cc.p(0, 1), 4, h)
        self.chatCtn[i] = ctn
        self.chatScv[i] = scv
    	-- 记录
        for j = recordNum[i], 1, -1 do
            local msg = gData.ChatData.getFromRecord(i, -j)
            if msg then
                local msgLayer = ChatFactory.createMsgLabel(ctl.ChatController, msg, true)
                if not tolua.isnull(msgLayer) then
                    self.chatCtn[i]:addNode(msgLayer)
                    scv:setContentOffset(scv:minContainerOffset())
                end
            end
        end
    end
    
    -- 战报
    local ctn = ui.newContainer(cc.size(viewSize.width - 12, fightH), fightH)
    local scv = ui.newScrollView(cc.size(viewSize.width - 12, fightH), 1, ctn)
    scv:setTouchEnabled(false)
    scv:setContentOffset(scv:minContainerOffset())
    ui.addChildEx(scv, self.chatNode[2], 0, 0, cc.p(0, 0), 4)
    self.fightCtn = ctn
    self.fightScv = scv
    
    --记录
    for i = recordNum[8], 1, -1 do
        local msg = gData.ChatData.getFromRecord(8, -i)
        if msg then
            if msg.labelType == 1 then
                self:addFightStat(gui.newLabels(msg[1], msg[2], msg[3]))
            else
                self:addFightStat(gui.newLabel(msg[1], msg[2], msg[3]))
            end
        end
    end
    
--    ui.removeNode(self.chatLine)
    -- 聊天的分界线
    local line = ui.newSplit(viewSize.width, 0)
    ui.addChildEx(line, self.chatNode[1], 0.5, yTab[7], cc.p(0, 0.5), 0, -3)
--    self.chatLine = line
    
    line = ui.newSplit(viewSize.width, 0)
    ui.addChildEx(line, self.chatNode[2], 0.5, yTab[7], cc.p(0, 0.5), 0, -3)

    self.chatLayer:setContentSize(viewSize)
    self:visibleChatBroad()    
end -- createChatBoard

function updateChatBoard(self)
    for i = 6, 7 do
        local msg = gData.ChatData.getFromBuffer(i)
        if msg then
            local msgLayer = ChatFactory.createMsgLabel(ctl.ChatController, msg, true)
            if not tolua.isnull(msgLayer) then
                self.chatCtn[i]:addNode(msgLayer)
                self.chatScv[i]:setContentOffset(self.chatScv[i]:minContainerOffset())
            end
            if i == 6 and gData.MainUIData.getChatState() == 2 then -- 有新消息且当前是战斗频道
                if tolua.isnull(self.chatBtns[1].nSpr) then
                    local spr = ui.newSpr("#guide/n.png")
                    ui.addChildEx(spr, self.chatBtns[1], 1, 1, cc.p(0.5, 0.5))
                    self.chatBtns[1].nSpr = spr
                end
            end
        end
    end
end

function tClass:VisUpView(vis)
    gData.MainUIData.mainUIState = vis
    self.headBtn:setEnabled(vis)
    self.headBtn:setVisible(vis)
    self.headBgSpr:setVisible(vis)
    self.headBgSpr:setEnabled(vis)
    self.moneyNode:setVisible(vis)
    self.moneyNode:setEnabled(vis)
	
	-- 活跃度
	self:visibleActive(vis)
	-- 切换按钮
	self:visibleChangeBtn(vis)
	-- 任务按钮
	self:visibleMissionBtn(vis)
    self:visibleTaskBtn(vis)
	
	--隐藏上面的按钮
	local tTab = self.itemPlaceTab[3]
	if tTab then
        for i, v in ipairs(tTab) do
            v:setVisible(vis)
            v:setEnabled(vis)
        end
	end
    --隐藏左面的按钮
    tTab = self.itemPlaceTab[2]
    if tTab then
        for i, v in ipairs(tTab) do
            v:setVisible(vis)
            v:setEnabled(vis)
        end
    end

	tTab = self.itemPlaceTab[4]
	if tTab then
        for i, v in ipairs(tTab) do
            if v.model.icon == "#mainUI/zhandou_1.png" then
                v:setVisible(vis)
                v:setEnabled(vis)
            end
        end
	end
    
	--隐藏其他按钮
	tTab = self.itemPlaceTab[5]
	if tTab then
        for i, v in ipairs(tTab) do
            if v.model.tag ~= "ChatController" then
                v:setVisible(vis)
                v:setEnabled(vis)
            end
        end
	end
	
end


local function visibleBtn(btn, parent, visible)
	if nonull(btn) then
--		if not visible then
--			visible = false
--		else
--			visible = true
--		end
--		if visible == btn:isVisible() then
--			return
--		end
		if visible then
			if null(btn:getParent()) then
				parent:addChild(btn)
--				btn:release()
			end
		else
			if nonull(btn:getParent()) then
--    			btn:retain()
    			btn:removeFromParent(true)
			end
		end
		--gprint("计数: " .. btn:getReferenceCount())
	end
end

function tClass:visibleActive(visible)
    if nonull(self.activeBtn_) then
        visibleBtn(self.activeBtn_, self, visible)
        self:updateActiveItem()
    end
end
function tClass:visibleChangeBtn(visible)
	if nonull(self.changeBtn) then
	    if visible ~= self.changeBtn.showBtn__ then
	       changeBtnHd(self)
	   end
	end
end

function tClass:visibleMissionBtn(visible)
    if tolua.isnull(self.missionBtn) then
        return
    end
    if nil == visible then
        visible = false
    end
    self.missionBtn:setVisible(visible)
    self.missionBtn:setEnabled(visible)
end

function tClass:visibleTaskBtn(visible) 
     if tolua.isnull(self.taskBtn) then
        return
    end
    if nil == visible then
        visible = false
    end
    self.taskBtn:setVisible(visible)
    self.taskBtn:setEnabled(visible)
end

function tClass:createActiveItem()
    if not tolua.isnull(self.activeBtn_) then
        return
    end
    
    if not gData.ActiveData.checkMainUIOpen() then
        return
    end

	local tLayer = ui.newLayer(cc.c4b(0, 0, 0, 200), cc.size(193, 40))
	
	local activeBtn = ui.newBtn({img=tLayer
        , text="", callback=function()
--        	gprint("活跃度: " .. self.activeBtn_:getTag())
        	if not self.activeRecommend_ then
        	   ctl.TaskController:openView(1) -- 每日必做
    		else
    			gData.ActiveData.doActive(self.activeRecommend_.id)
        	end
        end
    })
    self.activeBtn_ = activeBtn
    activeBtn:retain()
    self.needRemoveTab_["activeItem"] = activeBtn
    ui.addToPos(activeBtn, self, cc.p(ui.autoSizes.x0, ui.autoSizes.yc), cc.p(0, 0.5), cc.p(10, 0))
    
    local tLabel = gui.newLabels({{"更多活跃度", ui.color.yellow, nil, cc.c3b(0, 0, 0)}, {"", ui.color.green, nil, cc.c3b(0, 0, 0)}}, 2, 22)
    tLabel:setLocalZOrder(10)
    self.activeLabel_ = tLabel
    ui.addChildEx(tLabel, activeBtn, 0, 0.5, cc.p(0, 0.5), 5)
    
    self:updateActiveItem()
end


function updateMaxPassIdFB(self, passid)
   self:createActiveItem()
end

function tClass:addItem(itemTag, callback)
    local model = gData.MainUIData.getModelByTag(itemTag)
    if model then
        if not self.itemPlaceTab[model.place] then
            self.itemPlaceTab[model.place] = {}
        end
        local item = newItem(self, model)
        if nonull(item) then
            local tPos
            if model.posTab then
                tPos = cc.pAdd(cc.p(ui.autoSizes[model.posTab.x], ui.autoSizes[model.posTab.y]), model.posTab.ajPos)
            else
                tPos = startPosTab[model.place]
            end
            ui.addToPos(item, self, tPos)
            
            table.insert(self.itemPlaceTab[model.place], item)
            table.sort(self.itemPlaceTab[model.place], function(a, b)
                return a.model.index < b.model.index
            end)
            self.itemTab[model.tag] = item
            item:setGuideTag("MainUIView", model.tag)
            
            item.callback = callback
            
            updatePosNoAction(self, model.place)
            self:VisUpView(gData.MainUIData.mainUIState)
            
            gData.MainUIData.addToItemTab(item)
            gData.MainUIData.addToOpenModels(model)
            
            
            if model.isOpenShowN then
                self:updateButtonNumGuide(model.tag, -1)
            end
        end
    else
        gprint("功能开启失败")
        if callback then
            callback()
        end
    end
end

function tClass:removeItem(itemTag)
    local btn = self.itemTab[itemTag]
    if nonull(btn) then
        local place = btn.model.place
        for i, v in pairs(self.itemPlaceTab[place]) do
            if v.model.index == btn.model.index then
                table.remove(self.itemPlaceTab[place], i)
                ui.removeNode(btn)
                updateAllPos(self, place)
                return true
            end
        end
    end
end

function tClass:updateActiveItem()
    if tolua.isnull(self.activeBtn_) then
        return
    end
    
    ui.removeNode(self.activeBtn_.effAnim)
    
	local recommend = gData.ActiveData.getRecommend()
	if not recommend then
		self.activeLabel_:setString("更多活跃度", 1)
		self.activeLabel_:setString("", 2)
	else
		self.activeLabel_:setString(recommend.name, 1)
		self.activeLabel_:setString(string.format("(%d/%d)", recommend.curTime, recommend.maxTime), 2)
        if null(self.activeBtn_.effAnim) then
        -- 发光
            local anim = ui.newAnim("greenKAnim")
        self.activeBtn_.effAnim = anim
        anim:setScaleY(1.3)
        anim:setScaleX(1.9)
        ui.addPosTo(anim, self.activeBtn_)
        end
	end
	self.activeRecommend_ = recommend
end

function tClass:update_fightPower_(em)
	local playerModel_ = gData.RoleData.model
	self.powerLabel:setString(playerModel_:getAllFightPower())--em.value)
end

function tClass:update_level_(em)
	self.levelLabel:setString(em.value)
end
--更新角色等级
function tClass:update_name_(name)
    self.nameLabel:setString(name)
end

function updateExpTimer(self)
    ui.removeNode(self.expProTimer)
    local proTimer = ui.newProTimerL({img="#mainUI/exp.png"})
    proTimer:setLocalZOrder(1)
    ui.addPosTo(proTimer, self.expBgSpr, cc.p(0.5, 0.5), cc.p(0, 0))
    self.expProTimer = proTimer
end


function tClass:update_exp_(em)
	local playerModel_ = gData.RoleData.model
	
--    gprint("lastExpLevel: " .. self.lastExpLevel)
--    gprint("level: " .. playerModel_.level)
--    
--    gprint("exp: " .. playerModel_.exp)
--    gprint("next_level_exp: " .. playerModel_.next_level_exp)

--    if playerModel_.exp > playerModel_.next_level_exp then
--        return
--    end
    
    local percent = playerModel_.exp / playerModel_.next_level_exp * 100

    self.expProTimer:stopAllActions()

    if self.lastExpLevel == playerModel_.level then
        local tTime = 2 * (percent - self.expProTimer:getPercentage())*0.01
        ui.proTActionTo(self.expProTimer, tTime, percent)
    else
        self.lastExpLevel = playerModel_.level
        local tTime = 2 * (100 - self.expProTimer:getPercentage())*0.01

        ui.runActions(self.expProTimer, {cc.ProgressTo:create(tTime, 100)
            , cc.ProgressTo:create(0, 0)
            , cc.ProgressTo:create(2 * percent * 0.01, percent)
        })
    end
    
    self.expPercentLabel:setString(string.format("%s / %s ( %.2f%% )", playerModel_.exp, playerModel_.next_level_exp, percent))
end

function tClass:update_vip_level_(em)
    --更新主界面按钮VIP等级
    --self:updateItem("VipController")
    self:updateItem("VipPriController")
end

function tClass:update_jingjie_(em)
    self:updateItem("JingjieController")
end

function tClass:updateBagGuide()
    local btn = self.itemTab["BagController"]
	if nonull(btn) then
        if (gData.GoodsData.isBagFull()) then
			if null(btn.guideNodeFull) then
			    local model = gData.MainUIData.getModelByTag("BagController")
                local guideNode = gui.newGuideN(model.isShowEff, "#guide/full.png")
                btn.guideNodeFull = guideNode
                ui.addPosTo(guideNode, btn, cc.p(1, 1), cc.p(0, 0))
			end
		else
			ui.removeNode(btn.guideNodeFull)
		end
	end
end

function tClass:updateEquipLoadGuide(isLoad)
	--TipMsg.show("装备设置N")
	--gprint(isLoad)
	local btn = self.itemTab["PetController"]
	if nonull(btn) then
		if isLoad then
			if null(btn.guideNodeLoad) then
			    local model = gData.MainUIData.getModelByTag("PetController")
                local guideNode = gui.newGuideN(model.isShowEff)
				btn.guideNodeLoad = guideNode
    			ui.addPosTo(guideNode, btn, cc.p(1, 1), cc.p(0, 0))
			end
			--TipMsg.show("装备设置N添加")
		else
			ui.removeNode(btn.guideNodeLoad)
			btn.guideNodeLoad = nil
			--TipMsg.show("装备设置N删除")
		end
	end
end

-- 大于0就是数字, 小于0就是n, 等于0就是删除
function tClass:updateButtonNumGuide(tag, num)
	num = num or 0
	local btn = self.itemTab[tag]
	if nonull(btn) then
		if num > 0 then
			ui.removeNode(btn.guideNode)
			if null(btn.guideSpr_) then
				local tSpr = ui.newSpr("#guide/numBg.png")
                tSpr:setLocalZOrder(1)
    			btn.guideSpr_ = tSpr
    			ui.addPosTo(tSpr, btn, cc.p(1, 1), cc.p(0, 0))
			end
			if null(btn.guideLabel_) then
				local label = gui.newLabel(num, ui.color.white, 20)
    			btn.guideLabel_ = label
    			ui.addPosTo(label, btn.guideSpr_)
			else
				btn.guideLabel_:setString(num)
			end
		elseif num < 0 then
			ui.removeNode(btn.guideSpr_)
			if null(btn.guideNode) then
			    local model = gData.MainUIData.getModelByTag(tag)
                local guideNode = gui.newGuideN(model.isShowEff)
                guideNode:setLocalZOrder(2)
                btn.guideNode = guideNode
                ui.addPosTo(guideNode, btn, cc.p(1, 1), cc.p(0, 0))
			end
		elseif num == 0 then
			ui.removeNode(btn.guideSpr_)
			ui.removeNode(btn.guideNode)
		end
	end
end

-- 不删除的N
function tClass:updateNoDelGuide(tag, num)
    num = num or 0
    local btn = self.itemTab[tag]
    if nonull(btn) then
        if num == 0 then
            ui.removeNode(btn.noDelNode)
        else
            if null(btn.noDelNode) then
                local guideNode = gui.newGuideN(false)
                btn.noDelNode = guideNode
                guideNode:setLocalZOrder(3)
                guideNode:setScale(1.01)
                ui.addPosTo(guideNode, btn, cc.p(1, 1), cc.p(1, 0))
            end
        end
    end
end

function tClass:updateFightAnim(fight)
--	TipMsg.show("战斗标志动画")
    local btn = self.itemTab["FightController"]
	if nonull(btn) then
		if fight then
            btn:changeImage("#mainUI/zhandou.png")
			ui.removeNode(btn.fightSearchAnim_)
			if null(btn.fightAnim_) then
    			local tab = {
            		animName = tonumber(gData.RoleData.model:getBodyName()),
            		actionName = "attack",
            		direction  = 2,
            	}
            	local tAnim = SimpleAnim.createLoop(tab, {"attack1", "attack2", "attack"})
            	tAnim:setScale(0.4)
            	ui.addPosTo(tAnim, btn, cc.p(0.5, 0), cc.p(0, 35))
            	btn.fightAnim_ = tAnim
                	
             --   	tab.sp = tAnim
             --   	btn:stopAllActions()
             --   	ui.doDelay(btn, function()
             --   		if null(tab.sp) then
             --       		btn:stopAllActions()
             --       	else
             --   			SimpleAnim.change(tab)
           		-- 	end
           		-- end, 2, 0)
        	end
		else
            btn:changeImage("#mainUI/zhandou2.png")
			ui.removeNode(btn.fightAnim_)
			if null(btn.fightSearchAnim_) then
			local csize = btn:getContentSize()
			local pos = cc.p(csize.width*0.5, csize.height*0.5-12)
    		local tAnim = gui.newSearchEnemyAnim(btn, pos, false)
    		tAnim:setScale(0.8)
--    		ui.addPosTo(tAnim, btn, cc.p(0.5, 0.5), cc.p(0, 0))
    		btn.fightSearchAnim_ = tAnim
    		
    		end
		end
	end
end


function tClass:updateChangeMap()
	local btn = self.itemTab["map"]
	if nonull(btn) then
		btn:setString(MapUtil.getCurMapName())
    end
end

function tClass:addFightStat(label)
    if tolua.isnull(label) then
        return
    end
    
    if not tolua.isnull(self.fightCtn) then
        self.fightCtn:addNode(label)
        self.fightScv:setContentOffset(self.fightScv:minContainerOffset())
    end
end

function tClass:visibleChatBroad(chatState)
    chatState = chatState or gData.MainUIData.getChatState()
    if chatState == 1 then
        self.chatScv[6]:setVisible(true)
        self.chatNode[2]:setVisible(false)
    else
        self.chatScv[6]:setVisible(false)
        self.chatNode[2]:setVisible(true)
    end
end

function tClass:updateChatState(btn)
    self:visibleChatBroad(btn.tag)
    gData.MainUIData.setChatState(btn.tag)
    
    local chatBtn = self.itemTab["ChatController"]
    if not tolua.isnull(chatBtn) then
        chatBtn:changeImage("#mainUI/liaotian" .. btn.tag .. ".png")
    end
    
    if not tolua.isnull(btn.nSpr) then
        btn.nSpr:removeFromParent()
    end
end

-----主线引导按钮
function tClass:updateMissionBtn()
    local missInfo = gData.GuideMissionData.getInfo()
--    printTab(missInfo)
--    gprint("==== mission info in MainUIVIew")
    ui.removeNode(self.taskBtn)
    if missInfo.id == 0 then
        ui.removeNode(self.missionBtn)
    else
        if tolua.isnull(self.missionBtn) then
            self.missionBtn = gui.easyBtn("", "#mainUI/renwu.png")
            ui.addChildEx(self.missionBtn, self, ui.autoSizes.x0 + 64,  ui.autoSizes.y0 + 422)
            self.missionBtn:setGuideTag(self.__cname, "mission")
            
            -- local spr = ui.newSpr("#share/textBg8.png")
            local spr = ui.newLayer(cc.c4b(0, 0, 0, 200), cc.size(193, 40))
            ui.addChildEx(spr, self.missionBtn, 0.5, 0, cc.p(0.5, 0.5), 36)
            
            self.missionLabel = gui.newLabel("", ui.color.yellow, 22)
            ui.addChildEx(self.missionLabel, spr, 0.5, 0.5, cc.p(0.5, 0.5), -15)
        end
        
        if missInfo.status == 1 then
            self.missionBtn:setCallback(function()
                TipMsg.show(missInfo.name .. "任务进行中")
                GuideManager.reloadMissionBuff()
            end)
        else
            self.missionBtn:setCallback(function()
                -- 重新执行任务引导
                GuideManager.startMissionGuide()
            end)
        end
        self.missionLabel:setString(missInfo.name)
    end
    self:visibleMissionBtn(gData.MainUIData.mainUIState)
end

-- 提示光效
function tClass:updateMissionBtnState(state)
    if tolua.isnull(self.missionBtn) then
        return
    end

    if not gData.MainUIData.mainUIState then
        return
    end

    if state then
        if not tolua.isnull(self.missionBtn.selectLight) then
            return
        end

        -- 判断是否有任务 且点击可执行
        local missInfo = gData.GuideMissionData.getInfo()
        if not missInfo or missInfo.id == 0 or missInfo.status == 1 then
            return
        end
        self.missionBtn.selectLight = ui.selectAnim(self.missionBtn)
    else
        ui.removeNode(self.missionBtn.selectLight)
    end
end

-------任务引导按钮
function tClass:updateTaskBtn()
    ui.removeNode(self.taskBtn)
    if not tolua.isnull(self.missionBtn) then
        return
    end
    
    local isShow, hasMainTask, descTab, status, taskId, isOpen = gData.TaskData.getDescInmainui()
    if not isShow then
        return
    end

    self.taskBtn = gui.easyBtn("", "#mainUI/renwu.png")
    ui.addChildEx(self.taskBtn, self, ui.autoSizes.x0 + 64,  ui.autoSizes.y0 + 422)
    if hasMainTask then
        -- local spr = ui.newSpr("#share/textBg8.png")
        local spr = ui.newLayer(cc.c4b(0, 0, 0, 200), cc.size(193, 40))
        ui.addChildEx(spr, self.taskBtn, 0.5, 0, cc.p(0.5, 0.5), 36)
        local descLabel = gui.newLabels(descTab, nil, 22, (status == 0 and ui.color.yellow or ui.color.green))
        ui.addChildEx(descLabel, spr, 0, 0.5, cc.p(0, 0.5), 2) 

        if not isOpen or status == 1 then
            self.taskBtn:setCallback(function()
                ctl.TaskController:openView(2)
            end) 
        else
            self.taskBtn:setCallback(function()
                gData.TaskData.goto(taskId)
            end)
        end  
    else
        self.taskBtn:setCallback(function()
            ctl.TaskController:openView(2)
        end)  
    end
   
    self:visibleTaskBtn(gData.MainUIData.mainUIState)
end

function updatePetBarGuideN(self, isGuide)
	if isGuide then
		self:updateButtonNumGuide("fengShen", -1)
	end
end


function updatePetJinHuaGuideN(self, isGuide)
--	gprint("updatePetJinHuaGuideN=========")
--	gprint(isGuide)
	if isGuide then
		self:updateButtonNumGuide("fengShen", -1)
	else
		self:updateButtonNumGuide("fengShen", 0)
	end
end


function updatePetHelpGuideN(self, param)
	local isGuide = param.isGuide
	if isGuide then
		self:updateButtonNumGuide("fengShen", -1)
	end
end


return tClass