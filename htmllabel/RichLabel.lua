
--[[

	富文本标签
	---
	RichLabel基于Cocos2d-x 3.x + Lua

	**特性：**
	*   兼容项目组旧版本C++实现的Html控件
	*   多颜色字体、字体大小 <font face="font21" color ="#f39800">
	*   颜色格式支持 #000000、0x000000
	*   支持表情动画 <cs id="$34"/>
	*   支持文本属性(颜色，渐变颜色，字体大小)
	*   自动换行，支持换行符 '\n' 、 '<br/>'
	*   支持设置行间距，字符间距
	
	**示例：**

    if not ui.addPlist("allPlist/expression.plist") then return end
    local textlist  = {}
    textlist[#textlist + 1] = "CLICK <a href='http://example.com/'>here!</a>"
    textlist[#textlist + 1] = '奥斯卡的卷发洛杉矶佛按摩法<font face="font21" color ="#f39800">kkk<cs id="$34"/>hh</font>'
    textlist[#textlist + 1] = '<font face="font21" color ="#f39800">kkk<cs id="$34"/><cs id="$34"></cs>hh</font>'
    textlist[#textlist + 1] = '<font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">黑鳄甲虫</font><font face="font16" color="#ff0000">（0/15）</font><br/><font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">蛊晶蚊</font><font face="font16" color="#ff0000">（0/15）</font><br/>'
    textlist[#textlist + 1] = '<font face="font16">可制作5级攻击药<font color="#ffff00"><a face="font16" href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续<cs id="$01"/>时间24小时。<br/><font color="#9d1bd4">最高等级：15级</font></font>'
    textlist[#textlist + 1] = '可制作5级攻击药<font color="#ffff00"><a href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续时间24小时。<br/><font color="#9d1bd4">最高等级：15级</font>'
    textlist[#textlist + 1] = "<font color='#ebebeb' size='13'>使用<u><a href='event:get|57|1'><font color='#23e342' size='13'>VIP1大礼包</font></a></u>可获得</font>"
    textlist[#textlist + 1] = "死亡时立即原地满血复活"
    textlist[#textlist + 1] = "送<font color='#23e342'>绝版</font><font color='#d323e3'>神兵玉佩</font>、升阶丹、金砖、修为丹、海量钻石！"
    textlist[#textlist + 1] = "<font color='#23e342'>装备颜色：</font>  <font color='#ffffff'>白</font>-<font color='#00ff00'>绿</font>-<font color='#0066ff'>蓝</font>-<font color='#9000ff'>紫</font>-<font color='#ff7800'>橙</font>-<font color='#cc0000'>红</font>-<font color='#00fff0'>青</font>-<font color='#fe50a6'>粉</font>-<font color='#fffc00'>金</font>-<font color='#ffffff'>亮白</font>-<font color='#00ff00'>亮绿</font>-<font color='#0066ff'>亮蓝</font>-<font color='#9000ff'>亮紫</font>-<font color='#ff7800'>亮橙</font>-<font color='#cc0000'>亮红</font>-<font color='#00fff0'>亮青</font>-<font color='#fe50a6'>亮粉</font>-<font color='#fffc00'>亮金</font>"
    textlist[#textlist + 1] = "<font color='#23e342'>兑换说明：</font><br/><br/>1、每日可兑换<font color='#23e342'>20</font>次，每次消耗<font color='#23e342'>5000W</font>经验，兑换5000修为；<br/>2、兑换消耗：<font color='#23e342'>20W</font>绑定金币；<br/>3、VIP每日可领取增加兑换修为次数的<font color='#23e342'>修为兑换石</font>。"
    textlist[#textlist + 1] = "<font color='#FF00'><a href='event:OPEN_OPENSERVERACT_PANEL|3'> <u>详情点击查看 </u></a></font>"
    textlist[#textlist + 1] = "对狂战士增加攻击力126<br/><br/>圣器效果随圣器等级提高而提升<br/><br/>获取途径：<br/><font color='#23e342'>开服活动、累计充值</font><br/><font color='#23e342'>进阶返利、BOSS掉落</font><br/><font color='#23e342'>玩家分享</font>"
    textlist[#textlist + 1] = "abc<br/><br/><br/>defg"
    textlist[#textlist + 1] = '<font color="#16ffca" start_color="#16ffca" end_color="#ff42ff" >[真理手镯（右）]</font>'

    for i, text in ipairs(textlist) do
        local label = RichLabel.new{maxWidth = 370, fontSize = 22, lineSpace = 0, callback = function(id, name, href, x, y)
            yzjprint("==== RichLabel link touch!! ", id, name, href, x, y)
        end}
        self.testLabel = label
        label:setString(text)
        label:debugDraw()
        ui.addChild(self, label, 42 + i * 10, 153 + i * 10, nil, nil, 999)
    end

	---示例结束---


	** 默认属性 **
	self._default.dimensions = dimensions
	self._default.fontName = fontName
	self._default.fontSize = fontSize
	self._default.fontColor = fontColor
	self._default.lineSpace = linespace
	self._default.charSpace = charspace -undone

	**基本接口：**

	* setString - 设置要显示的富文本   
	* getSize - 获得Label的大小  
	* setMaxWidth - 设置宽度
	* setAnchorPoint - 设置宽度
	* debugDraw 调试模式，显示字体包围框

]]--

local CURRENT_MODULE = ...

require("gamecore/ui/richlabel/htmlparser")
local labelparser = htmlparser

local RichLabel = class("RichLabel", function()
    return cc.Node:create()
end)	

-- 文本的默认属性
RichLabel._default = {}

-- 属性
RichLabel._maxWidth = nil
RichLabel._currentWidth = nil
RichLabel._currentHeight = nil

-- 容器
RichLabel._containerNode = nil
RichLabel._allnodelist = nil
RichLabel._currentText = nil
RichLabel._parsedtable = nil
RichLabel._alllines = nil

RichLabel._animationCounter = nil

-- 共享解析器列表
local shared_parserlist = {}

-- 播放动画默认速度
local ANIM_WORD_PER_SEC = 15
local DEBUG_MARK = "richlabel.debug.drawnodes"
local expressionList = require "gamecore/config/ExpressionConfig"
local createExpressAnimation
local _expressionScale = 0.44
-- local _expressionScale = 1

--[[--
-   ctor: 构造函数
	@param: 
		params - 可选参数列表
		params.dimensions  - 默认的字体名称
		params.fontName - 默认字体大小
		params.fontSize - 默认字体颜色
		params.fontColor - Label最大宽度
		params.linespace - 行间距
		params.charspace - 字符间距 -- undone
]]
local checkFontSize
local checkC3b

function RichLabel:ctor(params)
	params = params or {}
	local fontName 	= params.fontName
	local fontSize 	= params.fontSize
	local fontColor = params.fontColor or cc.c3b(0xff, 0xff, 0xff)
	local dimensions = params.dimensions
	local maxWidth 	= params.maxWidth or 0
	local linespace = params.lineSpace or 0 -- 行间距
	local charspace = params.charSpace or 0 -- 字符距
	self._callback = params.callback

	-- 精灵容器
	local containerNode = cc.Node:create()
	-- local containerNode = ui.newLayer(cc.size(100, 20), cc.c4b(math.random(255), math.random(255), math.random(255), 40))
	self:addChild(containerNode)

	self._maxWidth = maxWidth > 0 and maxWidth or 99999
	self._containerNode = containerNode
	self._animationCounter = 0

	self._default = {}
	self._default.dimensions = dimensions
	self._default.fontName = fontName
	self._default.fontSize = fontSize
	self._default.fontColor = fontColor
	self._default.lineSpace = linespace
	self._default.charSpace = charspace

	-- 标签内容向右向下增长
	self:setAnchorPoint(cc.p(0, 0))
	-- 允许setColor和setOpacity生效
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
    containerNode:setCascadeOpacityEnabled(true)
    containerNode:setCascadeColorEnabled(true)
end

--[[--
-   setString: 设置富文本字符串
	@param: text - 必须遵守规范的字符串才能正确解析	
			<div fontcolor=#ffccbb>hello</div>
]]
function RichLabel:setString(text)
	text = text or ""
	-- 字符串相同的直接返回
	if self._currentText == text and self._lastMaxWidth == self._maxWidth then
		return
	end

	-- 若之前存在字符串，要先清空
	if self._currentText then
		self._allnodelist = {}
		self._parsedtable = {}
		self._alllines = {}
		self._containerNode:removeAllChildren()
	end

	self._currentText = text

	local containerNode = self._containerNode

	-- 普通字符
	if not string.find(text, "<.+>") then
		-- yzjprint("normal return !!!! ", text)
		self._allnodelist = {}
		self._alllines = {[1]={}}
		self._parsedtable = {[1] = {content = text, dimensions = self._default.dimensions}}
		
		local lines, maxwidth, maxheight = self:createLine_(containerNode, self._parsedtable, 1, 1)
		for i, node in ipairs(lines) do
			node:setPositionY(-maxheight)
			table.insert(self._alllines[1], node)
			table.insert(self._allnodelist, node)
		end
		--  调整高度
		self:updatePosition(maxwidth, maxheight)
		return
	end

	-- 转换字符串中的特定标签
	text = self:checkTags_(text)
	-- yzjprint("==== replaceTag text = ", text)


	-- 解析字符串，解析成为一种内定格式(表结构)，便于创建精灵使用
	local containerNode = self._containerNode
	local parsedtable = labelparser.parse(text)
	local allnodelist, alllines = self:createLabels_(containerNode, parsedtable)

	self._alllines = alllines
	self._allnodelist = allnodelist
	self._parsedtable = parsedtable	
end 

function RichLabel:getAllLines()
	return self._alllines
end

function RichLabel:getString()
	return self._currentText
end

--[[--
-   setMaxWidth: 设置行最大宽度
	@param: maxwidth - 行的最大宽度
]]

function RichLabel:setMaxWidth(maxwidth)
	if self._maxWidth == maxWidth then
		return
	end
	self._lastMaxWidth = self._maxWidth
	self._maxWidth = maxwidth
	-- self:layout()
	if self._currentText then
		self:setString(self._currentText)
	end
end

function RichLabel:setAnchorPoint(anchor, anchor_y)
	if type(anchor) == "number" then
		anchor = cc.p(anchor, anchor_y)
	end
	local super_setAnchorPoint = getmetatable(self).setAnchorPoint
	super_setAnchorPoint(self, anchor)
	if self._currentText then 
		-- self:layout()
		self:updatePosition(self._currentWidth, self._currentHeight)
	end
end

--[[--
-   getSize: 获得label的真实宽度
]]
function RichLabel:getSize()
	return cc.size(self._currentWidth, self._currentHeight)
end

--[[--
-   getLineHeight: 获得行高，取决于此行最高的元素
]]
function RichLabel:getLineHeight(rowindex)
	local line = self._alllines[rowindex]
	if not line then return 0
	end

	local maxheight = 0
	for _, node in pairs(line) do
		local box = node:getBoundingBox()
		if box.height > maxheight then
			maxheight = box.height
		end
	end
	return maxheight
end

--[[--
-   getElementWithIndex: 获得指定位置的元素
]]
function RichLabel:getElementWithIndex(index)
	return self._allnodelist[index]
end

--[[--
-   getElementWithRowCol: 获得指定位置的元素
]]
function RichLabel:getElementWithRowCol(rowindex, colindex)
	local line = self._alllines[rowindex]
	if line then return line[colindex]
	end
end


--[[--
-   walkElements: 遍历元素
]]
function RichLabel:walkElements(callback)
	assert(callback)
	for index, node in pairs(self._allnodelist) do
		if callback(node, index) ~= nil then return 
		end
	end
end

--[[--
-   walkLineElements: 遍历并传入行号和列号
]]
function RichLabel:walkLineElements(callback)
	assert(callback)
	for rowindex, line in pairs(self._alllines) do
		for colindex, node in pairs(line) do
			if callback(node, rowindex, colindex) ~= nil then return 
			end
		end
	end
end

--
-- Animation
--

-- wordpersec: 每秒多少个字
-- callback: 每个字符出来前的回调
function RichLabel:playAnimation(wordpersec, callback)
	wordpersec = wordpersec or ANIM_WORD_PER_SEC
	if self:isAnimationPlaying() then return
	end
	local counter = 0
	local animationCreator = function(node, rowindex, colindex)
		counter = counter + 1
		return cc.Sequence:create(
				cc.DelayTime:create(counter/wordpersec),
				cc.CallFunc:create(function() 
					if callback then callback(node, rowindex, colindex) end 
				end),
				cc.FadeIn:create(0.2),
				cc.CallFunc:create(function()
					self._animationCounter = self._animationCounter - 1
				end)
			)
	end

	self:walkLineElements(function(node, rowindex, colindex)
		self._animationCounter = self._animationCounter + 1
		node:setOpacity(0)
		node:runAction(animationCreator(node, rowindex, colindex))
	end)
end

function RichLabel:isAnimationPlaying()
	return self._animationCounter > 0
end

function RichLabel:stopAnimation()
	self._animationCounter = 0 
	self:walkElements(function(node, index)
		node:setOpacity(255)
		node:stopAllActions()
	end)
end



--
-- Debug
--

--[[--
-   debugDraw: 绘制边框
	@param: level - 绘制级别，level<=2 只绘制整体label, level>2 绘制整体label和单个字符的范围
]]
function RichLabel:debugDraw(level)
	level = level or 2
    local containerNode = self._containerNode
	local debugdrawnodes1 = cc.utils:findChildren(containerNode, DEBUG_MARK)
	local debugdrawnodes2 = cc.utils:findChildren(self, DEBUG_MARK)
	function table_insertto(dest, src, begin)
	    if begin <= 0 then
	        begin = #dest + 1
	    end
	    local len = #src
	    for i = 0, len - 1 do
	        dest[i + begin] = src[i + 1]
	    end
	end
	table_insertto(debugdrawnodes1, debugdrawnodes2, #debugdrawnodes1+1)
	for k,v in pairs(debugdrawnodes1) do
		v:removeFromParent()
	end

	local labelSize = self:getSize()
	local anchorpoint = self:getAnchorPoint()
	local pos_x, pos_y = 0, 0
	local origin_x = pos_x-labelSize.width*anchorpoint.x
	local origin_y = pos_y-labelSize.height*anchorpoint.y
	local frame = cc.rect(origin_x, origin_y, labelSize.width, labelSize.height)
	-- 绘制整个label的边框
    self:drawrect(self, frame, 1):setName(DEBUG_MARK)
    -- 绘制label的锚点
    self:drawdot(self, cc.p(0, 0), 5):setName(DEBUG_MARK)

    -- 绘制每个单独的字符
    if level > 1 then
	    local allnodelist = self._allnodelist
	    local drawcolor = cc.c4f(0,0,1,0.5)
	    for _, node in pairs(allnodelist) do
	    	local box = node:getBoundingBox()
	    	local pos = cc.p(node:getPositionX(), node:getPositionY())
			self:drawrect(containerNode, box, 1, drawcolor):setName(DEBUG_MARK)
			self:drawdot(containerNode, pos, 2, drawcolor):setName(DEBUG_MARK)
	    end
	end
end


--- 超链接
function RichLabel:createLink_(node, params)
	local box = node:getBoundingBox()
	local size = cc.size(box.width, box.height)
	-- local bgLayer = ui.newLayer(size, cc.c4b(255, 255, 255, 40)) -- for test
	local bgLayer = ui.newLayer(size)
	if self._callback then
		Helper.setTouchEnable(bgLayer, function(touch, event)
			local eventCode = event:getEventCode()
			local target = event:getCurrentTarget()
			-- yzjprint(eventCode, tostring(target))
			if eventCode == 0 then
				if Helper.isClickInTarget(target, touch) then
					target._isLinkTouchBegan = true
					return true
				end
				return false
			elseif eventCode == 2 then
				if target._isLinkTouchBegan and Helper.isClickInTarget(target, touch) then
					-- local locationInNode = target:getParent():convertToNodeSpace(touch:getLocation())
					local locationInNode = touch:getLocation()
					self._callback(params.id or "", params.name or "", params.href or "", locationInNode.x, locationInNode.y)
				end
				target._isLinkTouchBegan = false
			end
		end, true, false, true, true)
	else
		-- yzjprint("Tag '<a>' of html label has no callback !!")
	end

	local fontColor = params.color or self._default.fontColor

	fontColor = checkC3b(fontColor)
	local line = ui.drawLine(nil,size,{fontColor.r, fontColor.g, fontColor.b, 255})
	line:setPosition(0, 2)
	line:setAnchorPoint(cc.p(0, 0))
	bgLayer:addChild(line)

	node:setPosition(0, 0)
	node:setAnchorPoint(cc.p(0, 0))
	bgLayer:addChild(node)
	return bgLayer
end

-- 创建临时对象用于计算宽高，内存命中率
function RichLabel:createLabelTemp_(params)
	--  size属性是字体大小，但是旧的html不支持，需要保持一致
	-- local fontSize = ((params.size or params.face) or params.fontSize) or self._default.fontSize
	local fontSize = (params.face or params.fontSize) or self._default.fontSize
	return ui.newLabel(params.content, checkFontSize(fontSize))
end


---------简单的帧动画创建
function createExpressAnimation(format, num, time)
	local tab = {}
	local frame
	for i=1, num do
		frame = ui.newSprFrame(string.format("#" .. format, i))
		if frame then
			table.insert(tab, frame)
		end
	end
	local sp
	if #tab >= 1 then
		sp = cc.Sprite:createWithSpriteFrame(tab[1])
		sp:setScale(_expressionScale)
		local animation = cc.Animation:createWithSpriteFrames(tab)
		animation:setDelayPerUnit(time/num)
		local animate = cc.Animate:create(animation)
		sp:runAction(cc.RepeatForever:create(animate))
	else
		sp = cc.Sprite:create()
	end
	return sp
end



function RichLabel:createLabel_(params)
	local node
	if params.labelname == "cs" then
		local expressionData = expressionList[params.id]
		node = createExpressAnimation(expressionData[3], expressionData[1], expressionData[2])
	else
		--  size属性是字体大小，但是旧的html不支持，需要保持一致
		-- local fontSize = ((params.size or params.face) or params.fontSize) or self._default.fontSize
		local fontSize = (params.face or params.fontSize) or self._default.fontSize
		fontSize = checkFontSize(fontSize)
		local fontColor = params.color or self._default.fontColor
		if params.start_color and params.end_color then
			node = ui.newGradientLabel(params.content, fontSize, checkC3b(params.start_color), checkC3b(params.end_color), params.dimensions)
		else
			node = ui.newLabel(params.content, fontSize, checkC3b(fontColor), params.dimensions)
		end
		if params.labelname == "a" then
			node = self:createLink_(node, params)
		end
	end
	return node
end

	
function RichLabel:getContentSize()
	return self:getSize()
end
		
local function getPartTable(tab, begPos, endPos)
	endPos = endPos or #tab
	local ret = {}
	for i = begPos, endPos do
		ret[#ret +1] = tab[i]
	end
	return ret
end


function RichLabel:checkStrWidth_(params)
	local content = params.content
	assert(type(content) == 'string', "'params.content' in RichLabelcheckStrWidth_ is not 'string' type")
	local maxWidth = self._maxWidth
	local isNextLine
	local curStr = content
	local nextStr
	-- yzjprint(content, "==   self.addwidth, box.width, maxWidth = ", self.addwidth, box.width, maxWidth)

	local foundBreakMark = false
	local b, e = string.find(content, "\n")
	if b then
		local tempCurStr = string.sub(content, 1, b - 1)
		local node = self:createLabelTemp_{content = tempCurStr, face = params.face, fontSize = params.fontSize}
		if (self.addwidth + node:getBoundingBox().width <= maxWidth) then
			isNextLine = true
			foundBreakMark = true
			curStr = string.sub(content, 1, b - 1)
			nextStr = string.sub(content, e + 1)

			if curStr == "" then
				curStr = " " -- 用于换行高度计算
			end
		end
	end

	if not foundBreakMark then
		local node = self:createLabelTemp_(params)
		local box = node:getBoundingBox()
		local calcWidth = self.addwidth + box.width
		
		isNextLine = (calcWidth > maxWidth)

		if isNextLine then
			local chars = self:stringToChars(content)
			local width = self.addwidth
			local breakIndex

			for i, v in ipairs(chars) do
				local tempNode = self:createLabelTemp_{content = v, face = params.face, fontSize = params.fontSize}
				width = width + tempNode:getBoundingBox().width
				if width > maxWidth then
					breakIndex = i
					break
				end
			end
			-- yzjprint("== breakIndex = ", breakIndex)
			curStr = table.concat(getPartTable(chars, 1, breakIndex - 1)) 
			nextStr = table.concat(getPartTable(chars, breakIndex))
		else
			self.addwidth = calcWidth
		end
	end
	return isNextLine, curStr, nextStr
end


function RichLabel:checkAnimWidth_(params)
	local expressionData = expressionList[params.id]
    local format, num, time = expressionData[3], expressionData[1], expressionData[2]
	local sp
	if num > 0 then
		frame = ui.newSprFrame(string.format("#" .. format, 1))
		sp = cc.Sprite:createWithSpriteFrame(frame)
	else
		sp = cc.Sprite:create()
	end
	sp:setScale(_expressionScale)

	local box = sp:getBoundingBox()
	-- yzjprint(self.addwidth, "====== checkAnimWidth_() ")
	local calcWidth = self.addwidth + box.width
	local maxWidth = self._maxWidth
	local isNextLine = (calcWidth > maxWidth)
	
	if not isNextLine then
		self.addwidth = calcWidth
	end

	return isNextLine
end

function RichLabel:addToParsedTable(parsedtable, index, newParams, newParams2)
	parsedtable[index] = newParams
	if newParams2 then
		table.insert(parsedtable, index + 1, newParams2)
	end
	return parsedtable
end

function RichLabel:traverseParsedTable_(parsedtable, index, lineindex)
	local count = 0 
	local len = #parsedtable
	for i = index, len do
		local params = parsedtable[i]
		local isNextLine, curStr, nextStr

		--创建文字
		if (params.labelname == "font" or params.labelname == "a") then 
			isNextLine, curStr, nextStr = self:checkStrWidth_(params)
		--表情动画
		elseif params.labelname == "cs" then 
			isNextLine = self:checkAnimWidth_(params)
		end

		-- yzjprint(" isNextLine ", isNextLine, curStr, " <> ", nextStr)
		if isNextLine then
			self.addwidth = 0

			local newParsedTable
			if curStr then
				-- 替换本项的内容
				local newParams = clone(params)
				newParams.content = curStr
				if nextStr ~= "" then
					local newParams2 = clone(params)
					newParams2.content = nextStr
					newParsedTable = self:addToParsedTable(parsedtable, i, newParams, newParams2)
				end
			end
			if params.labelname == "cs" then 
				-- 换行索引
				self._breakline[lineindex] = count - 1
				self:traverseParsedTable_(parsedtable, i, lineindex + 1)
			else
				-- 换行索引
				self._breakline[lineindex] = count
				self:traverseParsedTable_(newParsedTable or parsedtable, i + 1, lineindex + 1)
			end

			break
		else
			if len ~= i then
				count = count + 1
			else
				-- 最后一项
				self._breakline[lineindex] = count
			end
		end
	end
	return parsedtable
end


function RichLabel:createLine_(containerNode, parsedtable, sIndex, eIndex)
	local lines = {}
	local width = 0
	local height = 0
	if parsedtable then
		for i = sIndex, eIndex do
			if parsedtable[i] then
				local node = self:createLabel_(parsedtable[i])
				lines[#lines + 1] = node
				local box = node:getBoundingBox()
				node:setAnchorPoint(cc.p(0, 0))
				node:setPosition(width, 0)
				containerNode:addChild(node)
				width = width + box.width
				height = box.height > height and box.height or height
			end
		end
	end
	return lines, width, height
end


function RichLabel:createLabels_(containerNode, parsedtable)
	local allnodelist = {}
	self._breakline = {}

	self.addwidth = 0 -- 用于每行长度判断
	parsedtable = self:traverseParsedTable_(parsedtable, 1, 1)
	-- printTable(parsedtable, yzjprint)
	-- printTable(self._breakline, yzjprint)

	-- 每行创建
	local index = 1
	local lineHeightTable = {}
	local alllines = {}
	local containerNode = self._containerNode
	local linespace = self._default.lineSpace
	-- local charspace = self._default.charSpace
	local maxwidth = 0
	local maxheight = 0
	for lineindex, count in ipairs(self._breakline) do
		local lines, linewidth, lineheight = self:createLine_(containerNode, parsedtable, index, index + count)
		maxheight = maxheight + lineheight + linespace
		maxwidth = linewidth > maxwidth and linewidth or maxwidth

		--  调整高度
		alllines[lineindex] = {}
		for i, node in ipairs(lines) do
			node:setPositionY(-maxheight)
			table.insert(alllines[lineindex], node)
			table.insert(allnodelist, node)
		end

		index = index + count + 1
	end

	-- 减去最后多余的一个行间距
	maxheight = maxheight - linespace
	self:updatePosition(maxwidth, maxheight)

	return allnodelist, alllines
end


function RichLabel:updatePosition(maxwidth, maxheight)
	local containerNode = self._containerNode
	self._currentWidth = maxwidth
	self._currentHeight = maxheight
	-- 根据锚点重新定位
	local anchor = self:getAnchorPoint()
	local origin_x, origin_y = 0, maxheight
	local result_x = origin_x - anchor.x * maxwidth
	local result_y = origin_y - anchor.y * maxheight
	containerNode:setPosition(result_x, result_y)
end


-- 拆分出单个字符
function RichLabel:stringToChars(str)
	-- 主要用了Unicode(UTF-8)编码的原理分隔字符串
	-- 简单来说就是每个字符的第一位定义了该字符占据了多少字节
	-- UTF-8的编码：它是一种变长的编码方式
	-- 对于单字节的符号，字节的第一位设为0，后面7位为这个符号的unicode码。因此对于英语字母，UTF-8编码和ASCII码是相同的。
	-- 对于n字节的符号（n>1），第一个字节的前n位都设为1，第n+1位设为0，后面字节的前两位一律设为10。
	-- 剩下的没有提及的二进制位，全部为这个符号的unicode码。
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end



-- drawdot(self, cc.p(200, 200))
function RichLabel:drawdot(canvas, pos, radius, color4f)
    radius = radius or 2
    color4f = color4f or cc.c4f(1,0,0,0.5)
    local drawnode = cc.DrawNode:create()
    drawnode:drawDot(pos, radius, color4f)
    canvas:addChild(drawnode)
    return drawnode
end

-- drawrect(self, cc.rect(200, 200, 300, 200))
function RichLabel:drawrect(canvas, rect, borderwidth, color4f, isfill)
    local bordercolor = color4f or cc.c4f(1,0,0,0.5)
    local fillcolor = isfill and bordercolor or cc.c4f(0,0,0,0)
    borderwidth = borderwidth or 2

    local posvec = {
        cc.p(rect.x, rect.y),
        cc.p(rect.x, rect.y + rect.height),
        cc.p(rect.x + rect.width, rect.y + rect.height),
        cc.p(rect.x + rect.width, rect.y)
    }
    local drawnode = cc.DrawNode:create()
    drawnode:drawPolygon(posvec, 4, fillcolor, borderwidth, bordercolor)
    canvas:addChild(drawnode)
    return drawnode
end



local replaceMap = {
	["<br/>"] = "\n",
	["<cs id=\"($%d%d)\"/>"] = "<cs id=\"%1\"></cs>",
}

function RichLabel:checkTags_(text)
	for k, v in pairs(replaceMap) do
		text = string.gsub(text, k, v)
	end
	return text
end


function checkFontSize(fs)
	if type(fs) == "string" then
		fs = string.gsub(fs, "font", "")
	end
	return tonumber(fs)
end



local function subColorStr(str, s, e)
	local ret = string.sub(str, s, e)
	return ret ~= "" and ret or "00"
end

-- 解析16进制颜色rgb值, 支持格式 #000000、0x000000
function checkC3b(c)
	if type(c) == "string" then
		local r, g, b
		if string.sub(c, 1, 1) == "#" then
			r, g, b = "0x" .. subColorStr(c, 2, 3), "0x" .. subColorStr(c, 4, 5), "0x" .. subColorStr(c, 6, 7)
		else
			r, g, b = "0x" .. subColorStr(c, 3, 4), "0x" .. subColorStr(c, 5, 6), "0x" .. subColorStr(c, 7, 8)
		end
		return cc.c3b(tonumber(r), tonumber(g), tonumber(b))
	else
		return c
	end
end

return RichLabel