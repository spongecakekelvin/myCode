-----------------------------------------
---作者：wy
---日期：2014/10/30
---描述：主界面右下方的技能按钮
-----------------------------------------
local BaseClass = ui.BaseLayer
local MainUIIconsView = class("MainUIIconsView",BaseClass)
require("gamecore/modules/mainUI/MainUIModel")
local MainUIModel = MainUIModel:getInstance()


-- 获得节点相对于屏幕（ tipLayer）的坐标点
local function getLocation(target, anchorPoint, size)
    anchorPoint = anchorPoint or cc.p(0.5, 0.5)
    size = size or target:getContentSize()
    local pos = cc.p(size.width * 0.5, size.height * 0.5)

    
    pos = target:convertToWorldSpace(pos)
    pos = LayerManager.topLayer:convertToNodeSpace(pos)
    
    return pos
end


function MainUIIconsView:ctor(param)
    BaseClass.ctor(self,true,true,false)

    local target = param.target
    local info = param.info
    -- printTable(info, yzjprint)

    local pos = getLocation(target)

    local num = #info.childrenConfig
    local size = cc.size(num * 85, 85)
    local targetSize = target:getContentSize()

    local layer = ui.newLayer(size, cc.c4b(255, 255, 0, 80))
    self.layer = layer
    layer:ignoreAnchorPointForPosition(false)
    layer:setPosition(cc.p(0.5, 0))
    layer:setPosition(pos.x, pos.y + targetSize.height)
    self:addChild(layer)

    local gap = size.width / num
    local gap2 = gap / 2

    for i, config in ipairs(info.childrenConfig) do
        local funcBtn = ui.newCustomButton(config.getIconPathFunc())
        funcBtn:onClick(nil, function()
            if config.openlv and config.openlv > DataGlobal.role.attr.level then
                ui.showTip(config.name .. "系统" .. config.openlv .. "开放！") 
                return  
            end
            config.clickEventFunc()
            Dispatcher.dispatchEvent(EventType.OPEN_MAINUI_ICONS_VIEW,{tag="close"})
        end)
        funcBtn:setPosition(gap2 + (i - 1) * gap, 50)
        layer:addChild(funcBtn)

        local label = ui.newLabel(config.name, 26, ui.color.green)
        label:setStroke()
        label:setPosition(38, 30)
        funcBtn:addChild(label, 100)
    end

end

function MainUIIconsView:onEnter()
    BaseClass.onEnter(self)
end

function MainUIIconsView:onExit()
    BaseClass.onExit(self)
end


function MainUIIconsView:onTouchBegan(touch, event)
    local location = touch:getLocation()
    local isIn = Helper.isClickInTarget(self.layer, location) 
    if isIn then
        return true
    end
    ui.removeSelf(self)
    return true
end

-- function MainUIIconsView:onTouchMoved(touch, event)
--    local ret = BaseClass.onTouchMoved(self, touch, event)
--    return ret
-- end

-- function MainUIIconsView:onTouchEnded(touch, event)
--    local ret = BaseClass.onTouchEnded(self, touch, event)
--    return ret
-- end

return MainUIIconsView