module("GuideManager", package.seeall)

local guideConfig = require "config/GuideConfig"

if GameConfig.isDebug then
    GameConfig.guideMode = guideConfig.guideMode
end

local levelConfig = guideConfig.level or {}

local funcOpenConfig = guideConfig.funcOpen or {}

local viewConfig = guideConfig.view or {}

local otherConfig = guideConfig.other or {}

local schedulerEntry = nil

local printTab = function() end
local gprint = function() end

-- 不产生间隔的步骤（除了是在引导流第一步的）(都是检查跳过的步骤)
local quickExecuteFunc = {
    requestFinish = true,
    checkEquip = true, -- 确保身上装备穿戴状态，exist,notExist,change(更换装备) 位置, 包含的三步引导的额外参数，跳过步数（默认后面全部）
    checkEmbed = true, -- 位置, (宝石镶嵌专用), 跳过步数（默认后面全部）
    sceneState = true, -- 场景状态检查 fight（战斗中） notFight（非战斗中）,跳过步数
    checkPet = true, -- 跳过步数（默认后面全部）
    checkMsgBox = true, -- 有弹窗处理  按钮
    checkChangeBtn = true, -- 主界面切换按钮  true展开/false 收起 , 引导说明额外参数,
    viewLimit = true, -- 界面限制
    checkEquipSystem = true, -- 检查某部位装备是否开启了某系统，否跳过{checkFoster, 部位, 系统标记，跳过步数}
    checkEquipsN = true, -- {checkEquipsN, 跳过步数}
    checkPush = true, -- 检测推送图标 {"checkPush", id, 跳过步数}
    missionComplete = true, -- 前端完成任务
    checkSkill = true, -- 是否有技能手指出现 {"checkSkill", skillType(1boss2小怪3竞技), 跳过步骤}
}

-- 用于判断的函数
local guideFunc = {}

-- 当前引导的状态
local state = {
    isMission = false 
}
-- 任务的箭头
local missionTip
local closeGuideTip

-----------------------------
-- 引导缓存数据
-----------------------------

local buffer = {} -- 可引导数据缓存
--local buffer = {
--        [1] = {
--                [1] = 2,
--                firstMark = "",
--                block = true,
--                ctl = "GuideController",
--                times = -1,
--                func = "openFuncOpenView",
--
--                param = {
--                        [1] = "SkillController",
--
--                },
--        },
--        [2] = {
--                [1] = 0,
--                [2] = "SkillController",
--        },
--        [3] = {
--                [1] = "checkChangeBtn",
--                [2] = true,
--                [3] = {
--                        [1] = 3,
--                        [2] = "点这里展开",
--
--                },
--                firstMark = "",
--                isMission = true,
--                block = true,
--                noFightLimit = true,
--                times = -1,
--        },
--        [4] = {
--                [1] = 1,
--                [2] = "MainUIView",
--                [3] = "SkillController",
--                [4] = {
--                        [1] = 1,
--                        [2] = "点这里查看",
--
--                },
--                noFightLimit = true,
--                isMission = true,
--        },
--        [5] = {
--                [1] = 1,
--                [2] = "SkillView",
--                [3] = 1,
--                [4] = {
--                        [1] = 1,
--                        [2] = "恭喜你获得",
--
--                },
--                noFightLimit = true,
--                isMission = true,
--        },
--        [6] = {
--                [1] = 1,
--                [2] = "SkillSelectView",
--                [3] = 1,
--                [4] = {
--                        [1] = 2,
--                        [2] = "选择技能",
--                },
--                noFightLimit = true,
--                isMission = true,
--        },
--        [7] = {
--                [1] = "viewLimit",
--                noFightLimit = true,
--                isMission = true,
--        },
--        [8] = {
--                [1] = "requestFinish",
--                noFightLimit = true,
--                isMission = true,
--        },
--        [9] = {
--                [1] = 0,
--                isMission = true,
--        },
--        [10] = {
--                [1] = 2,
--                firstMark = "",
--                block = true,
--                ctl = "GuideController",
--                times = -1,
--                func = "openFuncOpenView",
--
--                param = {
--                        [1] = "SkillController",
--
--                },
--        },
--        [11] = {
--                [1] = 0,
--                [2] = "SkillController",
--        },
--}

local function insertToBuff(index, step, isMission)
    step.isMission = isMission
    table.insert(buffer, index, step)
