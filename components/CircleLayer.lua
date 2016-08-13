----------------------------------------
-- YuZhenjian
-- 2015年5月13日
-- 半圆的容器
----------------------------------------

local tClass = class("CircleLayer", function() return ui.newNode() end)

local createCell

-- viewSize界面大小
-- cellSize 节点大小
-- totalNum 是所有节点(cell)数
-- 使用示例:
--[[
local circleLayer = require("ui/CircleLayer").new(cc.size(280, 480), cc.size(142, 142), 7)
circleLayer:setCreateCallback(function(cell, index)end)
circleLayer:setSelectCallback(function(cell, index)end)
circleLayer:selectIndex(1)
--]]

function tClass:ctor(viewSize, cellSize, totalNum)
    viewSize = viewSize or cc.size(400, 400)
    self.viewSize = viewSize
    self:setContentSize(viewSize)
        
    self.totalNum = totalNum or 1
    self.cellSize = cellSize or cc.size(100, 100)
    self.createFunc = function() gprint("未实现createCallback回调") end
    self.selectCallback = function() gprint("未实现selectCallback回调") end
    
    self.centerPos = cc.p(0, viewSize.height / 2)   -- 中心点
    self.selectPos = cc.p(viewSize.width - cellSize.width / 2, viewSize.height / 2)  -- 初始点
    
    self.cells = {}
    
    -- 设置触摸
    helper.ccSetTouchEnable(self, {
        eventBegin = handler(self, self.onTouchBegan),
        eventEnd = handler(self, self.onTouchEnded),
        isSwallow = true
    })
    
    -- 用于超出范围不可点击
    self.scrollView, self.container = ui.newScrollView(self.viewSize)
    self.scrollView:setTouchEnabled(false)
    self.scrollView:setContentSize(self.cellSize)
    self.scrollView:ignoreAnchorPointForPosition(false)
    self.scrollView:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.scrollView)
end

-- callback传入参数为：cell, index
function tClass:setCreateCallback(callback)
    self.createCallback = callback
end

-- callback传入参数为：cell, index
function tClass:setSelectCallback(callback)
    self.selectCallback = callback
end

function tClass:selectIndex(index)
    if (index < 1) or (index > self.totalNum) then
        gprint("选中的index超出范围 (1 - " .. self.totalNum .. ")")
        return
    end
    
    self.currentIndex = index
    
    for i = 1, self.totalNum, 1 do
        createCell(self, i)
    end
    
    -- 选中
    if not tolua.isnull(self.cells[self.currentIndex]) then
        self.selectCallback(self.cells[self.currentIndex], self.currentIndex)
    end
end

-- 下一项
function tClass:selectNextIndex()
    self:selectIndex(self.currentIndex and self.currentIndex + 1 or self.totalNum)
end

-- 上一项
function tClass:selectLastIndex()
    self:selectIndex(self.currentIndex and self.currentIndex - 1 or 1)
end

function tClass:getScrollView()
    return self.scrollView
end


function createCell(self, index)
    local cell = self.cells[index]
    if tolua.isnull(cell) then
        --        cell = ui.newLayer(cc.c4b(math.random(255), math.random(255), math.random(255), 80))
        cell = ui.newLayer()
        self.cells[index] = cell

        cell:setContentSize(self.cellSize)
        cell:ignoreAnchorPointForPosition(false)
        cell:setAnchorPoint(cc.p(0.5, 0.5))
        self.container:addChild(cell)

        local label = gui.newLabel(index, ui.color.red, 26)
        ui.addChildEx(label, cell)

        self.createCallback(cell, index) -- 创建回调函数

        self:adjustPositionNoDelay(index) -- 调整位置
    else
        self:adjustPosition(index)-- 调整位置
    end
    return cell
end

local angleConfig = {
    [-2] = 112,
    [-1] = 56,
    [0] = 0,
    [1] = -56,
    [2] = -112,
}
local function getAngleByOffsetIndex(offsetIndex)
    offsetIndex = offsetIndex < -2 and -2 or offsetIndex
    offsetIndex = offsetIndex > 2 and 2 or offsetIndex
    return angleConfig[offsetIndex]
end

local function getPositionByIndex(self, index)
    local offsetIndex = index - self.currentIndex
    local angle = getAngleByOffsetIndex(offsetIndex)
    local newPos = cc.pRotateByAngle(self.selectPos, self.centerPos, math.angle2radian(angle))

    return newPos
end

--  位置调整
function tClass:adjustPositionNoDelay(index)
    local cell = self.cells[index]
    if tolua.isnull(cell) then
        return
    end
    cell:setPosition(getPositionByIndex(self, index))
end

function tClass:adjustPosition(index)
    local cell = self.cells[index]
    if tolua.isnull(cell) then
        return
    end
    local newPos = getPositionByIndex(self, index)
    cell:stopAllActions()
    
    cell:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.2, newPos),
        cc.CallFunc:create(function()
            if not tolua.isnull(cell) then
                cell:setPosition(getPositionByIndex(self, index))
            end
        end)
    ))
end


---  以下是触摸事件回调
function tClass:onTouchBegan(touch, event)
    if helper.ccIsClickInTarget(self, touch) then
        local location = touch:getLocation()
        self.beganPosition = self:convertToNodeSpace(location)
        return true
    end
    return false
end

function tClass:onTouchEnded(touch, event)
    if self.beganPosition then
        local location = touch:getLocation()
        local endedPosition = self:convertToNodeSpace(location)
        local offsetPos = cc.pSub(endedPosition, self.beganPosition)
        
        if offsetPos.y < -30 then --            gprint("向上滑动")
            self:selectLastIndex()
        elseif offsetPos.y > 30 then --            gprint("向下滑动")
            self:selectNextIndex()
        end
    end
end


return tClass