------------------------------------------------------
--作者:   YuZhenjian
--日期:   2016年1月14日
--描述:   快捷键界面
------------------------------------------------------
local BaseClass = ui.BaseLayer
local HotKeyView = class("HotKeyView",BaseClass)

local SkillModel = SkillModel:getInstance()
local SettingModel = SettingModel:getInstance()
local DragItem = require("gamecore/ui/DragItem")

local DRAG_MODE = true -- 操作方式：拖动/点击
local STATE_VIEW = 1 -- 查看
local STATE_SET = 2 -- 设置
local updateViewFunc = {}

local skillConfig = gameconfig.skillVO
local itemConfig = gameconfig.itemVO
-- local itemid = 20300101
local itemIds = {
	[7] = 24000101, --   疗伤药
	[8] = 20200101, --   随机神石
	[9] = 20400101, --   回城神石
    [10] = 23900001, --   新手传送石
}

local hotKeyNum = 10

local function getGoodImgById(itemid)
    -- local imgPath = "icon/goods/".. itemConfig[itemid].itemPicTempName .. ".png"
    local imgPath = "icon/skill/".. itemid .. ".png"
    return ui.newSprFrame(imgPath)
end


local function getSkillImgById(sid)
    local skillData = skillConfig[sid]
    local imgPath = "icon/skill/1601.png"
    if skillData then
        -- imgPath = "icon/skill/" .. skillData.sid .. ".png"
        imgPath = "icon/skill/2110" .. skillData.sid .. ".png"
    end
    return ui.newSprFrame(imgPath)
end



------------------------------------------------------
--界面初始化
------------------------------------------------------
function HotKeyView:ctor()
    BaseClass.ctor(self)

    self.defaultList = SkillModel:getDefaultSkillIdList()
    self.isHotKeyChanged = false

    self.layout = ui.newLayoutUtilYzj("HotKeyView", false)

    local bj = ui.new9Spr("#common/middleBj.png", cc.size(909, 250))
    ui.addChildAuto(self.layout, self, bj, "bj")
	
	self.skillLayer = ui.newLayer(cc.size(150, 100))--, cc.c4b(255, 255, 0, 80))
	self.skillLayer:setPosition(0, 0)
	bj:addChild(self.skillLayer, 3)

    local bj2 = ui.new9Spr("#common/middleBj.png", cc.size(909, 230))
    ui.addChildAuto(self.layout, self, bj2, "bj2")

	self.hotkeyLayer = ui.newLayer(cc.size(150, 100))--, cc.c4b(255, 255, 0, 80))
	self.hotkeyLayer:setPosition(0, 0)
	bj2:addChild(self.hotkeyLayer, 3)


	local tips1 = ui.newLabel("长按图标并拖到下方的键位，即可完成设置", 22, ui.color.green)
	ui.addChildAuto(self.layout, self, tips1, "tips1", 0, 1)

	local tips2 = ui.newLabel("设置提示：\n键位1~6为技能键位，键位7~8为道具键位", 22, ui.color.green)
	ui.addChildAuto(self.layout, self, tips2, "tips2", 0, 1)


	self.curState = STATE_VIEW
end

function HotKeyView:onEnter()
	self:createSkill()
	self:createHotKey()


    self.resetBtn = ui.newBlueButton("还原默认")
    self.resetBtn:onClick(self, self.onResetHandler)
    if not DRAG_MODE then
        ui.addChildAuto(self.layout, self, self.resetBtn, "resetBtn")

    	self.setBtn = ui.newBlueButton("设置快捷键")
    	ui.addChildAuto(self.layout, self, self.setBtn, "setBtn")
    else
        ui.addChildAuto(self.layout, self, self.resetBtn, "resetBtn_drag")
    end

	self:updateView(self.curState)
    -- Dispatcher.addEventListener(EventType.EQUIP_SLOT_UPDATE_SINGLE, equipSlotUpdateSingle, self)
end

function HotKeyView:onExit()
    -- Dispatcher.removeEventListener(EventType.ROLE_BSILVER_CHANGED, self.updateCost)
    if self.isHotKeyChanged then
        Dispatcher.dispatchEvent(EventType.REQUEST_SYSTEM_CONFIG_CHANGE)
    end
