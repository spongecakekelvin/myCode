------------------------------------------------------
--作者:	Yzj
--日期:	2016年2月18日
--描述:	check in
------------------------------------------------------
local BaseClass = ui.BaseLayer
local CheckInView = class("CheckInView",BaseClass)
local CheckInModel = CheckInModel:getInstance()
local checkinIds = gameconfig.checkinIds
local checkinVO = gameconfig.checkinVO


------------------------------------------------------
--界面初始化
------------------------------------------------------
function CheckInView:ctor(param)
	if not ui.addPlist("allPlist/checkIn.plist") then return end
	reloadLua("gamecore/common/DateUtil")
	BaseClass.ctor(self)
	self.param = param or {}
	self.layout = ui.newLayoutUtilYzj("CheckInView", false)
end


function CheckInView:onEnter()
	ui.addChildAuto(self.layout, self, ui.newSpr("#checkIn/bg.png"), "bg")
	ui.addChildAuto(self.layout, self, ui.newSpr("#checkIn/yue.png"), "yue")

	local date = DateUtil.getDate()
	self.yueLabel = ui.newLabelAtlas(date.month, "number/checkinnum_yue.png", 14, 21, string.byte('0'))
	ui.addChildAuto(self.layout, self, self.yueLabel, "yueLabel", 1, 0)

	self.timesLabel = ui.newLabelAtlas(0, "number/checkinnum_times.png", 21, 31, string.byte('0'))
	ui.addChildAuto(self.layout, self, self.timesLabel, "timesLabel", 0, 0)

	self:createCanlendar()

	local labels = {}
	for i, v in ipairs(checkinIds) do
		labels[i] = "签到" .. v .. "次"
	end
	self.tabbar = ui.UITabBar.new({
        labels = labels,
        images = {off = "#common/blank.png", on = "#common/tab_light.png"},
        -- btnNameImgs = imgTab,
        direction = ui.UITabPanel.DIRECTION_HORIZONTAL,
        font_size = 26,
        unselectColor = ui.color.yellow,
        btn_size = cc.size(136, 34),
        -- defaultSelected = self.index,
    })
    self.tabbar:setContentSize(400, 100)
    self.tabbar:onButtonSelectChanged(nil, function(event)
        self:changeTab(self.tabbar:getSelectedIndex())
    end)
    -- self.tabbar:enable(false)
    ui.addChildAuto(self.layout, self, self.tabbar, "tabbar", 0, 0)

	self.checkInBtn = ui.newRed2Button("签到")
	self.checkInBtn:onClick(self, self.onCheckInHandler)
	ui.addChildAuto(self.layout, self, self.checkInBtn, "checkInBtn")


	self.rewardBtn = ui.newRed2Button("领取奖励")
	self.rewardBtn:onClick(self, self.onRewardHandler)
	ui.addChildAuto(self.layout, self, self.rewardBtn, "rewardBtn")



	Dispatcher.dispatchEvent(EventType.REQUEST_CHECKIN_QUERY, {op_type = 0})

	Dispatcher.addEventListener(EventType.UPDATE_CHECKIN_VIEW, self.updateView, self)
end


function CheckInView:onExit()
	ui.removePlist("allPlist/checkIn.plist")
	Dispatcher.removeEventListener(EventType.UPDATE_CHECKIN_VIEW, self.updateView)
end


function CheckInView:onCloseClickedHandler()
    Helper.throwEvent(EventType.OPEN_CLOSE_CHECKIN_VIEW, {tag = "close"})
end


function CheckInView:changeTab(index)
	ui.removeSelf(self.rewardLayer)
	local checkId = checkinIds[index]
	if not checkId then 
		return
	end
	local vo = checkinVO[checkId]
	if not vo then
		return
	end

	local size = cc.size(634, 76)
	local layer = ui.newLayer(size)
	-- local layer = ui.newLayer(size, cc.c4b(255, 0, 0, 80))
	self.rewardLayer = layer
	local x = 40
	for i = 1, 6 do
		local rewardid = vo["reward" .. i]
		local num = vo["num" .. i]

		if rewardid and rewardid > 0 then
		    local model = GoodsModel.new(tonumber(rewardid))
		    model.p_goods.num = num
		    if gameconfig.itemVO[rewardid] then 
		    	model.p_goods.bind = gameconfig.itemVO[rewardid].bind
		    end 
		    local goodsItem = GoodsItem.new(model,{isShowNum=true, dragEnable = false, clickEnable = true})
		    ui.addChild(layer, goodsItem, x, 40, 0.5, 0.5)
		    x = x + 100
		end
	end
    ui.addChildAuto(self.layout, self, self.rewardLayer, "rewardLayer")
end


local row, col = 6, 7
local w, h = 634 / col, 182 / row

