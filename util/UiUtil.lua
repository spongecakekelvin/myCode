-- 子节点居中于父节点 (默认居中)
-- 可选参数:
-- wRatio: 宽度比例
-- hRatio: 高度比例
-- offsetX: 偏移x
-- offsetY: 偏移y
function ui.alignCenter(parent, child, wRatio, hRatio, offsetX, offsetY)
    wRatio = wRatio or 0.5
    hRatio = hRatio or 0.5
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local parentSize = parent:getContentSize()
    local childSize = child:getContentSize()
    local childAp = child:getAnchorPoint()
    child:setPosition(
        parentSize.width * wRatio + (childAp.x - wRatio) * childSize.width + offsetX, 
        parentSize.height * hRatio + (childAp.y - hRatio) * childSize.height + offsetY
    )
end