end

function HotKeyView:updateIconHandler(icon, model)
    local tType = model.type
    local tId = model.id
    if icon.isGrey == nil then
        icon.isGrey = false
    end

    local isGrey = false
    if tType == 1 then -- 技能
        icon:setSpriteFrame(getSkillImgById(tId))
        isGrey = not (SkillModel:hasSkill(tId))
    elseif tType == 2 then -- 道具
        icon:setSpriteFrame(getGoodImgById(tId))
        isGrey = false
    end

    if isGrey ~= icon.isGrey then
        if isGrey then
            ui.SpriteFilter:addGreyEff(icon)
        else
            ui.SpriteFilter:removeEff(icon)
        end
    end
end

function HotKeyView:onEnableHandler(item, _enable)
    if _enable then
        ui.removeSelf(item.lockSpr)
    else
        item.lockSpr = ui.newSpr("#common/lock3.png")
        item:addChild(item.lockSpr, 100)
        ui.alignCenter(item, item.lockSpr)
    end
end

function HotKeyView:createSkill()
    self.skillList = {}
    self.skillItems = {}

	local hun = myRole.category * 100
    for i = 1, hotKeyNum do
        local data = {}
        if i <= 6 then
            data.type = 1
            data.id = hun + i + 1
            data.text =  "技能" .. (i + 1)
        else
            data.type = 2
            data.id = itemIds[i]
            data.text = itemConfig[data.id].name
        end
        self.skillList[i] = data
    end

    local x, y = 70, 155
    for i, v in ipairs(self.skillList) do
        local skillBtn = DragItem.new()
        skillBtn:setUpdateIconCallback(handler(self, self.updateIconHandler))
        skillBtn:setEnableCallback(handler(self, self.onEnableHandler))
        skillBtn:setDragEnabled(DRAG_MODE)
        -- skillBtn:setBeganCallback(callback)
        -- skillBtn:setMovedCallback(callback)
        if not DRAG_MODE then
            skillBtn:setEndedCallback(handler(self, self.onSkillBtnClickedHandler))
        else
            skillBtn:setDragEndedCallback(handler(self, self.onSkillDragEndedHandler))
        end
        -- skillBtn:setDragBeganCallback(callback)
        skillBtn.index = i
    	ui.addChild(self.skillLayer, skillBtn, x, y, 0.5, 0.5)

        skillBtn:setModel({type = v.type, id = v.id})
        skillBtn:enable((i >= 7) or SkillModel:hasSkill(v.id))
        self.skillItems[i] = skillBtn

    	if i % 8 == 0 then
    		x = 70
    		y = y - 98
    	else
    		x = x + 109
    	end
    end
end

function HotKeyView:createHotKey()
	self.shortcutItems = {}
	local x, y = 70, 117

    for i = 1, 8 do
        local shortcutbtn = DragItem.new{text = "键" .. i, fontSize = 26, fontColor = ui.color.white}
        shortcutbtn:setUpdateIconCallback(handler(self, self.updateIconHandler))
        shortcutbtn:setEnableCallback(handler(self, self.onEnableHandler))
        shortcutbtn:setDragEnabled(DRAG_MODE)
        -- skillBtn:setBeganCallback(callback)
        -- skillBtn:setMovedCallback(callback)
        if not DRAG_MODE then
            shortcutbtn:setEndedCallback(handler(self, self.onShortcutBtnClickedHandler))
        else
            shortcutbtn:setDragEndedCallback(handler(self, self.onShortcutDragEndedHandler))
        end
        -- skillBtn:setDragBeganCallback(callback)
        shortcutbtn.index = i
        ui.addChild(self.hotkeyLayer, shortcutbtn, x, y)

        self.shortcutItems[i] = shortcutbtn

        local deleteSp = ui.newSpr("#skill/close2.png")
        shortcutbtn:addChild(deleteSp)
        ui.alignCenter(shortcutbtn, deleteSp, 1, 1)
        deleteSp:setVisible(false)

        shortcutbtn.deleteSp = deleteSp

    	if i % 8 == 0 then
    		x = 70
    		y = y - 98
    	else
    		x = x + 109
    	end
    end
