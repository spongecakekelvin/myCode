------------------------------------------------------
--作者:   YuZhenjian
--日期:   2016年1月12日
--描述:   折叠下拉菜单
------------------------------------------------------
local UIFoldingMenu = class("UIFoldingMenu", function() return cc.Node:create() end)

local FoldingMenuItem = require("gamecore/ui/FoldingMenuItem")

local maxH = 2048

-- 1折叠 2展开
local state_collapse = 1
local state_expand = 2

local IMG = {
	[state_collapse] = "#common/menuTab1.png",
	[state_expand] = "#common/menuTab2.png",
}


--[[
接口
+ selectTab(tabIndex) 选中标签
+ getItemList() 返回当前标签下的全部节点
+ getState() 当前节点的状态（1折叠 2展开）

----
options所需参数：
viewSize 菜单大小
itemSize 每个节点大小
tabList 标签名字列表

-- 回调：
options.createItemHandler 创建节点函数，ps:需要返回节点实例, 节点size用于排版
options.getItemNumHandler 返回每个标签下的节点数
options.expandHandler （可选）标签展开后的回调

示例： CastingView.lua
	self.menu = ui.FoldingMenu.new({
		viewSize = cc.size(292, 489), 
		itemSize = cc.size(292, 58),
		tabList = btn_map,
		-- 获得标签下的item数量
		getItemNumHandler = function(menu, tabIndex)
			self:getModels(tabIndex)
			return #self.models
		end,
		-- 创建item函数
    	createItemHandler = function(menu, tabIndex, itemIndex)
    		self:getModels(tabIndex)
    		return self:createItem(itemIndex)
    	end,
    	-- 展开回调
    	expandHandler = function(menu, tabIndex, defaultItemIndex)
    		self:getModels(tabIndex)
    		itemClickedHandler(self, defaultItemIndex or 1)
    	end
	})
	ui.addChildAuto(self.layout, self, self.menu, "menu", 0, 0)
	self.menu:selectTab(1)

TODO:
	加上滚动条、折叠展开动作
]]--

function UIFoldingMenu:ctor(options)
    self.options = options or {}
    self.viewSize = options.viewSize
    self.itemSize = options.itemSize
    self.tabList = options.tabList
    self.createItemHandler = options.createItemHandler
    self.getItemNumHandler = options.getItemNumHandler
    self.expandHandler = options.expandHandler

 	-- printTable(options)

    self:setContentSize(self.viewSize)

    -- testing:
    -- local layer = ui.newLayer(self.viewSize, cc.c4b(255, 255, 0, 80))
    -- self:addChild(layer)

	-- FoldingMenuItem = reloadLua("gamecore/ui/FoldingMenuItem")
    self:createView()
    self:createContent()

end

function UIFoldingMenu:selectTab(tabIndex)
	self:onTabClickedHandler(tabIndex)
end

function UIFoldingMenu:createView()
    self.scrollView = cc.ScrollView:create()
    self.baseContainer = FoldingMenuItem.new()

    self.scrollView:setViewSize(self.viewSize)
    self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scrollView:setContainer(self.baseContainer)
    self.scrollView:setTouchEnabled(true)

    ui.addChild(self, self.scrollView, 0, 0, 0, 0)
end

function UIFoldingMenu:updateLastState()
	for k, v in pairs(self.tabState) do
		self.lastState[k] = v
	end
end

function UIFoldingMenu:createContent()
    self.containerList = {}
    self.tabBtnList = {}
    self.tabState = {}
    self.lastState = {}

    for i, v in ipairs(self.tabList) do
    	local layer = ui.newLayer(self.itemSize)
    	-- local layer = ui.newLayer(self.itemSize, cc.c4b(math.random(255), math.random(255), math.random(255), 80))
    	self.tabState[i] = state_collapse

	 	local btn =  ui.UIButton.new({
	        images = {normal = IMG[self.tabState[i]]},
	        btnName = v,
	        font_size = 24,
	        color = ui.color.yellow,
	    })
	    btn:setSwallowTouches(false)
    	btn:onClick(self, self.onTabClickedHandler)
        btn.index = i

    	layer:addChild(btn)
    	ui.alignCenter(layer, btn)

    	self.baseContainer:addNode(layer)
    	-- 空的容器
        local container = FoldingMenuItem.new(self.baseContainer)
        self.baseContainer:addNode(container)

        -- printTable(self.baseContainer:getContentSize())

        self.tabBtnList[i] = btn
        self.containerList[i] = container
    end
    self:updateLastState()
end


function UIFoldingMenu:updateTabState(tabBtn, index)
	if self.tabState[index] == self.lastState[index] then
		return
	end
	tabBtn:changeBtnImg({normal = IMG[self.tabState[index]]})
end

function UIFoldingMenu:onTabClickedHandler(clickedBtn)
	local index
	if type(clickedBtn) == "number" then
		index = clickedBtn
		clickedBtn = self.tabBtnList[index]
	else
		index = clickedBtn.index
	end
	-- gprint(self.selectIndex, "click " .. tostring(index))

	if not clickedBtn then
		yzjprint("222222222222")
		return
	end

	if not self.selectIndex or self.selectIndex == index then
		self.tabState[index] = 3 - self.tabState[index]
		self:updateTabState(clickedBtn, index)
	else
		for i, btn in ipairs(self.tabBtnList) do
			self.tabState[i] = (i == index and state_expand or state_collapse)
			self:updateTabState(btn, i)
		end
	end
	-- printTable(self.lastState)
	-- printTable(self.tabState)

	self.lastSelectIndex = self.selectIndex
	self.selectIndex = index
	-- gprint("==================", self.lastSelectIndex, self.selectIndex)

	if self.lastSelectIndex ~= self.selectIndex then
		self:updateItems(self.lastSelectIndex)
	end
	self:updateItems(self.selectIndex)

	self:updateLastState()

	if self.expandHandler then
		if self:getState(self.selectIndex) == state_expand then -- 当前展开才回调
			self:expandHandler(self.selectIndex)
		end
	end
end

function UIFoldingMenu:updateItems(index)
	if not index then
		return
	end

	local state = self.tabState[index]
	local lastState = self.lastState[index]

	if state == lastState then
		return 
	end

	local container = self.containerList[index]
	if state == state_collapse then
		container:removeAll()
	else
		for i = 1, self:getItemNumHandler(index) do
			local item = self:createItemHandler(index, i)
			container:addNode(item)
		end
	end

	self.scrollView:setContentOffset(self.scrollView:minContainerOffset())
end

function UIFoldingMenu:getItemList()
	local container = self.containerList[self.selectIndex]
	if container then
		return container:getChildren()
	end
end


function UIFoldingMenu:getState(tabIndex)
	return self.tabState[tabIndex]
end

return UIFoldingMenu