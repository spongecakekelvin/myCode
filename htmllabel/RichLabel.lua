
--[[

	富文本标签
	---
	RichLabel基于Cocos2dx+Lua v3.x  
	扩展标签极其简单，只需添加一个遵守规则的标签插件即可，无需改动已存在代码！！！  

	**特性：**
	    
	*   支持标签定义富文本展示格式
	*   支持图片(缩放，旋转，是否可见)
	*   支持文本属性(字体，大小，颜色，阴影，描边，发光)
	*   支持标签嵌套修饰文本，但是内部标签不会继承嵌套标签的属性
	*   支持标签扩展(labels文件夹中可添加标签支持)
	*   支持渐入动画，动画逐字回调
	*   支持设置最大宽度，自动换行布局
	*   支持手动换行，使用'\n'换行
	*   支持设置行间距，字符间距
	*   支持添加debug绘制文字范围和锚点
	*   支持获得文字的精灵节点
	*   支持设置标签锚点，透明度，颜色...
	*   支持遍历字符，行等
	*   支持获得任意行的行高
	        
	**标签支持：**  

	`<div>` - 文本标签，用于修饰文件，非自闭和标签，必须配对出现    
	属性： fontname, fontsize, fontcolor, outline, glow, shadow   
	注意：

	* *outline, glow 不能同时生效*
	* *使用glow会自动修改ttfConfig.distanceFieldEnabled=true，否则没有效果*
	* *使用描边效果后，ttfConfig.distanceFieldEnabled=false，否则没有效果*

	格式：

	+ fontname='pathto/msyh.ttf'
	+ fontsize=30
	+ fontcolor=#ff0099
	+ shadow=10,10,10,#ff0099 - (offset_x, offset_y, blur_radius, shadow_color)
	+ outline=1,#ff0099       - (outline_size, outline_color)
	+ glow=#ff0099            - (glow_color) 
	    
	`<img />` - 图像标签，用于添加图片，自闭合标签，必须自闭合<img />  
	属性：src, scale, rotate, visible  
	注意：*图片会首先在帧缓存中加载，否则直接在磁盘上加载*  
	格式：  
	+ src="pathto/avator.png"
	+ scale=0.5
	+ rotate=90
	+ visible=false

	**注意：**  

	+ 内部使用Cocos2dx的TTF标签限制，要设置默认的正确的字体，否则无法显示  
	+ 如果要设置中文，必须使用含有中文字体的TTF

	**示例：**
	```
	------------------------------------------------------
	------------  TEST RICH-LABEL
	------------------------------------------------------ 

	local test_text = {
	    "<div fontcolor=#ff0000>hello</div><div fontcolor=#00ff00>hello</div><div fontsize=12>你</div><div fontSize=26 fontcolor=#ff00bb>好</div>ok",
	    "<div outline=1,#ff0000 >hello</div>",
	    "<div glow=#ff0000 >hello</div>",
	    "<div shadow=2,-2,0.5,#ff0000 >hello</div>",
	    "hello<img src='res/test.png' scale=0.5 rotate=90 visible=true />world",
	}
	for i=1, #test_text do
	    local RichLabel = require("richlabel.RichLabel")
	    local label = RichLabel.new {
	        fontName = "res/msyh.ttf",
	        fontSize = 20,
	        fontColor = cc.c3b(255, 255, 255),
	        maxWidth=200,
	        lineSpace=0,
	        charSpace=0,
	    }
	    label:setString(test_text[i])
	    label:setPosition(cc.p(380,500-i*30))
	    label:playAnimation()
	    sceneGame:addChild(label)

	    label:debugDraw()
	end 
	
	```

	**基本接口：**

	* setString - 设置要显示的富文本   
	* getSize - 获得Label的大小  

	*当前版本：v1.0.1*  
	v1.0.0 - 支持`<div>`标签，仅支持基本属性(fontname, fontsize, fontcolor)  
	v1.0.1 - 增加`<div>`标签属性(shadow, outline, glow)的支持，增加`<img>`标签的支持(labelparser增加解析自闭和标签支持) 

]]--