end

--local state = {
--    isMission = false,
----    noViewLimit = false,
----    noFightLimit = false,
--}

--local function getStep(key)
--    return cc.UserDefault:getInstance():getIntegerForKey("guide_" .. gData.RoleData.model.role_id .. key)
--end
--local function setStep(key)
--    if key ~= "" then -- 无限次
--        local times = getStep(key)
--        cc.UserDefault:getInstance():setIntegerForKey("guide_" .. gData.RoleData.model.role_id .. key, (times and times + 1 or 1))
--    end
--end


-- 未进入战斗
local fightState = true

function setFightState(state)
    fightState = state
    if state then
        ctl.GuideMissionController:requestStat(12)
    end
end

function getFightState()
    return fightState
end

-- 当前副本类型
local curFbType = 1
function updateCurFightType(fightType)
    if fightType == 0 then --清0 
        if curFbType ~= 1 then -- 上一局非小怪类型才清
            curFbType = fightType
        end
    else
        if fightType == 1 and curFbType ~= 1 then
            curFbType = fightType
            checkMissionGuide()
        else
            curFbType = fightType
        end
    end
    if curFbType ~= 1 then -- 非打小怪
        reloadMissionBuff()
    end
    -- gprint(debug.traceback() .. "=== updateCurFightType = curFbType = " .. curFbType)
end


-- 当前是否有引导
local function hasStep()
    if buffer[1] then
        return true
    end
    return false
end


-- 是否引导过（userdata、最大等级、次数判断）
local function isGuided(guideInfo, userDataKey)
    if not guideInfo then gprint(debug.traceback()) end
    local tab = {
--        userData = (guideInfo.times ~= -1 and getStep(userDataKey) >= (guideInfo.times or 1)),
        level = (guideInfo.maxLv and gData.RoleData.model.level > guideInfo.maxLv or false),
    }
--    printTab(tab)

    local ret = tab.level --  or tab.userData
    if userDataKey then
        gprint(userDataKey .. "isGuided...." .. (ret and "true" or "false"))
    end

    return ret
end


