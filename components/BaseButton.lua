-- 基础按钮类
local tClass =  class("BaseButton", ui.BaseLayer)

function tClass:ctor(name, callback, imagePath, size)
    tClass.super.ctor(self)
    -- print("base button ctor")
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self.beganCallback = nil
    self.endedCallback = nil
    self.movedCallback = nil

    self.callback = callback
    self.endedCallback = self.callback
    self.name = name

    if imagePath then
        if not size then
            self.buttonSpr = ui.newSpr(imagePath)
            self.size = self.buttonSpr:getContentSize()
        else
            self.buttonSpr = ui.new9Spr(imagePath, size)
            self.size = size
        end
    elseif size then
        self.size = size
    else
         Log.e("创建按钮的参数imagePath和size不能同时为nil")
         return
    end

    self:setContentSize(self.size)
    if self.buttonSpr then
        ui.align(self, self.buttonSpr)
        self:addChild(self.buttonSpr)
    end

    -- local layer = ui.newLayer(cc.c4b(255, 255, 255, 80), cc.size(400, 400))
    -- self:addChild(layer)
    -- ui.align(self, layer)
    
    -- 添加吞噬类型的触摸事件
    self:addTouch()
    
    -- 按钮文字
    if self.name and self.name ~= "" then
        self.label = ui.newLabel(name)
        ui.align(self, self.label)
        self:addChild(self.label)
    end
end


function tClass:onEnter()
    tClass.super.onEnter(self)  
    -- print("base button on enter")
end

function tClass:onExit()
    tClass.super.onExit(self)
    -- print("base button on exit")
end

function tClass:onTouchBegan(touch, event)
    local isTouch = tClass.super.onTouchBegan(self, touch, event)
    if isTouch then
        if not tolua.isnull(self) then
            self.scale = self.scale or self:getScaleX()
            self:runAction(cc.ScaleTo:create(0.05, self.scale*1.1))
        end

        if self.beginCallback then
            self.beginCallback(self, touch, event)
        end
    end
    
    return isTouch
end

function tClass:onTouchMoved(touch, event)
    local isTouch = tClass.super.onTouchMoved(self, touch, event)
    return isTouch
end


function tClass:onTouchEnded(touch, event)
    -- print("touchEnded ...")
    if not tolua.isnull(self) then
        self:runAction(cc.ScaleTo:create(0.05, self.scale or 1))
    end
    local isTouch = tClass.super.onTouchEnded(self, touch, event)
    if isTouch then
        if self.endedCallback then
            self.endedCallback(self, touch, event)
        end
    end
    return isTouch
end


return tClass