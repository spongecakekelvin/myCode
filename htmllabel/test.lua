 -- test code
local testFunc

local labelparser = require("gamecore/ui/richlabel/labelparser")
require("gamecore/ui/richlabel/htmlparser")
local RichLabel = require("gamecore/ui/richlabel/RichLabel")

local Class
function Class(base, _ctor)
    local c = {}    -- a new class instance
    if not _ctor and type(base) == 'function' then
        _ctor = base
        base = nil
    elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    
    if TrackClassInstances == true then
        if ClassTrackingTable == nil then
            ClassTrackingTable = {}
        end
        ClassTrackingTable[mt] = {}
    local dataroot = "@"..CWD.."\\"
        local tablemt = {}
        setmetatable(ClassTrackingTable[mt], tablemt)
        tablemt.__mode = "k"         -- now the instancetracker has weak keys
    
        local source = "**unknown**"
        if _ctor then
        -- what is the file this ctor was created in?

        local info = debug.getinfo(_ctor, "S")
        -- strip the drive letter
        -- convert / to \\
        source = info.source
        source = string.gsub(source, "/", "\\")
            source = string.gsub(source, dataroot, "")
        local path = source

        local file = io.open(path, "r")
        if file ~= nil then
            local count = 1
            for i in file:lines() do
                if count == info.linedefined then
                        source = i
                -- okay, this line is a class definition
                -- so it's [local] name = Class etc
                -- take everything before the =
                local equalsPos = string.find(source,"=")
                if equalsPos then
                source = string.sub(source,1,equalsPos-1)
                end 
                -- remove trailing and leading whitespace
                        source = source:gsub("^%s*(.-)%s*$", "%1")
                -- do we start with local? if so, strip it
                        if string.find(source,"local ") ~= nil then
                            source = string.sub(source,7)
                        end
                    -- trim again, because there may be multiple spaces
                        source = source:gsub("^%s*(.-)%s*$", "%1")
                        break
                end
                    count = count + 1
            end
            file:close()
        end
        end
                             
        mt.__call = function(class_tbl, ...)
            local obj = {}
            setmetatable(obj,c)
            ClassTrackingTable[mt][obj] = source
            if c._ctor then
                c._ctor(obj,...)
            end
            return obj
        end    
    else
        mt.__call = function(class_tbl, ...)
            local obj = {}
            setmetatable(obj,c)
            if c._ctor then
               c._ctor(obj,...)
            end
            return obj
        end    
    end
        
    c._ctor = _ctor
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do 
            if m == klass then return true end
            m = m._base
        end
        return false
    end
    setmetatable(c, mt)
    return c
end