end



function HotKeyView:updateShortcutKey(list)
    ui.removeSelf(self.selectSp)

    if list then
        for i, v in ipairs(list) do
            SettingModel:setSystemSkillkey(i, list[i])
        end
    end

    for i, btn in ipairs(self.shortcutItems) do
        local enable = (i >= 7) or SkillModel:hasSkill(self.defaultList[i])
        btn:enable(enable)
        if not enable then
            local sid = self.defaultList[i]
            -- yzjprint("=== not enable = sid = ", sid)
            local stype = i < 7 and 1 or 2
            btn:setModel({type = stype, id = sid})
        else
            local sid = SettingModel:getSystemSkillkeyByIndex(i)
            if sid and sid ~= 0 then
                local stype = i < 7 and 1 or 2
                btn:setModel({type = stype, id = sid})
                btn.deleteSp:setVisible((self.curState == STATE_SET))
            else
                btn:setModel(nil)
                btn.deleteSp:setVisible(false)

                if not DRAG_MODE then
                    if self.selectHotKeyIndex == i then
                        self.selectSp = ui.newSpr("#common/skillSelect.png")
                        btn:addChild(self.selectSp, 10)
                        ui.alignCenter(btn, self.selectSp)
                    end
                end
            end
        end
    end
end


function HotKeyView:setShortcut(index, id)
    self.isHotKeyChanged = true
    SettingModel:setSystemSkillkey(index, id)
end


function HotKeyView:removeShortcut(index)
    if not DRAG_MODE then
        if self.curState ~= STATE_SET then
            return 
        end
    end
    self.isHotKeyChanged = true
    SettingModel:setSystemSkillkey(index,0)
end


function HotKeyView:onSkillBtnClickedHandler(button)
    if self:isSkillSettable(button:getModel(), self.selectHotKeyIndex) then
        self:setShortcut(self.selectHotKeyIndex, button:getModel().id)
        self:updateShortcutKey()
    end
end

function HotKeyView:onShortcutBtnClickedHandler(button)
    self.selectHotKeyIndex = button.index
    self:removeShortcut(button.index)
    self:updateShortcutKey()
end


function HotKeyView:onSkillDragEndedHandler(button, target)
    local releasePos = cc.p(target:getPosition())
    releasePos = self.hotkeyLayer:convertToNodeSpace(releasePos)
    local descItem = nil
    for i, v in ipairs(self.shortcutItems) do
        if not tolua.isnull(v) and cc.rectContainsPoint(v:getBoundingBox(), releasePos) then
            descItem = v
            break
        end
    end
    if descItem then
        if not descItem:isEnable() then
            ui.showTip("键位未解锁")
            return
        end
        
        local srcModel = button:getModel()
        if self:isSkillSettable(srcModel, descItem.index) then
            -- 删除键位上相同技能
            for i, v in ipairs(self.shortcutItems) do
                local sid = SettingModel:getSystemSkillkeyByIndex(i)
                if sid and sid ~= 0 and sid == srcModel.id then
                    self:removeShortcut(i)
                    break
                end
            end
            self:removeShortcut(descItem.index)
            self:setShortcut(descItem.index, button:getModel().id)
            self:updateShortcutKey()
        end
    end
end


