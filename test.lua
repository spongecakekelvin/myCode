 -- test code
local labelparser = require("gamecore/ui/richlabel/labelparser")
require("gamecore/ui/richlabel/htmlparser")
local RichLabel = require("gamecore/ui/richlabel/RichLabel")

local function printList(list)
    local temp = {}
    for i, v in ipairs(list) do
        temp[#temp + 1] = tostring(v)
        temp[#temp + 1] = ","
    end
    temp[#temp] = nil
    yzjprint(table.concat(temp))
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
    -- 平行二叉树
    -- local low = 1
    -- local hight = #array
    -- local key = array[low]
    -- while low < hight do
    --     while low < hight and array[hight] >= key do
    --         hight = hight - 1
    --     end
    --     array[low] = array[hight]

    --     while low < hight and array[low] <= key do
    --         low = low + 1
    --     end
    --     array[hight] = array[low]
    -- end
    -- array[low] = key

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




 return function(self)
    if not ui.addPlist("allPlist/expression.plist") then return end
 -- local text = "CLICK <a href='http://example.com/'>here!</a>"
    -- local text = [[奥斯卡的卷发洛杉矶佛按摩法<font face="font21" color ='#f39800'>kkk<cs id="$34"/>hh</font>]]
    -- local text = [[<font face="font21" color ='#f39800'>kkk<cs id="$34"/><cs id="$34"></cs>hh</font>]]
    -- local text = '<font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">黑鳄甲虫</font><font face="font16" color="#ff0000">（0/15）</font><br/><font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">蛊晶蚊</font><font face="font16" color="#ff0000">（0/15）</font><br/>'
    -- local text = [[<font face='font16'>可制作5级攻击药<font color="#ffff00"><a face='font16' href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续<cs id="$01"/>时间24小时。<br/><font color='#9d1bd4'>最高等级：15级</font></font>]]
    -- local text = [[可制作5级攻击药<font color="#ffff00"><a href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续时间24小时。<br/><font color='#9d1bd4'>最高等级：15级</font>]]
    -- local text = [[<font color='#ebebeb' size='13'>使用<u><a href='event:get|57|1'><font color='#23e342' size='13'>VIP1大礼包</font></a></u>可获得</font>]]
    -- local text = "死亡时立即原地满血复活"
    -- local text = "送<font color='#23e342'>绝版</font><font color='#d323e3'>神兵玉佩</font>、升阶丹、金砖、修为丹、海量钻石！"
    -- local text = "<font color='#23e342'>装备颜色：</font>  <font color='#ffffff'>白</font>-<font color='#00ff00'>绿</font>-<font color='#0066ff'>蓝</font>-<font color='#9000ff'>紫</font>-<font color='#ff7800'>橙</font>-<font color='#cc0000'>红</font>-<font color='#00fff0'>青</font>-<font color='#fe50a6'>粉</font>-<font color='#fffc00'>金</font>-<font color='#ffffff'>亮白</font>-<font color='#00ff00'>亮绿</font>-<font color='#0066ff'>亮蓝</font>-<font color='#9000ff'>亮紫</font>-<font color='#ff7800'>亮橙</font>-<font color='#cc0000'>亮红</font>-<font color='#00fff0'>亮青</font>-<font color='#fe50a6'>亮粉</font>-<font color='#fffc00'>亮金</font>"
    -- local text = "<font color='#23e342'>兑换说明：</font><br/><br/>1、每日可兑换<font color='#23e342'>20</font>次，每次消耗<font color='#23e342'>5000W</font>经验，兑换5000修为；<br/>2、兑换消耗：<font color='#23e342'>20W</font>绑定金币；<br/>3、VIP每日可领取增加兑换修为次数的<font color='#23e342'>修为兑换石</font>。"
    -- local text = [[<font color='#FF00'><a href='event:OPEN_OPENSERVERACT_PANEL|3'> <u>详情点击查看 </u></a></font>]]
    -- local text = [[对狂战士增加攻击力126<br/><br/>圣器效果随圣器等级提高而提升<br/><br/>获取途径：<br/><font color='#23e342'>开服活动、累计充值</font><br/><font color='#23e342'>进阶返利、BOSS掉落</font><br/><font color='#23e342'>玩家分享</font>]]
    -- local text = [[abc<br/><br/><br/>defg]]
    local text = [[<font color="#16ffca" start_color="#16ffca" end_color="#ff42ff" >[真理手镯（右）]</font>]]

    for i = 1, 1 do
        local label = RichLabel.new{maxWidth = 370, fontSize = 22, lineSpace = 0, callback = function(id, name, href, x, y)
            yzjprint("==== RichLabel link touch!! ", id, name, href, x, y)
        end}
        self.testLabel = label
        label:setString(text)
        label:debugDraw()
        ui.addChild(self, label, 42 + i / 2, 153 - i / 4, nil, nil, 999)
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
    
end