local CURRENT_MODULE = ...
ccprint(CURRENT_MODULE)
--local dotindex = string.find(CURRENT_MODULE, "%.%w+$")
--local currentpath = string.sub(CURRENT_MODULE, 1, dotindex-1)
--local parserpath = string.format("%s.labelparser", currentpath, label)
--local labelparser = require(parserpath)
-- local labelparser = require("gamecore/ui/richlabel/labelparser")
require("gamecore/ui/richlabel/htmlparser")
local labelparser = htmlparser

local RichLabel = class("RichLabel", function()
    return cc.Node:create()
end)	

-- 文本的默认属性
RichLabel._default = nil

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
local expressionScale_ = 0.44
-- local expressionScale_ = 1

--[[--
-   ctor: 构造函数
	@param: 
		params - 可选参数列表
		params.fontName - 默认的字体名称
		params.fontSize - 默认字体大小
		params.fontColor - 默认字体颜色
		params.maxWidth - Label最大宽度
		params.lineSpace - 行间距
		params.charSpace - 字符间距
]]
local checkFontSize
local checkC3b

function RichLabel:ctor(params)
	params = params or {}
	local fontName 	= params.fontName
	local fontSize 	= params.fontSize
	local fontColor = params.fontColor or cc.c3b(0xff, 0xff, 0xff)
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
	if self._currentText == text then
		return
	end

	-- 若之前存在字符串，要先清空
	if self._currentText then
		self._allnodelist = nil
		self._parsedtable = nil
		self._alllines = nil
		self._containerNode:removeAllChildren()
	end

	self._currentText = text

	local containerNode = self._containerNode

	-- 普通字符
	if not string.find(text, "<.+>") then
		-- yzjprint("normal return !!!! ", text)
		self._allnodelist = {}
		self._alllines = {[1]={}}
		self._parsedtable = {[1] = {content = text}}
		
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

function RichLabel:getString()
	return self._currentText
end

--[[--
-   setMaxWidth: 设置行最大宽度
	@param: maxwidth - 行的最大宽度
]]
function RichLabel:setMaxWidth(maxwidth)
	self._maxWidth = maxwidth
	self:layout()
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
-   getElementsWithLetter: 获取字母匹配的元素集合
]]
function RichLabel:getElementsWithLetter(letter)
	local nodelist = {}
	for _, node in pairs(self._allnodelist) do
		-- 若为Label则存在此方法
		if node.getString then
			local str = node:getString()
			-- 若存在换行符，则换行
			if str==letter then 
				table.insert(nodelist, node)
			end
		end
	end
	return nodelist
end

--[[--
-   getElementsWithGroup: 通过属性分组顺序获取一组的元素集合
]]
function RichLabel:getElementsWithGroup(groupIndex)
	return self._parsedtable[groupIndex].nodelist
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



-- 一般情况下无需手动调用，设置setMaxWidth, setString, setAnchorPoint时自动调用
-- 自动布局文本，若设置了最大宽度，将自动判断换行
-- 否则一句文本中的内容'\n'换行
function RichLabel:layout()
	local parsedtable = self._parsedtable
	local basepos = cc.p(0, 0)
	local col_idx = 0
	local row_idx = 0

	local containerNode = self._containerNode
	local allnodelist = self._allnodelist
	local linespace = self._default.lineSpace
	local charspace = self._default.charSpace

	local maxwidth = 0
	local maxheight = 0
	-- 处理所有的换行，返回换行后的数组
	local alllines = self:adjustLineBreak_(allnodelist, charspace)
	self._alllines = alllines
	for index, line in pairs(alllines) do
		local linewidth, lineheight = self:layoutLine_(basepos, line, 1, charspace)
		local offset = lineheight + linespace
		basepos.y = basepos.y - offset
		maxheight = maxheight + offset
		if maxwidth < linewidth then maxwidth = linewidth
		end
	end
	-- 减去最后多余的一个行间距
	maxheight = maxheight - linespace
	self._currentWidth = maxwidth
	self._currentHeight = maxheight

	-- 根据锚点重新定位
	local anchor = self:getAnchorPoint()
	local origin_x, origin_y = 0, maxheight
	local result_x = origin_x - anchor.x * maxwidth
	local result_y = origin_y - anchor.y * maxheight
	containerNode:setPosition(result_x, result_y)
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

--
-- Internal Method
--

-- 加载标签解析器，在labels文件夹下查找
function RichLabel:loadLabelParser_(label)
	local labelparserlist = shared_parserlist
	local parser = labelparserlist[label]
	if parser then return parser
	end
	-- 组装解析器名
