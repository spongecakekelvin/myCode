

-- 从文件读取
-- 格式， 帧数，总时间（开始索引, 节点）
function ui.newAnimFile(format, num, time, startIndex, times, spr)
    if tolua.isnull(spr) then
        spr = cc.Sprite:create()
    end
    
    startIndex = startIndex or 1
    
    local animation = cc.Animation:create()
    
    for i = startIndex, num - (1 - startIndex) do
--        gprint(string.format(format, i))
        animation:addSpriteFrameWithFile(string.format(format, i))
    end
    
    animation:setDelayPerUnit(time / num)
    animation:setRestoreOriginalFrame(true)
    
    local action = cc.Animate:create(animation)
    if times and times == -1 then
        spr:runAction(cc.RepeatForever:create(action))
    else
        spr:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
            if not tolua.isnull(spr) then
                spr:removeFromParent()
            end
        end)))
    end
    return spr
end


-- 从帧缓存读取
-- 动画名字， (一次动画的时间, 循环次数)默认
function ui.newAnim(animName, time, loops)
    local config = gfile.EffectAnimConfig[animName]
    if not config then
        gprint("EffectAnimConfig没有效果动画配置" .. animName .. "！")
        return
    end
    
    loops = loops or config.loops
    time = time or config.time

    local frameCache = cc.SpriteFrameCache:getInstance()  
    local tab = {}
    
    for i = config.startIndex, config.frameCount - (1 - config.startIndex) do
        local frame = frameCache:getSpriteFrame(string.format(animName .. config.path, i))
        if frame then
            table.insert(tab, frame)
        end
    end
    
    local spr = cc.Sprite:create()
    
    if #tab >= 1 then
        local animation = cc.Animation:createWithSpriteFrames(tab, time / config.frameCount)
        -- animation:setLoops(-1)
        -- animation:setDelayPerUnit(time/num)
        local action = cc.Animate:create(animation)
        if loops == -1 then
            spr:runAction(cc.RepeatForever:create(action))
        else
            spr:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                if not tolua.isnull(spr) then
                    spr:removeFromParent()
                end
            end)))
        end
    else
        gprint("效果动画" .. animName .."没有动画帧！")
    end  

    return spr
end