function CheckInView:createCanlendar()
	local dateLayer = ui.newLayer(cc.size(w * col, h * row))--, cc.c4b(255, 255, 0, 80))

	self.dateItems = {}
	local x, y
	local index
	for j = 1, row do
		x = 0
		y = (row - j) * h
		for i = 1, col do
			index = (j - 1) * col + i
			self.dateItems[index] = self:createDateItem(index)
			ui.addChild(dateLayer, self.dateItems[index], x, y, 0, 0)
			x = x + w
		end
	end
	ui.addChildAuto(self.layout, self, dateLayer, "dateLayer")

	-- 下面是日期数据
	local date = DateUtil.getDate()

	local preMonth, preMonthYear = DateUtil.getPreMonth(date.month, date.year)
	local preMonthDays = DateUtil.getDays(preMonthYear, preMonth)

	local curMonthDays = DateUtil.getDays(date.year, date.month)
	local firstDayDate = DateUtil.getDate(DateUtil.getSecondsByDate({
		year = date.year, month = date.month, day = 1	
	}))

	local firstWeekDay = firstDayDate.wday

	self.today = date.day
	self.firstWeekDay = firstWeekDay

	for i = 1, firstWeekDay - 1 do
		self.dateItems[i]:updateNum(preMonthDays - firstWeekDay + i + 1, false)
	end

	for i = 1, curMonthDays do
		self.dateItems[firstWeekDay + i - 1]:updateNum(i, true)
	end

	self.dateItems[firstWeekDay + date.day - 1]:addToday()

	local index = 1
	for i = curMonthDays + firstWeekDay, 42 do
		self.dateItems[i]:updateNum(index, false)
		index = index + 1
	end

end

function CheckInView:createDateItem(index)
	local item = ui.newNode(cc.size(w, h))
	
	item.bg = ui.newSpr("#checkIn/grid.png")
	item:addChild(item.bg)
	ui.alignCenter(item, item.bg)

	item.label = ui.newLabel("")
	item:addChild(item.label)
	ui.alignCenter(item, item.label)

	item.updateNum = function(item, num, state)
		item.label:setString(num)
		if state then
			item.bg:setOpacity(255)
			item.label:setOpacity(255)
		else
			-- 无效
			item.bg:setOpacity(0.6 * 255)
			item.label:setOpacity(0.6 * 255)
		end
	end

	item.addMark = function(item)
		ui.removeSelf(item.mark)
		item.mark = ui.newSpr("#checkIn/mark.png")
		item:addChild(item.mark, 1)
		ui.alignCenter(item, item.mark)
	end

	item.addToday = function(item)
		if tolua.isnull(item.today) then
			item.today = ui.newSpr("#checkIn/jin.png")
			item:addChild(item.today, 1)
			ui.alignCenter(item, item.today, 0, 1, 0, 1)
		end
	end

	return item
end


function CheckInView:updateView()
	local data = CheckInModel:getData()
	-- data.reward_id = 0
	self.reward_id = data.reward_id

	for i, v in ipairs(data.checks) do
		self.dateItems[self.firstWeekDay + v - 1]:addMark()
	end

	local hasChecked = false
	for i, v in ipairs(data.checks) do
		if self.today == v then
			hasChecked = true
			break
		end
	end

	if hasChecked then
		self.checkInBtn:setString("已签到")
		self.checkInBtn:setGrey(true)
	end
	
	local curindex
	-- 签到奖励
	local nextId = CheckInModel:getNextRewardId()
	if nextId then
		for i, id in ipairs(checkinIds) do
			if nextId == id then
				curindex = i
				break
			end
		end
	end

	local canReward = false
	if curindex then
		self.tabbar:onSetButtonSelected(curindex)
		canReward = (self.reward_id < checkinIds[curindex] and checkinIds[curindex] <= #data.checks)
	end

	printTable(data, yzjprint)
	-- yzjprint(" canReward = ", tostring(canReward), self.reward_id, checkinIds[curindex], curindex, #data.checks)
	self.rewardBtn:setGrey(not canReward)

	self.timesLabel:setString(#data.checks)
end


function CheckInView:onCheckInHandler(button)
	Dispatcher.dispatchEvent(EventType.REQUEST_CHECKIN_QUERY, {op_type = 1})
end


function CheckInView:onRewardHandler(button)
	-- var curid:int = RewardHallModule.getInstance().rewardid;
	-- 		for(var i:int=0;i<ConfigManager.checkinIds.length;i++){
	-- 			if(curid<ConfigManager.checkinIds[i] && ConfigManager.checkinIds[i]<=RewardHallModule.getInstance().checkins.length){
	-- 				RewardHallModule.getInstance().requestCheckInReward(ConfigManager.checkinIds[i]);
	-- 				break;
	-- 			}
	-- 		}
	local nextId = CheckInModel:getNextRewardId()
	if not nextId then
		ui.showTip('不可领取')
		return
	end
	Dispatcher.dispatchEvent(EventType.REQUEST_CHECKIN_REQWRD, {reward_id = nextId})
end

return CheckInView
