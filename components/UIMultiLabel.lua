----------------------------------------
-- YuZhenjian
-- 2014年10月16日
-- 多颜色字体
----------------------------------------

--local UIMultiLabel = class("UIMultiLabel", function() return ui.newLayer(cc.c4b(255, 0, 0, 255)) end)
local tClass = class("UIMultiLabel", function() return cc.Node:create() end)


--textTab = {
--    {font, color, size},
--    {obj, offsetPos},
--    ...
--}
-- defSize 默认字体大小
-- defColor 默认字体大小
-- defIdx 默认调用索引 setString、setColor等接口需要
function tClass:ctor(textTab, defSize, defColor, defIdx)
    
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    
    
    self.labTab = {} 

    local w, h = 0, 0 
    for i, text in ipairs(textTab) do
        local label
        local offsetPos
        -- 如果是对象
        if type(text[1]) == "userdata" then
            label = text[1]
            offsetPos = text[2]
        else
            label = ui.newLabel(text[1], text[3] or defSize, text[2] or defColor, nil, ui.fontType.def)
        end
        label:setAnchorPoint(cc.p(0, 0))
        if offsetPos then
        	label:setPosition(w + offsetPos.x, offsetPos.y)
        else
        	label:setPosition(w, 0)
        end
        self:addChild(label)
        
        label.w, label.h = label:getPosition()
        
        label:setTag(i)
        self.labTab[i] = label
        
        local size = label:getContentSize()
        w = w + size.width
        h = size.height > h and size.height or h
    end
    self.size = cc.size(w, h)
    self:setContentSize(self.size)
    
    self.defSize = defSize
    self.defColor = defColor
    self.defIdx = defIdx or 1

end
 
-- {"text", "color", "fontsize"}
function tClass:addLabel(tab)
    local contentSize = self:getContentSize()
    local label = ui.newLabel(tab[1] .."", tab[3] or self.defSize, tab[2] or self.defColor, nil, ui.fontType.def)
    label:setAnchorPoint(cc.p(0, 0))
    label:setPosition(contentSize.width, 0)
    self:addChild(label)

    label.w = contentSize.width
    label.h = 0

    local labelSize = label:getContentSize()
    local w = contentSize.width + labelSize.width
    local h = labelSize.height > contentSize.height and labelSize.height or contentSize.height
    self.size = cc.size(w, h)
    self:setContentSize(self.size)   
end

--function tClass:onEnter()
--end
--
--function tClass:onExit()
--end

-- 设置默认索引
function tClass:setDefaultIndex(index)
    self.defIdx = index
end

-- 设置字体
function tClass:setString(str, index)
	index = index or self.defIdx
    local label = self.labTab[index]
    
    if not tolua.isnull(label) and label.setString then
        local oldSize = label:getContentSize()
--        gprint("old width  = " .. oldSize.width)
        
        label:setString(str)
        local newSize = label:getContentSize()
        
--        gprint("new width  = " .. newSize.width)
        
        local offsetW = newSize.width - oldSize.width
        
        if offsetW ~= 0 then
            for i = index + 1, #self.labTab do
                local tLabel = self.labTab[i]
                
                tLabel.w = tLabel.w + offsetW
                tLabel:setPosition(tLabel.w, tLabel.h)
                
            end
            
            self.size = cc.size(self.size.width + offsetW, self.size.height)
            self:setContentSize(self.size)
        end
    else
        gprint("labels 无效索引" .. index)
    end
end

-- 设置颜色
function tClass:setColor(color, index)
	index = index or self.defIdx
    local label = self.labTab[index]
    if not tolua.isnull(label) and label.setColor then
        label:setColor(color)
    end
end

function tClass:getChildByIndex(index)
    return self.labTab[index]
end


return tClass