function ui.starEffect(node)
    local action
    local array = {}
    array[#array + 1] = cc.CallFunc:create(function()
        if not tolua.isnull(node) then
            node:setScale(1.5)
        end
    end)
    array[#array + 1] = cc.Spawn:create(
        cc.RotateBy:create(0.2, 360 * 1),
        cc.DelayTime:create(0.2)
    )
    array[#array + 1] = cc.DelayTime:create(0.3)
    array[#array + 1] = cc.Spawn:create(
        cc.DelayTime:create(0.3),
        --        cc.RotateBy:create(1, 360 * 2),
        cc.EaseBackIn:create(cc.ScaleTo:create(0.3, 1))
    )
    action = cc.Sequence:create(array)
    if not tolua.isnull(node) then
        node:runAction(action)
    end
    return action
end



function ui.shakeAction(duration)
    duration = duration or 0.1
    local shakeCount = 4
    local shakeTime = duration / shakeCount / 3
    return cc.Repeat:create(
        cc.EaseSineIn:create(cc.Sequence:create(
            cc.MoveBy:create(shakeTime, cc.p(10, 0)),
            cc.DelayTime:create(0.01),
            cc.MoveBy:create(shakeTime, cc.p(-10, 0))
        )),
        shakeCount
    )
end

function ui.splashEffect(node, shakeNode, callback)
    local action
    local array = {}
    array[#array + 1] = cc.CallFunc:create(function()
        if not tolua.isnull(node) then
            node:setScale(6)
        end
    end)
    array[#array + 1] = cc.ScaleTo:create(0.15, 1)
    array[#array + 1] = cc.CallFunc:create(function()
        if not tolua.isnull(shakeNode) then
            -- 星星粒子
            local tPar = gui.newPar_levelUp()
            ui.addPosTo(tPar, node)

            shakeNode:runAction(ui.shakeAction())
        end
    end)
    array[#array + 1] = cc.DelayTime:create(0.5)
    if callback then
        array[#array + 1] = cc.CallFunc:create(function() callback() end)
    end

    action = cc.Sequence:create(array)
    if not tolua.isnull(node) then
        node:runAction(action)
    end
    return action
end

function ui.turnOverAction(node)
    local action = cc.RepeatForever:create(cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1, 0),
        cc.ScaleTo:create(0.3, 1, 1),
        cc.DelayTime:create(3)
    ))
    if not tolua.isnull(node) then
        node:runAction(action)
    end
    return action
end