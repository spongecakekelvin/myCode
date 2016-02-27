------------------------------------------------------
--作者:   YuZhenjian
--日期:   2016年1月12日
--描述:   自动增长高度的子控件 (for UIFoldingMenu)
------------------------------------------------------
local FoldingMenuItem = class("FoldingMenuItem", function() return cc.Node:create() end)


--[[
创建 FoldingMenuItem.new(parent)
- parent 可选， 同样为FoldingMenuItem

+ addNode(node) 添加内容
    addNode后会调用parent的以下接口
     parent:updateSize() 刷新控件大小
     parent:updateBaseNode() 内容位置调整
]]--

function FoldingMenuItem:ctor(parent)
    self.parent = parent
    self.children = {}
    self.width = 0
    self.height = 0
    self.baseNode = cc.Node:create()
    self:addChild(self.baseNode)
end

function FoldingMenuItem:addNode(node)
    local size = node:getContentSize()
    if self.width == 0 then
        self.width = size.width
    end

    self.children[#self.children + 1] = node
    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(cc.p(0, 1))
    node:setPosition(cc.p(0, 0 - self.height))
    self.baseNode:addChild(node)

    self.height = self.height + size.height
    self:setContentSize(cc.size(self.width, self.height))
    
    self:updateBaseNode()

    if self.parent and self.parent.updateSize then
        self.parent:updateSize()
        self.parent:updateBaseNode()
    end
end

function FoldingMenuItem:removeAll()
    self.baseNode:removeAllChildren()
    self.children = {}
    self.width = 0
    self.height = 0
    self:setContentSize(cc.size(0, 0))

    if self.parent and self.parent.updateSize then
        self.parent:updateSize()
        self.parent:updateBaseNode()
    end
end


function FoldingMenuItem:updateSize()
    local height = 0
    local width = nil
    local posList = {}
    local num = #self.children
	for i, node in ipairs(self.children) do
        local size = node:getContentSize()
        if not width then
            width = size.width
        end
        posList[i] = cc.p(0, -height)
        height = height + size.height
    end

    for i, node in ipairs(self.children) do
        node:setPosition(posList[i])
    end

    self.width = width
    self.height = height
    self:setContentSize(cc.size(width, height))
end

function FoldingMenuItem:updateBaseNode()
    self.baseNode:setPosition(0, self:getContentSize().height)
end


function FoldingMenuItem:getChildren()
    return self.children
end

return FoldingMenuItem