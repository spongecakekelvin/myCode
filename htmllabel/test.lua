 -- test code
local labelparser = require("gamecore/ui/richlabel/labelparser")
require("gamecore/ui/richlabel/htmlparser")
local RichLabel = require("gamecore/ui/richlabel/RichLabel")

 return function(self)
    ui.addPlist("allPlist/expression.plist")
 -- local text = "CLICK <a href='http://example.com/'>here!</a>"
    local text = [[奥斯卡的卷发洛杉矶佛按摩法<font face="font21" color ='#f39800'>kkk<cs id="$34"/>hh</font>]]
    -- local text = [[<font face="font21" color ='#f39800'>kkk<cs id="$34"/><cs id="$34"></cs>hh</font>]]
    -- local text = '<font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">黑鳄甲虫</font><font face="font16" color="#ff0000">（0/15）</font><br/><font face="font16" color="#ffffff">击杀</font><font face="font16" color="#57d0f8">蛊晶蚊</font><font face="font16" color="#ff0000">（0/15）</font><br/>'
    local text = [[<font face='font16'>可制作5级攻击药<font color="#ffff00"><a face='font16' href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续<cs id="$01"/>时间24小时。<br/><font color='#9d1bd4'>最高等级：15级</font></font>]]
    -- local text = [[可制作5级攻击药<font color="#ffff00"><a href="10086">剂，使用药</a>剂</font>后可以增加<a href="attack">攻击</a>0-3100，持续时间24小时。<br/><font color='#9d1bd4'>最高等级：15级</font>]]
    -- local text = [[<font color='#ebebeb' size='13'>使用<u><a href='event:get|57|1'><font color='#23e342' size='13'>VIP1大礼包</font></a></u>可获得</font>]]
    -- local text = "死亡时立即原地满血复活"
    -- local text = "送<font color='#23e342'>绝版</font><font color='#d323e3'>神兵玉佩</font>、升阶丹、金砖、修为丹、海量钻石！"
    -- local text = "<font color='#23e342'>装备颜色：</font>  <font color='#ffffff'>白</font>-<font color='#00ff00'>绿</font>-<font color='#0066ff'>蓝</font>-<font color='#9000ff'>紫</font>-<font color='#ff7800'>橙</font>-<font color='#cc0000'>红</font>-<font color='#00fff0'>青</font>-<font color='#fe50a6'>粉</font>-<font color='#fffc00'>金</font>-<font color='#ffffff'>亮白</font>-<font color='#00ff00'>亮绿</font>-<font color='#0066ff'>亮蓝</font>-<font color='#9000ff'>亮紫</font>-<font color='#ff7800'>亮橙</font>-<font color='#cc0000'>亮红</font>-<font color='#00fff0'>亮青</font>-<font color='#fe50a6'>亮粉</font>-<font color='#fffc00'>亮金</font>"
    local text = "<font color='#23e342'>兑换说明：</font><br/>1、每日可兑换<font color='#23e342'>20</font>次，每次消耗<font color='#23e342'>5000W</font>经验，兑换5000修为；<br/>2、兑换消耗：<font color='#23e342'>20W</font>绑定金币；<br/>3、VIP每日可领取增加兑换修为次数的<font color='#23e342'>修为兑换石</font>。"
    local t1 = os.time()
    local htmlTab = htmlparser.parse(text)
    -- printTable(htmlTab, yzjprint)
    yzjprint("========= divided line  ====================  ", text[1], text[2])
    -- local parsedtable = labelparser.parse(text)
    -- printTable(parsedtable, yzjprint)
    
    
    -- local content = "ab\ncd"
    -- local b, e = string.find(content, "\n")
    -- yzjprint(string.sub(content, 1, b), string.sub(content, e + 1))
    -- local desc = ui.newHtmlLabel(self.data.desc, cc.size(556, 0))
    for i = 1, 1 do
        
        local label = RichLabel.new{maxWidth = 370, fontSize = 22, lineSpace = 0, callback = function(id, name, href, x, y)
            yzjprint("==== RichLabel link touch!! ", id, name, href, x, y)
        end}
        self.testLabel = label
        label:setString(text)
        label:debugDraw()
        -- label:playAnimation()
        -- local label =  ui.newLabel("请选择服务器", 24, ui.color.orange)
        ui.addChild(self, label, 42 + i / 2, 153 - i / 4, nil, nil, 999)
        printTable(label:getContentSize(), yzjprint)
        yzjprint(self.testLabel:getPosition())
        printTable(self.testLabel:getAnchorPoint())
    end

    local lines = self.testLabel:getAllLines()
    for i, v in ipairs(lines) do
        yzjprint("==== line ", i, "===========")
        for j, k in ipairs(v) do
            local str = k.getString and k:getString() or ""
            local x, y = k:getPosition()
            yzjprint(j, "、", x, y, str)
        end
    end



    local btn = ui.UIButton.new({
    images = { normal = "#login/login.png", pressed = "#login/login2.png", disabled = "#login/login.png" },})
    ui.addChild(self, btn, 480, 450, 0.5, 0.5, 100)
    
    btn:onClick(nil, function() --登陆按钮
        local text = "送<font color='#23e342'>绝版</font><font color='#d323e3'>神兵玉佩</font>、升阶丹、金砖、修为丹、海量钻石！"
        self.testLabel:setString(text)
        self.testLabel:setAnchorPoint(0, 0)
        self.testLabel:debugDraw()
        yzjprint(self.testLabel:getPosition())
        printTable(self.testLabel:getAnchorPoint())
        -- local text = "可制作5级攻击药剂，使用药剂后可以增加攻击0-3100，持续时间24小时。<br/><font color='#9d1bd4'>最高等级：15级</font>"
        -- self.testLabel:setString(text)
        -- label:debugDraw()
    end)

    
    -- local node = ui.newLabel("请选择服务器", 24, ui.color.orange)
    -- yzjprint("== 1 the node is ", tolua.isnull(node), tostring(node))
    -- printTable(node:getContentSize())
    -- node:removeFromParent()
    -- yzjprint("== 2 the node is ", tolua.isnull(node), tostring(node))
    -- printTable(node:getContentSize())

    local t2 = os.time()
    yzjprint("=== delay time = ", t1, t2, t2 - t1)



    -- local replaceMap = {
    --     ["<br/>"] = "\\n",
    -- }
    -- local text = string.gsub(text, "", replaceMap)
    -- -- local text = string.gsub(text, "<br/>", "\\n")
    -- yzjprint("== text = ", text)

    -- local index = 1
    -- TimerManager.addTimer("testSendMsg", function()
    --     local sendIndex = CHANNEL.WORLD
    --     local text = index .. ' 、'.. [[发送id="$]] .. string.format("%02d", math.random(36)) .. [[表情]]
    --     yzjprint(text)
    --     Dispatcher.dispatchEvent(EventType.SEND_CHAT_MESSAGE,{channelIndex = sendIndex, privateChatName = self.privateChatName , msg = text})
    --     index = index + 1
    -- end, 3)
    -- TimerManager.clearTimer("testSendMsg")

end
