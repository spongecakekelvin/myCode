--------------------------
-- YuZhenjian
-- 2014年10月15日
-- 管理游戏中所有view的排版和布局
--------------------------
module("ViewManager", package.seeall)

local viewConfig = require("config/ViewConfig")

local viewAll = {} -- 全部已创建界面

local addView
local openScale

function init(dt)
    
end


----------------------------------
--  viewname： 界面名字
--  view: 界面
--  parent: 添加到的父节点
----------------------------------
function openView(view, parent, openType)
    if not view then
        Log.d("打开界面失败view nil")
        return
    end
    
    local viewName = view.__cname -- 类名
    if not viewName then
        Log.d("打开界面失败viewName nil")
        return
    end
--    Log.d("打开界面" .. viewName)
    
    if tolua.isnull(parent) then
        parent = SceneManager.windowLayer
    end
--Log.d("\n~~~~~~~~~~~~~~~~~~~~~~~~`")
    addView(viewName, view, parent, openType)
    
    openScale(view, function() 
    end)
--Log.d("\n==========================")
end


-- 返回bool (viewName 可以是类名或者界面的实例)
function closeView(viewName)
--    Log.d("关闭界面" .. viewName)
    if type(viewName) ~= "string" and viewName.__cname then
        viewName = viewName.__cname
    end
    
    if viewAll[viewName] then
        if not tolua.isnull(viewAll[viewName]) then
            viewAll[viewName]:removeFromParent()
            viewAll[viewName] = nil
            
            return true
        else
            viewAll[viewName] = nil
        end
    end
    
    return false
end


function closeAllView()
    for viewName, view in pairs(viewAll) do
        closeView(viewName)
    end

    viewAll = {}
end


function addView(viewName, view, parent, openType)
    Log.d("打开界面".. viewName)
    if viewAll[viewName] and not tolua.isnull(viewAll[viewName]) then
        Log.d("已存在界面".. viewName)
        closeView(viewName)
    end
    
    viewAll[viewName] = view 
    
    local openType = openType or (viewConfig.openType[viewName] or 1)
    
    if openType == 1 then
        if hasOpenedView() then
            closeAllView()
        end
        viewAll[viewName] = view
    elseif openType == 2 then
        -- 直接添加
        viewAll[viewName] = view
    end
    
--    Log.d("view open type = " .. openType)
    parent:addChild(view)
    ui.align(parent, view)
    
    -- 黑色透明层
    local tLayer = ui.newLayer(cc.c4b(0, 0, 0, 0))
    tLayer:setScale(1.2)
    helper.fadeFromTo(tLayer, 0.5, 0, 200)
    view:addChild(tLayer, -99)
    ui.align(view, tLayer)
end



-- 当前是否有界面显示
function hasOpenedView()
    local ret = false
    for k, view in pairs(viewAll) do
        -- FightStatView是一直存在的界面
        if not tolua.isnull(view) and view.__cname ~= "FightStatView" then
            ret = true
            break
        end
    end
    return ret
end

-- 获取当前打开界面实例
function getOpenedView(viewName)
    if viewName then
        Log.d("getOpenedView .. " .. viewName)
        return viewAll[viewName]
    else
        return (select(2, next(viewAll)))
    end
end

function openScale(view, callback)
    if not tolua.isnull(view) then
        if callback then
            callback()
        end
    end
end