local function addToBuffer(guideInfo, userDataKey)
    -- printTab(buffer)
    -- gprint("..............add to buffer before ... ")
    
    --  不要引导
    if GameConfig.isDebug and GameConfig.noGuide then
        return
    end

    if isGuided(guideInfo, userDataKey) then
        return
    end

    -- 开始标记
    if guideInfo[1] then
        local firstMark = guideInfo.times == -1 and "" or userDataKey
        if firstMark ~= "" then
            for i, v in ipairs(buffer) do
                if v.firstMark and v.firstMark == firstMark then
                    gprint("buffer中已有引导" .. firstMark)
                    return
                end
            end
        end

        guideInfo[1].firstMark = firstMark
        guideInfo[1].times = guideInfo.times
        guideInfo[1].block = true
        guideInfo[1].isMission = guideInfo.isMission
    end

    -- 限制标记，保存到每一步骤中
    for i, info in ipairs(guideInfo) do
        info.noViewLimit = guideInfo.noViewLimit
        info.noFightLimit = guideInfo.noFightLimit
        info.isMission = guideInfo.isMission
    end

    for i, info in ipairs(guideInfo) do
        table.insert(buffer, info)
    end

    -- 0 结束标记 (不需配置)
    insertToBuff(#buffer + 1, {0, userDataKey}, guideInfo.isMission)

    -- printTab(buffer)
    -- gprint(debug.traceback())
    gprint("..............add to buffer ... ")
    return true    
end


-- 引导限制检查
local function isViewGuidable(guideInfo)
    if not guideInfo.noViewLimit and ViewManager.hasOpenedView() then --有打开界面
        return false
    end
    return true
end

local function isFightGuidable(guideInfo)
    if not guideInfo.noFightLimit and not fightState then -- 进入战斗 
        return false
    end
    return true
end
-- 场景和界面限制判断
local function isGuidable(guideInfo)
    if guideInfo[1] == 0 then -- 结束标记
    	gprint("结束标记 isGuidable")
        return true
    end
    local stateTab = {
        ["isFightGuidable"] = isFightGuidable(guideInfo),
        ["isViewGuidable"] = isViewGuidable(guideInfo),
    }
--    printTab(stateTab)
    return stateTab.isFightGuidable and stateTab.isViewGuidable
end

-- 是否有一次可执行的引导
local function checkBlockStep()
    if #buffer > 0 and buffer[1].block then
        if buffer[1].firstMark then
            if isGuidable(buffer[1]) then
                -- 第一引导
                return true
            end
        else
            if not buffer[1].viewLimit or isViewGuidable(buffer[1]) then
                -- 后续引导 界面限制
                return true
            end
        end
    end
    return false
end


-- 执行暂停
local executeLock = false
-- 引导暂停
local guideLock = false
function setLock(state)
    guideLock = state
end

local reloadBuff

-----------------------------
-- 循环函数和数据
-----------------------------
local execureSucc = true
local executable = false
local dt = 0.1
local count = 0 -- 引导超时5s跳过
local updateMissionBtnStateFunc = function()end
local function loopFunc()
    if not hasStep() then
        if not ctl.GuideMissionController:hasTip() and not ViewManager.hasOpenedView() then
            updateMissionBtnStateFunc(true) -- 主界面任务按钮光效
        else
            updateMissionBtnStateFunc(false) -- 主界面任务按钮光效
        end
        return
    else
        updateMissionBtnStateFunc(false) -- 主界面任务按钮光效
    end
    
    if guideLock then
--        gprint(" guideLock locked ... 可能期间报错")
        return 
    end
    
    if executeLock then
--        gprint(" executeLock locked ... 可能期间报错")
        return 
    end

    -- 当前的引导可执行
    if checkBlockStep() then
        executable = true
        -- 返回获取target是否成功
        execureSucc = execute()
    end

--    if not state.isMission then
--
--        -- 是当前执行引导且符合执行条件，超过5s没获取到target，跳过
--        if executable and not execureSucc then
--            count = count + dt
--            if count > 5 then
--                reloadBuff()
--                count = 0
--                ctl.GuideController:closeTip()
--            end
--        else
--            count = 0
--        end
--    end

    executable = false
    execureSucc = true
end


-----------------------------
-- 初始引导、定时器
-----------------------------
function init()    
    local canGuide = false

    local openModels = gData.MainUIData.getOpenModels()

    -- 检查需要的 等级、功能开启引导
    for i, info in ipairs(guideConfig.steps) do
        local userDataKey = info[1] .. info[2]
        local guideInfo = guideConfig[info[1]] and guideConfig[info[1]][info[2]]
        if guideInfo then
            canGuide = false
            if info[1] == "level" then
                if gData.RoleData.model.level >= info[2] then
                    canGuide = true
                end 
            elseif info[1] == "funcOpen" then
                -- 功能开放查询
                if helper.isContainValue(openModels, info[2]) then
                    userDataKey = info[2]
                    canGuide = true
                end
            elseif info[1] == "other" then
                userDataKey = info[2]
                canGuide = true
            end

            if canGuide then
                addToBuffer(guideInfo, userDataKey)
            end
        else
            gprint("引导" .. userDataKey .. "已不存在")
        end
    end

    -- 定时器 0.32 （用于检查中断的引导）
    -- local scheduler = cc.Director:getInstance():getScheduler()
    -- if schedulerEntry then
    --     scheduler:unscheduleScriptEntry(schedulerEntry)
    --     schedulerEntry = nil
    -- end
    if schedulerEntry then
        TimerManager.unscheduleGlobal(schedulerEntry)
        schedulerEntry = false
    end
    local mainUIController = ctl.MainUIController
    updateMissionBtnStateFunc = function(state)
        local missInfo = gData.GuideMissionData.getInfo()
        if missInfo and missInfo.index and missInfo.index <= guideConfig.indexForMissionBtnLight then
            mainUIController:updateMissionBtnState(state) -- 保存到local        
        end
    end
    -- schedulerEntry = scheduler:scheduleScriptFunc(loopFunc, dt, false) 
    schedulerEntry = TimerManager.scheduleGlobal(loopFunc, dt)        
    -- 请求任务数据
    ctl.GuideMissionController:requestInfo()
    
    --    gprint("...............init ... ")
end

-----------------------------
-- 删除引导
--  deleteCount指定删除步数 （可选，默认删除完整的一个引导）
--  startIndex从某步骤开始reload （可选）
-----------------------------
function reloadBuff(deleteCount, startIndex)
--    printTab(buffer)
--    gprint("..... ....reloadBuff before............")

    if deleteCount and type(deleteCount) ~= "number" then
        deleteCount = nil
    end
    
    startIndex = startIndex or 1
    
    local oldFirstMark 
    if buffer[1] then
        oldFirstMark = buffer[1].firstMark
    end

    local insertMark 
    local temp = {}
    -- 删除剩余全部
    local count = 1
    for i = startIndex, #buffer do
        local info = buffer[i]
        
        if insertMark then  --删除到了下一个引导
            table.insert(temp, info)
        else
            if deleteCount and count > deleteCount then -- 大于删除步数的不删除
                table.insert(temp, info)
            else
                if info.firstMark and i~= 1 then --(not oldFirstMark or oldFirstMark ~= info.firstMark) then
                    insertMark = true
                    table.insert(temp, info)
                end
            end
        end
        count = count + 1
    end

    buffer = temp
    if #buffer == 0 then
        ctl.GuideController:closeTip()
    end
    if startIndex == 1 then
        nextStep()
        state.isMission = false
    end

-- printTab(buffer)
--    gprint("..... ....reloadBuff after............")
--    gprint(debug.traceback())
end

-- 下一步
function nextStep()
    if buffer[1] then
        if quickExecuteFunc[buffer[1][1]] and checkBlockStep() then
            execute()
        end
        if buffer[1] then
            buffer[1].block = true
        end
    end
end

-----------------------------
--  执行
-----------------------------
local executeFunc
-- 返回获取target是否成功
function executeFunc()
    local succ = false    
    local info = buffer[1] 

    if info.firstMark then
        if not isGuidable(info) then
            gprint(" ... execute .. limited ..")
            nextStep()
            return
        end

        if isGuided(info, info.firstMark) then
            reloadBuff()
            return
        end

--        setStep(info.firstMark) -- 结束，记录到userdefault
       
        state.isMission = info.isMission
    end

    local guideType = info[1]
    local viewName = info[2]

    if guideType == 0 then
        state.isMission = false
        --        setStep(info[2]) -- 结束，记录到userdefault
        -- 结束标记
        if ctl.GuideController then
            ctl.GuideController:closeTip()
        end
        succ = true
    elseif guideType == 1 then
        --        1 手指指向按钮 {1, 界面, 对象索引, "描述"[可选], }
        local view

        if viewName == "MainUIView" then
            view = ctl.MainUIController.view
        end

        if not view then
            view = getRegisterView(viewName)
        end

        if not tolua.isnull(view) then
            -- 节点有动作时拦住(block)
            if not viewName == "MainUIView" or 
                (view.getNumberOfRunningActionsEx and view:getNumberOfRunningActionsEx() or view:getNumberOfRunningActions()) == 0 then --Ex为自定义的判断动作的函数
                local targetId = info[3]
--                if viewName == "MainFbView" then
--                    targetId = math.ceil(targetId / 3)
--                end
                
                local target = getGuideObject(viewName, targetId)

                if tolua.isnull(target) and view.getTarget then
                    target = view:getTarget(targetId)
                end

                if not tolua.isnull(target) 
                    and target:getNumberOfRunningActions() == 0 
                    and target:isVisible() then
                    --                    and (not target.isEnabled or target:isEnabled()) then
                    
                    -- 滚动关卡界面
                    if viewName == "MainFbView" and view.selectItemByTag then
                        --                    view:selectItemByTag(targetId)
                        ctl.MainFbController:openView(targetId)  
                    -- elseif viewName == "MirrorView" and string.find(targetId, "reward") and view.fixToBarrier then
                    --     view:fixToBarrier(3) -- 选中最前的奖励按钮
                    end
                    
                    if not info.isMission then
                        if viewName == "MainUIView" then -- 关闭所有界面
                            ViewManager.closeAllView()
                        end
                    end
                    gprint("guide === isMission " .. (info.isMission and "true" or "false"))
                    if info.isMission then -- 任务类型
                        missionTip = ctl.GuideMissionController:openTip(target, info[4]) -- 不锁屏的手指
                    else
                        ctl.GuideController:openTip(target, info[4]) -- 锁屏的
                    end
                    succ = true
                else
                    gprint("guide === tolua.isnull(target)" .. info[3])
                end
            else
                gprint("guide === view getNumberOfRunningActions ~= 0")
            end
        else
            gprint("guide === tolua.isnull(view)" .. viewName)
        end

    elseif guideType == 2 then
        helper.funcCall(info.ctl, info.func, info.param)
        table.remove(buffer, 1)
--        insertToBuff(1, {"viewLimit"}, info.isMission)-- 选中按钮
--        succ = true
        --        打开界面并点亮按钮{2, ctl =xx, func=xx, param=xx}
    elseif guideFunc[guideType] then
        guideFunc[guideType]()
    else
        gprint("没有可执行的guide func ..... ")
    end



    if succ then
        table.remove(buffer, 1)
    else
        --        ctl.GuideController:closeTip()
        nextStep() --重新执行本步
    end

    if guideType ~= 2 then
       -- printTab(buffer)
       -- gprint(debug.traceback())
    end
    gprint("...............execute  after... ")
    return succ
end 

-- 执行一次引导
execute = function()
    if not hasStep() then
        return
    end
    executeLock = true
    executeFunc()
    executeLock = false
end


-----------------------------
-- 等级引导
-----------------------------
function checkLevelGuide(level, oldValue)
    gprint("... checkLevelGuide .. old level = " .. oldValue .. ", cur level = " .. level)
    if oldValue >= level then
        return
    end

    for i = oldValue, level do
        if levelConfig[i] then
            local guideInfo = levelConfig[i]

            local userDataKey = "level" .. i
            addToBuffer(guideInfo, userDataKey)
        end
    end

end


-----------------------------
-- 功能开启引导
-----------------------------
function checkFuncOpenGuide(ctlName)
    gprint(debug.traceback())
    gprint("=========  checkFuncOpenGuide  功能开启" .. ctlName .. "  ==== !")
    -- 打开功能开启界面
    local ctlGuideInfo = {times=-1,firstMark="",
        {2, ctl = "GuideController", func = "openFuncOpenView", param = {ctlName}}}

    local guideInfo = funcOpenConfig[ctlName]
    if guideInfo then
        -- 加入引导
        for i, v in ipairs(guideInfo) do
            table.insert(ctlGuideInfo, v)
        end
    end

    addToBuffer(ctlGuideInfo, ctlName) 
end

-----------------------------
-- 界面打开引导
-----------------------------
function checkViewGuide(viewName)
    -- 检查打开界面下一步引导
    if not viewConfig[viewName] then
        return
    end

    -- 检查界面引导
    local guideInfo = viewConfig[viewName]
    if guideInfo then
        local userDataKey = viewName

        addToBuffer(guideInfo, userDataKey)
    end
end

-----------------------------
-- 其他特殊的引导条件（需要程序处理）
-----------------------------
function checkOtherGuide(param)
    if not otherConfig[param] then
        return
    end

    gprint("checkOtherGuide ... " .. param)
    local guideInfo = otherConfig[param]
    local userDataKey = param

    return addToBuffer(guideInfo, userDataKey)
end

-- 删掉任务箭头，只用于 isMissionGuidable() 的否判断 执行
function closeGuideTip()
    -- 需要确定是否有其他问题 ok了再注释回来
   -- if not tolua.isnull(missionTip) then
   --     missionTip:close()
   --     gprint("=== = = 删掉任务箭头")
   -- end
end

--  找到任务类型的引导，并删除（reloadBuff）
function reloadMissionBuff()
    if not hasStep() then
        return
    end
    
--    printTab(buffer)
    gprint(" ===   reloadMissionBuff before --=== ")
    while true do
        local hasMission = false
        for i, info in ipairs(buffer) do
            if info.isMission then
                reloadBuff(nil, i)
                hasMission = true
                break 
            end
        end
        if not hasMission then
            break
        end
    end
    
end

-----------------------------
-- 任务引导 , ps:多次调用需要进行条件判断(使用checkMissionGuide)
-----------------------------
local checkMissionLimit

-- 无限制的  -- (点击任务按钮触发)
function startMissionGuide()
    --printTab(buffer)
    reloadMissionBuff()

    local guideInfo = gData.GuideMissionData.getBuffer()
    --printTab(guideInfo)    
 
    guideInfo.times = -1
    guideInfo.noFightLimit = true
    guideInfo.firstMark = ""
    guideInfo.isMission = true -- 用于判断打开不锁屏的手指
    
    addToBuffer(guideInfo)
end


local function isMissionGuidable()
    printTab({
        ["gData.MainUIData.mainUIState"] = gData.MainUIData.mainUIState,
        ["fbType == 1"] = curFbType
    })
    gprint("====>>>>>>>> isMissionGuidable" .. (gData.MainUIData.mainUIState and "true" or "false"))
    return gData.MainUIData.mainUIState or (curFbType == 1)
end

-- 有配置限制的  -- (任务数据更新、关闭对话框触发)
function checkStartMissionGuide()
    if checkMissionLimit() then    
        return
    end
    if isMissionGuidable() then
        startMissionGuide()
    else
        closeGuideTip() -- 删掉任务箭头
    end
end

-- 自动重来(有场景、配置、界面、缓存限制的) -- (关掉界面、切换场景触发)
function checkMissionGuide()
    if not hasStep() and not ViewManager.hasOpenedView() then
        if isMissionGuidable() then
            gprint(debug.traceback() .. "======unregister 重新执行任务引导" .. getTimer())
            checkStartMissionGuide()
        else
            closeGuideTip() -- 删掉任务箭头
            reloadMissionBuff()
        end
    end
end

-- 条件限制
function checkMissionLimit()
    local missInfo = gData.GuideMissionData.getInfo()
    if missInfo.status ~= 0 then
        return true
    end
    if missInfo.type then
        local limit = guideConfig.missionGuideLimit[missInfo.type]
        if limit and gData.RoleData.model.level >= limit.level and gData.MainFbData.getMaxPassId() >= limit.barrierId then
            gprint("======  任务引导不再自动触发。true")
            printTab({
                ["RoleData.model.level"] = gData.RoleData.model.level,
                ["limit.level"] = limit.level,
                ["MaxBarrierId()"] = gData.MainFbData.getMaxPassId(),
                ["limit.barrierId"] = limit.barrierId,
                ["missInfo.type"] = missInfo.type,
            })
            return true
        end
    end
    gprint("======  任务引导自动触发。 false")
    return false
end

-----------------------------
-- 添加到队列的接口
-----------------------------
local keyRecord = {}

-- 删除相同key的引导
local function reloadQueue(key)
    for i, step in ipairs(buffer) do
        if step.executeKey == key then
            reloadBuff(nil, i)
        end
    end
end

-- 打开界面的操作添加到引导队列
function addToQueue(ctlName, funcName, param, executeKey)
    if hasStep() or ViewManager.hasOpenedView() then
        reloadMissionBuff()
        
        executeKey = executeKey or ctlName .. funcName
        local guideInfo = {times=-1,firstMark="", noFightLimit = true, executeKey = executeKey,
            {2, ctl = ctlName, func = funcName, param = {param}},
        }
        if keyRecord[executeKey] then
            -- 把相同的删去
            reloadQueue(executeKey)
            keyRecord[executeKey] = nil
        end
        keyRecord[executeKey] = true
        addToBuffer(guideInfo)
    else
        helper.funcCall(ctlName, funcName, {param})
    end
end


-----------------------------
-- 注册
-----------------------------
local registerView = {}
local objectTab = {}

-- 注册(非ViewManager控制的界面)
function register(view, viewName)
    viewName = viewName or view.__cname
    if not tolua.isnull(registerView[viewName]) then
        return 
    end

    gprint("register viewName = " .. viewName)
    registerView[viewName] = view

    if GameConfig.guideMode then
        local label = gui.newLabel(viewName, ui.color.green, ui.fontSize.max)
        label:setLocalZOrder(100)
        ui.addChildEx(label, view, math.random(), 1, cc.p(0.5, 1))
        ui.fadeInOut(label, 0, 0.2, 0.5, 1)
    end
end

function unregister(view, viewName)
    viewName = viewName or view.__cname
    gprint("====unregister  " .. viewName)

    if registerView[viewName] then
        registerView[viewName] = nil
    end

    if objectTab[viewName] then
        objectTab[viewName] = nil
    end
    
    checkMissionGuide()
end


function getRegisterView(viewName)
    gprint(".. getRegisterView ....")
    return registerView[viewName]
end


-----------------------------
-- 记录界面中的对象tag
-----------------------------
--local objectTab = {}

function setGuideObject(cName, object, tag)
    if not objectTab[cName] then
        objectTab[cName] = {}
    end

    if type(object) == "table" then
        local key = type(tag) == "number" and tag or 100

        for k, v in pairs(object) do
            objectTab[cName][key] = v

            if GameConfig.guideMode then
                local label = gui.newLabel(key, ui.color.green, ui.fontSize.max)
                label:setLocalZOrder(100)
                ui.addChildEx(label, v, math.random(), 1, cc.p(0.5, 1))
                ui.fadeInOut(label, 0, 0.2, 0.5, 1)
            end

            key = key + 100
        end
    else
        objectTab[cName][tag] = object
        if GameConfig.guideMode then
            local label = gui.newLabel(tag, ui.color.green, ui.fontSize.mid)
            label:setLocalZOrder(100)
            ui.addChildEx(label, object, 0.5, math.random(0, 80) * 0.01, cc.p(0.5, 1))
            ui.fadeInOut(label, 0, 0.2, 0.5, 1)
        end
    end
end

function getGuideObject(cName, tag)
    if objectTab[cName] and objectTab[cName][tag] then
        return objectTab[cName][tag]
    end
end


-----------------------------
-- 程序做的操作判断
-----------------------------


guideFunc["checkEmbed"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local isMission = guideInfo.isMission
        local loadPos = guideInfo[2]
        local putOnEquip = gData.GoodsData.getPutOnEquipByLoadPos(loadPos)
        if not putOnEquip then
            local equips = gData.EquipData.getBagEquips(loadPos, false, true)

            if equips then
                gprint("引导穿上...")
                local hasPunchEquip = false
                for i, equip in ipairs(equips) do
                    if gData.StoneData.checkPunchLimit(equip) then
                        -- 引导穿上
                        insertToBuff(1, {1, "MainUIView", "PetController"}, isMission)
                        insertToBuff(2, {1, "RoleView", 1}, isMission)
                        insertToBuff(3, {1, "EquipSelectView", i}, isMission)
                        nextStep()

                        hasPunchEquip = true
                        break
                    end
                end

                if not hasPunchEquip then
                    gprint("没有有孔装备...")
                    reloadBuff(guideInfo[3])
                end
            else
                -- 没有装备
                gprint("没有装备...")
                reloadBuff(guideInfo[3])
            end
        else
            gprint("身上有装备...")
            local stones = gData.GoodsData.getBagGoodsStone()
            if stones and #stones > 0 then
                if gData.StoneData.checkPunchLimit(putOnEquip) then
                    -- 引导
                    insertToBuff(1, {1, "MainUIView", "PetController"}, isMission)
                    insertToBuff(2, {1, "RoleView", 1}, isMission)
                    nextStep()
                else
                    gprint("不是可镶嵌装备...")
                    reloadBuff(guideInfo[3])
                end
            else
                gprint("但是背包没有宝石...")
                reloadBuff(guideInfo[3])
            end
        end
    end
end


guideFunc["checkEquip"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local isMission = guideInfo.isMission
        local checkType = guideInfo[2]
        local loadPos = guideInfo[3]

        if checkType == "exist" then
            if not gData.GoodsData.getPutOnEquipByLoadPos(loadPos)  then
                local equips = gData.EquipData.getBagEquips(loadPos, false, true)
                if equips and #equips > 0 then
                    local exInfo = guideInfo[4]
                    -- 引导穿上
                    insertToBuff(1, {1, "MainUIView", "PetController", exInfo[1]}, isMission)
                    insertToBuff(2, {1, "RoleView", loadPos, exInfo[2]}, isMission)
                    insertToBuff(3, {1, "EquipSelectView", 1, exInfo[3]}, isMission)
                    nextStep()

                    gprint("引导穿上...")
                else
                    -- 没有装备
                    gprint("没有装备...")
                    reloadBuff(guideInfo[5])
                end
            else
                reloadBuff(guideInfo[5])
            end
        elseif checkType == "change" then
            gprint("没有装备跳过本引导...")
            local putOnEquip = gData.GoodsData.getPutOnEquipByLoadPos(loadPos)
            if not putOnEquip then
                reloadBuff(guideInfo[5])
            else
                local hasBetter = false
                local bagEquips = gData.GoodsData.getBagGoodsByBagType(1)
                for k, model in pairs(bagEquips) do
                    if model.id ~= putOnEquip.id then
                        if model:getEquipScore() > putOnEquip:getEquipScore() then
                            hasBetter = true
                            break
                        end
                    end
                end 
                if not hasBetter then
                    reloadBuff(guideInfo[5])
                else
                    nextStep()
                end
            end
        elseif checkType == "notExist" then
            if gData.GoodsData.getPutOnEquipByLoadPos(loadPos)  then
                -- 已有装备就跳过该引导
                gprint("已有装备就跳过该引导 ... ")
                reloadBuff(guideInfo[4])
            else
                nextStep()
            end
        end
    end
end

guideFunc["checkEquipSystem"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local model = gData.GoodsData.getPutOnEquipByLoadPos(guideInfo[2])
        if model and gData.EquipData.checkFunc(guideInfo[3], model) then
            nextStep()
        else
            reloadBuff(guideInfo[4])
        end
    end
end


guideFunc["sceneState"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local checkType = guideInfo[2]
        if checkType == "fight" then
            if gData.MainUIData.mainUIState == true then -- 主城
                -- 加入切换场景引导
                gprint("加入切换场景引导1")
                insertToBuff(1, {1, "MainUIView", "FightController", guideInfo[3] or {2,"点击返回"}}, guideInfo.isMission)
            end
        elseif checkType == "notFight" then
            if gData.MainUIData.mainUIState == false then -- 战斗
                -- 加入切换场景引导
                gprint("加入切换场景引导2")
                insertToBuff(1, {1, "NewFightView", "return", guideInfo[3] or {2,"点击返回"}}, guideInfo.isMission)
            end
        end
        nextStep()
    end
end

guideFunc["checkPet"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        if gData.PetData.isPetBagEmpty() then
            reloadBuff(guideInfo[2])
        else
            nextStep()
        end
    end
end

guideFunc["checkMsgBox"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local view = getRegisterView("MsgBox")
        if not tolua.isnull(view) then
            if view.okCb_ then
                view.okCb_(guideInfo[2] or 2)
            end
            view:close()
        end
        nextStep()
    end
end

guideFunc["checkChangeBtn"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local view = ctl.MainUIController.view
        if not tolua.isnull(view) and view.changeBtn then
            if view.changeBtn.showBtn__ ~= guideInfo[2] then
                gprint("加入主界面切换按钮引导")
                insertToBuff(1, {1,"MainUIView", "change", guideInfo[3]}, guideInfo.isMission)
            end
        end
        nextStep()
    end
end

guideFunc["viewLimit"] = function()
    table.remove(buffer, 1)
    ctl.GuideController:closeTip()
    if #buffer > 1 then
        buffer[1].viewLimit = true -- viewLimit是非第一步的步骤专用
    end
    nextStep()
end

guideFunc["checkEquipsN"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        if gData.MainUIData.getNoticeGuideInfo("equip") ~= 0 then
            nextStep()    
        else
            reloadBuff(guideInfo[2])
        end
    end
end

guideFunc["checkPush"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local target = getGuideObject("PushView", guideInfo[2])
        if not tolua.isnull(target) then
            nextStep()    
        else
            reloadBuff(guideInfo[3])
        end
    end
end


-- 请求完成任务
guideFunc["requestFinish"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local missionId = guideInfo.missionId
        if missionId == gData.GuideMissionData.getMissionId() then
            gprint("============== requestFinish 请求完成")
            --        TipMsg.show("== requestFinish 请求完成")
            reloadMissionBuff()
            ctl.GuideMissionController:requestFinish(missionId)
            gData.GuideMissionData.clearInfo()
            nextStep()
        else
            gprint("当前任务已id已不相同 old = " .. missionId .. ", new = " .. gData.GuideMissionData.getMissionId())
        end
    end
end

-- 是否有家族
guideFunc["checkFamily"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        if gData.RoleData.model.family_id > 0 then
            for i = #guideInfo[2], 1, -1 do
                insertToBuff(1, guideInfo[2][i])
            end
        else
            for i = #guideInfo[3], 1, -1 do
                insertToBuff(1, guideInfo[3][i])
            end
        end
    end
end

-- 是否可以引导技能
guideFunc["checkSkill"] = function()
    local guideInfo = table.remove(buffer, 1)
    if guideInfo then
        local skillType = guideInfo[2]
        if (gData.SkillData.isFingerGuidable(skillType)) then
            nextStep() --继续执行
        else
            reloadBuff(guideInfo[3]) --跳过本次引导
        end
    end
end


