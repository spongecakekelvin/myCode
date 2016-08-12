--[[
--作者:   Yuzhenjian
--日期:   2016年8月12日
--描述:   通用可拖动的item

--初始化参数param(可选): size、bgPath、 model、text、 fontSize、 fontColor
--接口：
    :setModel{type, id}
    :getModel()
    -- 以下是回调 --
    :setDragEnabled(false)
    :setBeganCallback(callback)
    :setMovedCallback(callback)
    :setEndedCallback(handler(self, self.onShortcutBtnClickedHandler))
    :setDragEndedCallback(handler(self, self.onShortcutDragEndedHandler))
    :setDragBeganCallback(callback)
    :setUpdateIconCallback(self, model)

]]--
local BaseClass = require "gamecore/ui/uiBaseClasses/BaseLayer"
local DragItem = class("DragItem", BaseClass)

local scaleTime = 0.05

function DragItem:ctor(param)
    BaseClass.ctor(self, true, true)
    
    self.param = param or {}
    self.bgPath = self.param.bgPath or "#skill/skillBg.png"

    self.model = self.param.model
    self.noScale = false --是否需要放大
    self.size = self.param.size or cc.size(84, 84)
    self.delayTime = 0.2
    self.dragEnabled = true -- 是否可拖动

    -- self.beganCallback = function()end
    -- self.movedCallback = function()end
    self.endedCallback = function() if not self.dragEnabled then gprint("未实现endedCallback回调") end end
    
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    
    if self.bgPath then
        local spr = ui.newSpr(self.bgPath)
        spr:setLocalZOrder(-1)
        self.size = spr:getContentSize() -- 
        self:setContentSize(self.size)
        self:addChild(spr)
        ui.alignCenter(self, spr)

        if self.param.text then
            self.label = ui.newLabel(self.param.text, self.param.fontSize, self.param.fontColor)
            ui.setStroke(self.label, cc.c4b(0x0b, 0x19, 0x31, 0xff), 2)
            spr:addChild(self.label)
            ui.alignCenter(spr, self.label)
        end
    else
        self:setContentSize(self.size)
    end
    
    local layer = ui.newNode(self.size)
    self.contentLayer = layer
    self:addChild(layer)
    ui.alignCenter(self, layer)
    
    if self.model then
        self:setModel(self.model)
    end
end

function DragItem:onExit()
    if not tolua.isnull(self.dragTarget) then
        self.dragTarget:removeFromParent()
    end
    self:stopAllActions()
end

function DragItem:setBeganCallback(callback)
    self.beganCallback = callback
end

function DragItem:setMovedCallback(callback)
    self.movedCallback = callback
end

function DragItem:setEndedCallback(callback)
    self.endedCallback = callback
end

function DragItem:setDragEndedCallback(callback)
    self.dragEndedCallback = callback
end

function DragItem:setDragBeganCallback(callback)
    self.dragBeganCallback = callback
end

function DragItem:setUpdateIconCallback(callback)
    self.updateIconCallback = callback
end



function DragItem:setDragEnabled(state)
    self.dragEnabled = state
end

function DragItem:setModel(model)
    self.model = model
    
    self.contentLayer:removeAllChildren()
    self.icon = self:createIcon()
    if not tolua.isnull(self.icon) then
        self.contentLayer:addChild(self.icon)
        ui.alignCenter(self.contentLayer, self.icon)
    end
end

function DragItem:getModel()
    return self.model
end

function DragItem:createIcon()
    if self.model then
        local icon = ui.newSpr()
        if self.updateIconCallback then
            self.updateIconCallback(icon, self.model)
        end
        return icon
    end
end

function DragItem:hasModel()
    if self.model then
        return true
    end
    return false
end

function DragItem:updateDragTargetPositon(newPos)
    if not tolua.isnull(self.dragTarget) then
        newPos = newPos or self.beganPos
--        printTab(newPos)
        self.dragTarget:setPosition(newPos)
    end
end

-- 点击延时拖动的回调
function DragItem:dragDelayCallback()
    if not self.dragEnabled then
        -- yzjprint("不能拖拉")
        return
    end
    self:stopAllActions()
    
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(self.delayTime),
        cc.CallFunc:create(function()
            if not tolua.isnull(self) and tolua.isnull(self.dragTarget) and not tolua.isnull(self.icon) then
                self.dragTarget = self:createIcon()
                self.dragTarget:setScale(1.2)
                self:updateDragTargetPositon()
                self.icon:setOpacity(100)
                LayerManager.topLayer:addChild(self.dragTarget)
            end
        end)
    ))
end

function DragItem:onTouchBegan(touch, event)
    local isIn = BaseClass.onTouchBegan(self, touch, event)
    self.isBeganIn = isIn
    local location = touch:getLocation()
    
    self.beganPos = LayerManager.topLayer:convertToNodeSpace(location)
    
    if isIn then
        -- self.beganTime = os.clock()
        
        if self.beganCallback then
            self.beganCallback(self)
        end

        if self.model then
            self:dragDelayCallback()
        end
        
        if not self.noScale then
            self:runAction(cc.ScaleTo:create(scaleTime, 1.1))
        end

        self:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime), cc.CallFunc:create(function()
            if self.dragBeganCallback then
                self.dragBeganCallback(self)
            end
        end)))
        
    end
    return isIn
end

function DragItem:onTouchMoved(touch, event)
    BaseClass.onTouchMoved(self, touch, event)
    if not tolua.isnull(self.dragTarget) then
        self:updateDragTargetPositon(LayerManager.topLayer:convertToNodeSpace(touch:getLocation()))
    end
    
    if self.movedCallback then
        self.movedCallback(self)
    end
end

function DragItem:onTouchEnded(touch, event)
    -- BaseClass.onTouchEnded(self, touch, event)
    local location = touch:getLocation()
    local isIn = Helper.isClickInTarget(self, location)

    if isIn then
        if self.endedCallback then
            self.endedCallback(self)
        end
    end
    self:stopAllActions()
    if not tolua.isnull(self.dragTarget) then
        -- 拖动放开
        if self.dragEndedCallback then
            self.dragEndedCallback(self, self.dragTarget)
        end
        self.dragTarget:removeFromParent()
        if not tolua.isnull(self.icon) then
            self.icon:setOpacity(255)
        end
    end
    
    if self.isBeganIn then
        if not self.noScale then
            self:runAction(cc.ScaleTo:create(scaleTime, 1))
        end
        self.isBeganIn = false
    end
end



return DragItem