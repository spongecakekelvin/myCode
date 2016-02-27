-- BasePanel.lua
local tClass =  class("BasePanel", ui.BaseLayer)

-- bgSize, bgImg, closeImg
function tClass:ctor(bgSize, bgImg, closeImg)
    tClass.super.ctor(self)
    -- 添加触摸
    self:addTouch()

    self:setModal(false)
    
    -- 背景
    if bgImg ~= false then
        self:setBgImg(bgImg, bgSize)
    else
        if bgSize then
            self:setContentSize(bgSize)
            self.size = bgSize
        end
    end
    
    if closeImg ~= false then
        -- 关闭按钮 (false 不创建, nil默认)
        self:addCloseBtn(closeImg)
    end
    
    -- 测试用
    -- local layer = ui.newLayer(cc.c4b(255, 0, 0, 80))
    -- layer:setContentSize(self.size)
    -- self:addChild(layer)
end

function tClass:onEnter()
    tClass.super.onEnter(self)
end

function tClass:onExit()
    tClass.super.onExit(self)

    -- 热更新
    if GameConfig.isDebug and self.__cpath then
        helper.reload(self.__cpath)
    end
end

function tClass:close()
    if not ViewManager or not ViewManager.closeView(self.__cname) then
        self:removeFromParent()
    end
end



function tClass:onTouchBegan(touch, event)
    local ret = tClass.super.onTouchBegan(self, touch, event)
    self.isBeganIn = helper.isTouch(self, touch)
    return ret
end

function tClass:onTouchEnded(touch, event)
    local ret = tClass.super.onTouchEnded(self, touch, event)
    self.isBeganIn = false

    return ret
end


function tClass:setBgImg(bgImg, bgSize)
    helper.remove(self.bgNode)
    
    local bgNode
    if not bgImg then
        if not bgSize then
            bgSize = cc.size(640, 400)
        end
        bgImg = "res/common/bg_1.png"
        bgNode = ui.new9Spr(bgImg, bgSize)
    elseif bgSize then
        bgNode = ui.new9Spr(bgImg, bgSize)
    else
        bgNode = ui.newSpr(bgImg)
        bgSize = bgNode:getContentSize()
    end
    
    self:setContentSize(bgSize)
    self.size = bgSize
    
    if bgNode then
        self:addChild(bgNode, -90)
        ui.align(self, bgNode)
        self.bgNode = bgNode
    end
end


function tClass:setTitle(text)
    if null(self.titleBg) then
        local bgSpr = ui.newSpr("common/title_bg_1.png")
        self.titleBg= bgSpr
        ui.align(self, bgSpr, 0.5, 1)
        self:addChild(bgSpr, 30)
        ui.setOffset(bgSpr, 0, -30)
    end
    
    helper.remove(self.titleLabel)

    if text then
        local titleLabel = ui.newLabel(text)
        self.titleLabel = titleLabel
        ui.align(self.titleBg, titleLabel)
        self.titleBg:addChild(titleLabel)
    end
end

-- 关闭按钮
function tClass:addCloseBtn(closeImg)
    helper.remove(self.closeBtn)

    local btn = ui.newButton(nil, function() self:close() end, closeImg or "res/common/btn_close.png")
    self.closeBtn = btn
    self:addChild(btn, 99)
    ui.align(self, btn, 1, 1, cc.p(0.5, 0.5), -17, -17)
end


return tClass