local function printList(list)
    local temp = {}
    for i, v in ipairs(list) do
        temp[#temp + 1] = tostring(v)
    end
    yzjprint(table.concat(temp, ","))
end

local qsort
-- 231
-- 131
-- 133
-- 123

function qsort(array, low, hight)
    if low >= hight then
        return
    end
    local key = array[low] -- 中轴值
    local left, right = low, hight

    while left < right do
        while left < right and array[right] >= key do -- right是右边界索引
            right = right - 1
        end
        array[left] = array[right]

        while left < right and array[left] <= key do -- -- left是左边界索引
            left = left + 1
        end
        array[right] = array[left]
    end
    array[left] = key -- 放到右边最小位置

    qsort(array, low, left - 1)
    qsort(array, left + 1, hight)
end


function bubblesort(array, low, hight)
    for i = low, hight do
        for j = hight, i + 1, -1 do
            if array[j] < array[j - 1] then
                array[j - 1], array[j] = array[j], array[j - 1]
            end
        end
    end
end


function insertsort(array, low, hight)
    for i = low + 1, hight do
        local key = array[i]
        local j = i - 1
        while j >= low and array[j] >= key do
            array[j + 1] = array[j] --右移
            j = j - 1
        end
        if j ~= i - 1 then
            array[j + 1] = key
        end
    end
end

local linknode = {}
-- function linknode.new(val, left, right)
function linknode.new(node)
    -- local node = {val = val, left = left, right = right}
    node = node or {}
    return setmetatable(node, {__index = linknode})
end
function linknode:print()
    printTable(self)
end

-- binary tree
local bt = {}

function bt.new(array)
    local self = bt.create()
    -- yzjprint("==== create 22 ", tostring(self), tostring(bt), tostring(getmetatable(self)), tostring(self.make))
    -- printTable(bt)
    self:make(array)
    return self
end

function bt.create()
    local mt = {}
    mt.firstnode = linknode.new()
    return setmetatable(mt, {__index = bt})
end

function bt:make(array)
    assert(type(array) == "table", "list is nil, table expected.")
    -- todo 平行二叉树

    self.firstnode = linknode.new()
    local len = #array
    if len > 0 then
        self.firstnode.val = array[1]
        
        for i = 2, len do
            local parentnode = self.firstnode
            local tempnode = parentnode
            local leftorright -- 1左 2右

            while tempnode do
                parentnode = tempnode
                if array[i] > tempnode.val then
                    tempnode = tempnode.left
                    leftorright = 1
                else
                    tempnode = tempnode.right
                    leftorright = 2
                end
            end
 
            local node = linknode.new{val = array[i]}
            if leftorright == 1 then
                parentnode.left = node
            else
                parentnode.right = node
            end
        end
    end
    return self.firstnode
end

function bt:traverse(node, func)
    if not node then
        return
    end
    self:traverse(node.right, func)
    func(node.val)
    self:traverse(node.left, func)
end

function bt:print()
    if not self.firstnode then
        return
    end
    self:traverse(self.firstnode, yzjprint)
end




 function testFunc_1(self)
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
    textlist[#textlist + 1] = "<font color='#23e342'>兑换说明：</font><br/><br/>1、每日可兑换<font color='#23e342'>20</font>次，每次消耗<font color='#23e342'>5000W</font>经验，兑换5000修为；<br/>2、兑换消耗：<font color='#23e342'>20W</font>绑定铜币；<br/>3、VIP每日可领取增加兑换修为次数的<font color='#23e342'>修为兑换石</font>。"
    textlist[#textlist + 1] = "<font color='#FF00'><a href='event:OPEN_OPENSERVERACT_PANEL|3'> <u>详情点击查看 </u></a></font>"
    textlist[#textlist + 1] = "对狂战士增加攻击力126<br/><br/>圣器效果随圣器等级提高而提升<br/><br/>获取途径：<br/><font color='#23e342'>开服活动、累计充值</font><br/><font color='#23e342'>进阶返利、BOSS掉落</font><br/><font color='#23e342'>玩家分享</font>"
    textlist[#textlist + 1] = "abc<br/><br/><br/>defg"
    textlist[#textlist + 1] = '<font color="#16ffca" start_color="#16ffca" end_color="#ff42ff" >[真理手镯（右）]</font>'

    for i, text in ipairs(textlist) do
        -- do break end
        local label = RichLabel.new{maxWidth = 370, fontSize = 22, lineSpace = 0, callback = function(id, name, href, x, y)
            yzjprint("==== RichLabel link touch!! ", id, name, href, x, y)
        end}
        self.testLabel = label
        label:setString(text)
        label:debugDraw()
        ui.addChild(self, label, 42 + i * 10, 153 + i * 10, nil, nil, 999)
    end

    yzjprint("time1 = ", getTimers())

    -- 从小到大排序
    -- local array = {3,6,1,9,2,5,4,7,8, 0}
    -- qsort(array, 1, #array)
    -- printTable(array)

    -- local array = {3,6,1,9,2,5,4,7,8, 0}
    -- bubblesort(array, 1, #array)
    -- printTable(array)

    -- local array = {3,6,1,9,2,5,4,7,8, 0}
    -- insertsort(array, 1, #array)
    -- printTable(array)

    local array = {3,6,1,9,2,5,4,7,8, 0}
    local tree = bt.new(array)
    tree:print() -- 右序遍历 从小到大
    tree.firstnode:print()
    -- local tree = bt.create()
    -- tree:make(array)
    -- tree:print()

    -- 文件操作
    -- local fileName = "gamecore/ui/richlabel/testFile.lua"
    -- -- local path = "testFile.lua"
    -- local path = cc.FileUtils:getInstance():getWritablePath().. "../../src/"..fileName
    -- local path = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    -- yzjprint(path)
    -- local content = cc.FileUtils:getInstance():getStringFromFile(path)
    -- yzjprint(content)
    -- local file = io.open(path, "r")
    -- if file then
    --     local content = file:read("*a")
    --     yzjprint(content)
    --     yzjprint(file:seek("end"))
    --     io.close(file)
    -- end
end

function testFunc_2(self)
    local Widget = Class(function(self, name)
        self.name = name or "Widget"
    end)
    local Screen = Class(Widget, function(self)
        Widget._ctor(self, "Screen")
    end)
    local screen = Screen()
    yzjprint(screen.name, type(Screen), type(Widget), type(screen)) -- __call
    -- local baseClass = {name= "bc"}
    -- local bc = baseClass()
    -- yzjprint(bc.name)

    function debuglocals (level)
        local t = {}
        local index = 1
        while true do
                local name, value = debug.getlocal(level + 1, index)
                if not name then break end
                t[index] = string.format("%s = %s", name, tostring(value))
                index = index + 1
        end
        return table.concat(t, ",\n")
    end
    yzjprint("debuglocals = ", debuglocals(1))

    function dumptable(obj, indent, recurse_levels)
        indent = indent or 1
        local i_recurse_levels = recurse_levels or 10
        if obj then
            local dent = ""
            if indent then
                for i=1,indent do dent = dent.."\t" end
            end
            if type(obj)==type("") then
                gprint(obj)
                return
            end
            for k,v in pairs(obj) do
                if type(v) == "table" and i_recurse_levels>0 then
                    gprint(dent.."K: ",k)
                    dumptable(v, indent+1, i_recurse_levels-1)
                else
                    gprint(dent.."K: ",k," V: ",v)
                end
            end
        end
    end
    dumptable({
        a = 1,
        {b = 2, c = 3, d = 2},
        {b = 2, c = 3, d = 2},
        {b = 2, c = 3, d = 2},
        {b = 2, c = 3, d = 2},
        {b = 2, c = 3, d = 2},
        apple = "babanan",
    })
end


function testFunc_3(self)
    local btn = ui.UIButton.new({
        images = { normal = "#login/login.png", pressed = "#login/login2.png", disabled = "#login/login.png" },
        btnName = "PLAY",
    })
    btn:onClick(self, function()
        GameMusicManager.playMusic()
    end)
    ui.addChild(self, btn, 200, 100)

    local btn = ui.UIButton.new({
        images = { normal = "#login/login.png", pressed = "#login/login2.png", disabled = "#login/login.png" },
        btnName = "PLAY",
    })
    btn:onClick(self, function()
        GameMusicManager.stopMusic()
    end)
    ui.addChild(self, btn, 350, 100)
end


local visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
function testFunc_4(self)
    local time = -1
    local num = 60
    -- local par = cc.ParticleSnow:createWithTotalParticles(num)
    local par = cc.ParticleSystemQuad:create("particle/snow_1.plist")
    -- par:setAutoRemoveOnFinish(true)
    par:setSpeed(90)
    local lifetime = visibleRect.height / 90 / 2
    par:setLife(lifetime)
    par:setLifeVar(lifetime)
    par:setPosVar(cc.p(visibleRect.width/4, 0))
    ui.addChild(self, par, visibleRect.width/2, visibleRect.height, 100)
    return par
end




function testFunc_5(self)
    cc.utils:captureScreen(function(suc,name)
            yzjprint(suc,name)
        end, "screenshot.png")
    -- ui.screenshot(nil, function(texture, winSize)
    --     -- local  screenShotSpr = cc.Sprite:createWithTexture(texture)
    --     local program = cc.GLProgram:createWithFilenames("shaders/noMvp.vsh","shaders/Blur.fsh")
    --     local gl_program_state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    --     texture:setGLProgramState(gl_program_state)
    -- end)

    return par
end


function testFunc_6(self)
    local text = {}
    table.insert(text, "有一堆2星式神，将其中一个培养成5星需要多少什么？")
    table.insert(text, "1个3星式神需要2个2星0级式神, 1个2星20级式神")
    table.insert(text, "1个4星式神需要3个3星0级式神, 1个3星25级式神")
    table.insert(text, "1个5星式神需要4个4星0级式神, 1个4星30级式神")
    table.insert(text, "设2/3/4/5星0级式神为x/y/z/f(x), 20/25/30级经验为a/b/c,以上公式为")
    table.insert(text, "y=3x+a")
    table.insert(text, "z=4y+b")
    table.insert(text, "f(x)=5z+c")
    table.insert(text, "∴ f(x)=5(4(3x+a)+b)+c")
    table.insert(text, "化简所得 f(x)=60x+20a+5b+c")
    table.insert(text, "其中百度得 a=149990, b=149990+191420= 341410, c=149990+191420+335030= 676440")
    table.insert(text, "化简所得 f(x)=60x+2999800+1707050+676440 = 60x+5383290")
    table.insert(text, "估算每场战斗每个式神场均经验为600")
    table.insert(text, "每场除了两个狗粮队长外，战斗有3个狗粮，观战有2个狗粮（一半经验），换算成4个狗粮")
    table.insert(text, "5383290经验需要战斗场数为 5383290/4/600 = 2243.0375 ≈ 2243 (场)")

    -- 1.56x>1.23x+2.11
    -- 0.33x>2.11
    -- x>6


end




local tabIndex = 0
local  function tab2str (tab)
    if type(tab) ~= "table" then
        return tab
    end
    local keytab = {}
    for k,v in pairs(tab) do
        table.insert(keytab,k)
    end
    table.sort(keytab,function(a,b)
        return (a < b)
    end)

    tabIndex = tabIndex + 1
    local tabStr = "\n"
    for i = 1, tabIndex do
        tabStr = tabStr .. "\t"
    end

    local s = ""
    for i,key in ipairs(keytab) do
        local v = tab[key]
        local keystr = key
        if type(key) == "number" then
            keystr = "[".. key .."]"
        end

        if type(v) ~= "table" then
            s = s .. tabStr .. tostring(keystr) .. "=".. tostring(v) ..","
        else
            s = s .. tabStr .. tostring(keystr) .. " = {".. tab2str(v).."},\n"
        end
    end

    tabIndex = tabIndex - 1
    return s
end
function testFunc_7(self)
    local path = cc.FileUtils:getInstance():getWritablePath().. "../../src/FindResults.lua"
    local file = io.open(path, 'r')
    local dirs = {}
    local marks = {}
    -- if file then
        local s = file:read("*a")
        -- for dir, name in string.gmatch(s, "#(%a+)/([%a_]+).png") do
        for dir, name in string.gmatch(s, "#([stall]+)/([%a_]+).png") do
            if not dirs[dir] then
                dirs[dir] = {}
            end
            local mark = dir .. name
            if not marks[mark] then
                table.insert(dirs[dir], name)
                marks[mark] = true
            end
        end
        io.close(file)
    -- end

    for k, v in pairs(dirs) do
        table.sort(v, function(a, b)
            return string.byte(a, 1) < string.byte(b, 1)
        end)
    end
    printTable(dirs)

    local path = cc.FileUtils:getInstance():getWritablePath().. "../../src/results.lua"
    local file = io.open(path, 'w')
    local s = "return {".. tostring(tab2str(dirs)).."}"
    file:write(s)
    io.close(file)


end

function testFunc_8(self)
    local path = cc.FileUtils:getInstance():getWritablePath().. "../../res/allPlist/com1mon.plist"
    local file = io.open(path, 'r')
    if file then
        local jsonStr = file:read("*a")
        -- yzjprint(jsonStr)
        -- local ret = require("json").decode(jsonStr)
        -- -- printTable(ret, yzjprint)
        io.close(file)
    end

    for i = 1, 5 do
        local spr = ui.newSpr("#common/elementhp" .. i .. ".png")
        ui.addChild(self, spr, 42 + i * 10, 153 + i * 10, nil, nil, 999)
    end
end



return testFunc_8