--    local dotindex = string.find(CURRENT_MODULE, "%.%w+$")
--    if not dotindex then return
--    end
--    local currentpath = string.sub(CURRENT_MODULE, 1, dotindex-1)
	local parserpath = string.format("gamecore/ui/richlabel/labels/label_%s", label)
	-- 检测是否存在解析器
	local parser = require(parserpath)
	if parser then
		labelparserlist[label] = parser
	end
	return parser
end

function RichLabel:createLink_(node, params)
	local box = node:getBoundingBox()
	local size = cc.size(box.width, box.height)
	-- local bgLayer = ui.newLayer(size, cc.c4b(255, 255, 255, 40)) -- for test
	local bgLayer = ui.newLayer(size)
	if self._callback then
		Helper.setTouchEnable(bgLayer, function(touch, event)
			local eventCode = event:getEventCode()
			local target = event:getCurrentTarget()
			yzjprint(eventCode, tostring(target))
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
		gprint("Tag '<a>' of html label has no callback !!")
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
		sp:setScale(expressionScale_)
		local animation = cc.Animation:createWithSpriteFrames(tab)
		animation:setDelayPerUnit(time/num)
		local animate = cc.Animate:create(animation)
		sp:runAction(cc.RepeatForever:create(animate))
	else
		sp = cc.Sprite:create()
		yzjprint(format)
	end
	return sp
end



function RichLabel:createLabel_(params)
	local node
	if params.labelname == "cs" then
		-- params.content = ""
		local expressionData = expressionList[params.id]
		node = createExpressAnimation(expressionData[3], expressionData[1], expressionData[2])
	else
	-- end
		--  size属性是字体大小，但是旧的html不支持，需要保持一致
		-- local fontSize = ((params.size or params.face) or params.fontSize) or self._default.fontSize
		local fontSize = (params.face or params.fontSize) or self._default.fontSize
		local fontColor = params.color or self._default.fontColor
		node = ui.newLabel(params.content, checkFontSize(fontSize), checkC3b(fontColor))
		if params.labelname == "a" then
			node = self:createLink_(node, params)
		end
	end
	-- local box = node:getBoundingBox()
	-- yzjprint("== params ", tostring(params.content),  tostring(params.labelname), box.width, box.height)
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
	local curStr = content
	local nextStr
	local node = self:createLabelTemp_(params)
	local box = node:getBoundingBox()
	local calcWidth = self.addwidth + box.width
	local maxWidth = self._maxWidth
	local isNextLine = (calcWidth > maxWidth)
	-- yzjprint(content, "==   self.addwidth, box.width, maxWidth = ", self.addwidth, box.width, maxWidth)
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
		local b, e = string.find(content, "\n")
		if b then
			isNextLine = true
			curStr = string.sub(content, 1, b - 1)
			nextStr = string.sub(content, e + 1)
			-- yzjprint(content, "  break found \\n return !!")
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
		sp = cc.Sprite:creat()
	end
	sp:setScale(expressionScale_)

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
			-- yzjprint("=====  == == curStr, nextStr= ", tostring(curStr),"   ++  ", tostring(nextStr))
		elseif params.labelname == "cs" then --表情动画
			isNextLine = self:checkAnimWidth_(params)
		end

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

	for i = sIndex, eIndex do
		local node = self:createLabel_(parsedtable[i])
		lines[#lines + 1] = node
		local box = node:getBoundingBox()
		node:setAnchorPoint(cc.p(0, 0))
		node:setPosition(width, 0)
		containerNode:addChild(node)
		width = width + box.width
		height = box.height > height and box.height or height

	end
	return lines, width, height
end


function RichLabel:createLabels_(containerNode, parsedtable)
	
	local default = self._default
	local allnodelist = {}
	local alllines = {}
	self.lineIndex = 1

	self.addwidth = 0

	self._breakline = {}
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
		-- yzjprint("linewidth, lineheight = ", linewidth, lineheight)
		maxheight = maxheight + lineheight + linespace
		maxwidth = linewidth > maxwidth and linewidth or maxwidth

		--  调整高度
		alllines[lineindex] = {}
		for i, node in ipairs(lines) do
			-- yzjprint("linewidth, lineheight = ", 0, -maxheight)
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
	-- printTable(anchor)
	-- yzjprint(debug.traceback() .. "========= result_x, result_y = ", result_x, result_y, origin_x, origin_y)
	containerNode:setPosition(result_x, result_y)
end


-- 布局单行中的节点的位置，并返回行宽和行高
function RichLabel:layoutLine_(basepos, line, anchorpy, charspace)
	anchorpy = anchorpy or 0.5
	local pos_x = basepos.x
	local pos_y = basepos.y
	local lineheight = 0
	local linewidth = 0
	for index, node in pairs(line) do
		local box = node:getBoundingBox()
		-- 设置位置
		node:setPosition((pos_x + linewidth + box.width/2), pos_y)
		-- 累加行宽度
		linewidth = linewidth + box.width + charspace
		-- 查找最高的元素，为行高
		if lineheight < box.height then lineheight = box.height
		end
	end
	-- 重新根据排列位置排列
	-- anchorpy代表文本上下对齐的位置，0.5代表中间对齐，1代表上部对齐
	if anchorpy ~= 0.5 then
		local offset = (anchorpy-0.5)*lineheight
		for index, node in pairs(line) do
			local yy = node:getPositionY()
			node:setPositionY(yy-offset)
		end
	end
	return linewidth - charspace, lineheight
end

-- 自动适应换行处理方法，内部会根据最大宽度设置和'\n'自动换行
-- 若无最大宽度设置则不会自动换行
function RichLabel:adjustLineBreak_(allnodelist, charspace)
	-- 如果maxwidth等于0则不自动换行
	local maxwidth = self._maxWidth
	-- 存放每一行的nodes
	local alllines = {{}, {}, {}}
	-- 当前行的累加的宽度
	local addwidth = 0
	local rowindex = 1
	local colindex = 0
	for _, node in pairs(allnodelist) do
		colindex = colindex + 1
		-- 为了防止存在缩放后的node
		local box = node:getBoundingBox()
		addwidth = addwidth + box.width
		local totalwidth = addwidth + (colindex - 1) * charspace
		local breakline = false
		-- 若累加宽度大于最大宽度
		-- 则当前元素为下一行第一个元素
		if totalwidth > maxwidth then
			rowindex = rowindex + 1
			addwidth = box.width -- 累加数值置当前node宽度(为下一行第一个)
			colindex = 1
			breakline = true
		end

		-- 在当前行插入node
		local curline = alllines[rowindex] or {}
		alllines[rowindex] = curline
		table.insert(curline, node)

		-- 若还没有换行，并且换行符存在，则下一个node直接转为下一行
		if not breakline and self:adjustContentLinebreak_(node) then
			rowindex = rowindex + 1
			colindex = 0
			addwidth = 0 -- 累加数值置0
		end
	end
	return alllines
end

-- 判断是否为文本换行符
function RichLabel:adjustContentLinebreak_(node)
	-- 若为Label则有此方法
	if node.getString then
		local str = node:getString() 
		-- 查看是否为换行符
		if str == "\n" then
			return true
		end
	end
	return false
end

-- 
-- utils
--

-- 解析16进制颜色rgb值
function  RichLabel:convertColor(xstr)
	if not xstr then return 
	end
    local toTen = function (v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xstr, -2, -1) 
    local g = string.sub(xstr, -4, -3) 
    local r = string.sub(xstr, -6, -5)

    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    if red and green and blue then 
    	return cc.c4b(red, green, blue, 255)
    end
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

function RichLabel:split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function RichLabel:printf(fmt, ...)
	return print(string.format("RichLabel# "..fmt, ...))
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

-- 创建精灵，现在帧缓存中找，没有则直接加载
-- 屏蔽了使用图集和直接使用碎图创建精灵的不同
function RichLabel:getSprite(filename)
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local spriteFrame = spriteFrameCache:getSpriteFrameByName(filename)

	if spriteFrame then
		return cc.Sprite:createWithSpriteFrame(spriteFrame)
	end
	return cc.Sprite:create(filename)
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

function checkC3b(c)
	if type(c) == "string" then
		local r, g, b = "0x" .. string.sub(c, 2, 3), "0x" .. string.sub(c, 4, 5), "0x" .. string.sub(c, 6, 7)
		return cc.c3b(r, g, b)
	else
		return c
	end
end

return RichLabel
