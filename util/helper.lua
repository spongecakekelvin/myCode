--------------------------
-- helper
-- 常用的方法
--------------------------

helper = helper or {}


-- node监听时间的节点
-- swallow是否吞噬事件
-- priority 不为0或nil 则是按优先度触发， 否则按场景绘制顺序触发
-- typeName 事件类型 "OneByOne"单点 , "AllAtOne"多点 
helper.addTouch = function(param)
    local node = param.node
    if tolua.isnull(node) then
        print("触摸对象为nil")
        return
    end
    
    local swallow = param.swallow
    local priority = param.priority
    local typeName = param.typeName or "OneByOne"

    local listener
    if typeName == "OneByOne" then
        listener = cc.EventListenerTouchOneByOne:create()
    elseif typeName == "AllAtOnce" then
        listener = cc.EventListenerTouchAllAtOnce:create()
    elseif typeName then
        if cc["EventListenerTouch" .. typeName] then
            listener = cc["EventListenerTouch" .. typeName]:create()
        else
            Log.e("EventListenerTouch 类型 " .. typeName .. " 不存在")
        end
    end
    
    if listener then
        node.onTouchBegan = node.onTouchBegan or function() print("触摸对象没设置函数onTouchBegan") end
        node.onTouchMoved = node.onTouchMoved or function() print("触摸对象没设置函数 onTouchMoved") end
        node.onTouchEnded = node.onTouchEnded or function() print("触摸对象没设置函数 onTouchEnded") end
        node.onTouchCanceled = node.onTouchCanceled or function() print("触摸对象没设置函数 onTouchCanceled") end
        
        listener:registerScriptHandler(function(touch, event)return node.onTouchBegan(node, touch, event)end,cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)return node.onTouchMoved(node, touch, event)end,cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)return node.onTouchEnded(node, touch, event)end,cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)return node.onTouchCanceled(node, touch, event)end,cc.Handler.EVENT_TOUCH_CANCELLED)
        
        if swallow ~= nil then
            listener:setSwallowTouches(swallow)
        end

        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
--        if priority and priority ~= 0 then
--            eventDispatcher:addEventListenerWithFixedPriority(listener, priority)
--        else
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
--        end
    end
    return listener
end

helper.isTouch = function(node, touch)
    -- 父节点判断
    --    local target = node:getParent()
    --    if tolua.isnull(target) then
    --        return
    --    end
    --    local touchLocation = target:convertTouchToNodeSpace(touch)
    --    local bBox = node:getBoundingBox()
    --    if cc.rectContainsPoint(bBox, touchLocation) then
    --        return true --调用onTouchEnded
    --    end
    
    -- 子节点判断
    local locationInNode = node:convertToNodeSpace(touch:getLocation())
    local s = node:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)
    if cc.rectContainsPoint(rect, locationInNode) then
        return true --调用onTouchEnded
    end
    return false
end


function helper.setNodeEvent(self)
    if self.onNodeEvent_ok_ then
        return
    end
    self.onNodeEvent_ok_ = true
    local function onNodeEvent(event)
        --        pInfo("NodeEvent:" .. event .. " " .. self.__cname)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
            -- elseif "enterTransitionFinish" == event then
            --     self:onEnterTransitionFinish()
            -- elseif "exitTransitionStart" == event then
            --     self:onExitTransitionStart()
            -- elseif "cleanup" == event then
            --     self:onCleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end


function helper.setSwallow(listener, value)
    if nil == value then
        value = false
    end
    listener:setSwallowTouches(value)
end


function helper.remove(node, tag)
    if node and not tolua.isnull(node) then
        if tag and type(tag) == "number" then
            node:removeChildByTag(tag, cleanup)
        else
            node:removeFromParent(true) -- true cleanup
        end
    end
end


--得到一个key-value翻转的新表
function helper.reverseTable(tab)
    local reTab = {}
    for k, v in pairs(tab) do
        reTab[v] = k
    end
    return reTab
end






-- 重新加载模块
function helper.reload(filePath)
    package.loaded[filePath] = nil
    return require (filePath)
end


function helper.fadeFromTo(node, time, from, to)
    node:setOpacity(from or 0)
    local action = cc.FadeTo:create(time or 1, to or 255)
    node:runAction(action)
    return action
end



local spriteFrameCache = cc.SpriteFrameCache:getInstance()

function helper.addPlist(plistPath, image)
    if not plistPath then
        Log.e("资源路径为空 plistPath = " .. plistPath)
    end
    if image then
        spriteFrameCache:addSpriteFrames(plistPath, image)
    else
        spriteFrameCache:addSpriteFrames(plistPath)
    end
    gprint("添加资源+: " .. plistPath)
end

function helper.removePlist(plistPath)
    spriteFrameCache:removeSpriteFramesFromFile(plistPath)
    gprint("移除资源-: " .. plistPath)
end