function HotKeyView:onShortcutDragEndedHandler(button, target)
    local releasePos = cc.p(target:getPosition())
    releasePos = self.hotkeyLayer:convertToNodeSpace(releasePos)
    local descItem = nil
    for i, v in ipairs(self.shortcutItems) do
        if not tolua.isnull(v) and cc.rectContainsPoint(v:getBoundingBox(), releasePos) then
            descItem = v
            break
        end
    end

    if descItem then
        if not descItem:isEnable() then
            ui.showTip("键位未解锁")
            return
        end
        if descItem.index == button.index then
            yzjprint("放回到原键位")
            return
        end
        
        local srcModel = button:getModel()
        if srcModel then
            if self:isSkillSettable(srcModel, descItem.index) then
                -- 删除键位上相同技能
                for i, v in ipairs(self.shortcutItems) do
                    local sid = SettingModel:getSystemSkillkeyByIndex(i)
                    if sid and sid ~= 0 and sid == srcModel.id then
                        self:removeShortcut(i)
                        break
                    end
                end
                -- 交换位置
                local descModel = descItem:getModel()
                self:setShortcut(descItem.index, srcModel.id)
                if descModel then
                    yzjprint(descItem.index, srcModel.id, "<====>", button.index, descModel.id)
                    self:setShortcut(button.index, descModel.id)
                end

                self:updateShortcutKey()
            end
        else
            gprint("键位槽与技能槽数据不对应")
        end
    else
        self:removeShortcut(button.index)
        self:updateShortcutKey()
    end

    -- for i = 1, 8 do
    --     local sid = SettingModel:getSystemSkillkeyByIndex(i)
    --     yzjprint("==after == i ,sid = ", i, sid)
    -- end
end


function HotKeyView:isSkillSettable(model, destIndex)
    local srcType = model.type
    local srcId = model.id
    -- yzjprint(srcType, destIndex)

    if not DRAG_MODE then
        if self.curState ~= STATE_SET then
            yzjprint("该界面状态下不可点")
            return
        end

        if not self.selectHotKeyIndex then
            ui.showTip("先选择下方快捷键位")
            return
        end

        local isExist = false
        for i = 1, 8 do
            local sid = SettingModel:getSystemSkillkeyByIndex(i)
            if sid ~= 0 and sid == srcId then
                isExist = true
                break
            end
        end

        if isExist then
            ui.showTip("已存在相同的" .. (srcType == 2 and "道具" or "技能"))
            return
        end
    end

    if srcType == 1 and (7 <= destIndex and destIndex <= 8) then --技能
        ui.showTip("技能只能放置在1~6键")
        return
    end

    if srcType == 2 and (1 <= destIndex and destIndex <= 6) then --道具
        ui.showTip("道具只能放置在7、8键")
        return
    end
    return true
end


function HotKeyView:onResetHandler(button)
    local alertView
    local function onCancelHandler()  --自动寻路按钮点击回调                            
        ui.removeSelf(alertView)
    end 

    local function onConfirmHandler() --立刻传送按钮点击回调
        self:updateShortcutKey(self.defaultList)
        self.isHotKeyChanged = true
        ui.showTip("还原默认成功")
    end 

    local alertView = ui.createAlertView(
        {{"取消", onCancelHandler}, {"确定", onConfirmHandler}},
        false,"sureBtn","是否还原为默认设置?", nil, true)
end

function HotKeyView:updateView(state)
	self.curState = state
    
    self.selectHotKeyIndex = nil

	updateViewFunc[self.curState](self)

    -- 图标变化
    self:updateShortcutKey()
end


updateViewFunc[STATE_VIEW] = function(self)
	self.resetBtn:setGrey(false)

    if not tolua.isnull(self.setBtn) then
    	self.setBtn:setString("设置快捷键")
    	self.setBtn:onClick(self, function()
    		self:updateView(STATE_SET)
    	end)
    end
end


updateViewFunc[STATE_SET] = function(self)
    -- 选中图标
    for i = 1, 8 do
        local sid = SettingModel:getSystemSkillkeyByIndex(i)
        if sid == 0 then
            self.selectHotKeyIndex = i
            break
        end
    end

	self.resetBtn:setGrey(true)

    if not tolua.isnull(self.setBtn) then
    	self.setBtn:setString("保存")
    	self.setBtn:onClick(self, function()
    		self:updateView(STATE_VIEW)

            if self.isHotKeyChanged then
                yzjprint("==== isHotKeyChanmged true")
                Dispatcher.dispatchEvent(EventType.REQUEST_SYSTEM_CONFIG_CHANGE)
            else
                yzjprint("==== isHotKeyChanged false")
            end
            ui.showTip('技能快捷键保存成功！')
    	end)
    end
end



return HotKeyView

