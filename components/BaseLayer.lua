--BaseLayer.lua
local tClass =  class("BaseLayer",function()
    return cc.Layer:create()
end)


function tClass:ctor()
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end


function tClass:onEnter()
end


function tClass:onExit()
end


-- 添加吞噬类型的触摸事件
function tClass:addTouch()
    -- if not param then
    --     self.listener = helper.addTouch({node = self, swallow = true})
    -- else
        self.listener = helper.addTouch({node = self, typeName = "OneByOne", swallow = true, prority = 0})
    -- end
end


function tClass:setSwallow(value)
    if self.listener then
        helper.setSwallow(self.listener, value)
    end
end


function tClass:setModal(value)
    self.modal = value
    if self.modal then
        self:setSwallow(value)
    end
end


function tClass:onTouchBegan(touch, event)
    if self.modal then
        return true
    end

    return helper.isTouch(self, touch)
end


function tClass:onTouchMoved(touch, event)
    local isTouch = helper.isTouch(self, touch)
    return isTouch
end


function tClass:onTouchEnded(touch, event)
    local isTouch = helper.isTouch(self, touch)
    return isTouch
end


return tClass