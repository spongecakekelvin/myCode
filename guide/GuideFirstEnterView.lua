local tClass = class("GuideFirstEnterView", cls.GamePanel)


local effectFunc = {}

local createDrama
local createContent
local createSpr
local createBtn
local createText
local updateNextView
local updateNextStep
local guideFinish
local finishWord
local createFingerAction

local loopFunc
local schedulerEntry = nil

function tClass:ctor()
    ui.addPlist("res/plistUI/guideTip.plist")

    tClass.super.ctor(self, cc.size(530, 552), false ,false)

    self:addTouch()
    self:setModal(true)

    -- 黑色底
    local layer = ui.newLayer(cc.c4b(0, 0, 0, 230))
    self.blackLayer = layer
    layer:setLocalZOrder(-1)
    layer:setScale(2)
    ui.addChildEx(layer, self)

    self.currentPeriodId = gData.GuideData.getCurrentPeriodId()
    self.config = gData.GuideData.getCurrentPeriodRewardConfig()

    self.stepNum = #self.config
    self.step = 0

    updateNextView(self)
end


function tClass:touchBegan(touch, event)
    local isIn = tClass.super.touchBegan(self, touch, event)
    self.isBeganIn = self:isTouch(touch)
    return true
end


function tClass:touchEnded(touch, event)
    local isTouch = tClass.super.touchEnded(self, touch, event)
    -- 点击非面板区域关闭 
    updateNextView(self)

    self.isBeganIn = false
end

function tClass:onEnter()
    tClass.super.onEnter(self)

    GuideManager.register(self)
end


function tClass:onExit()
    tClass.super.onExit(self)
    GuideManager.unregister(self)

    ui.removePlist("res/plistUI/guideTip.plist")
    ui.reloadLua("modules/guide/GuideFirstEnterView")
end


function finishWord(self)
    if not tolua.isnull(self.wordLabel) and self.wordLabel.word then
        self.wordLabel:setString(self.wordLabel.word)
    end
end

function updateNextView(self)
    if self.showWord then -- 播放函数
        self.showWord("finish")
        return
    end

    updateNextStep(self)
end

function updateNextStep(self)
    self.step = self.step + 1

    if self.step > self.stepNum then
        guideFinish(self)
        return
    end

    self.stepInfo = self.config[self.step]

    if self.currentPeriodId == 1 and (self.step == 1 or self.step == 2)then
        self.dramaOn = true
        self.blackLayer:setOpacity(255)
        createDrama(self)
    else
        self.dramaOn = false
        self.blackLayer:setOpacity(230)
        createContent(self)
    end
end

function createDrama(self)
    ui.removeNode(self.contentBg)

    local stepInfo = self.stepInfo
    local sprInfo = stepInfo.sprInfo

    local bgSize = self:getContentSize()

    local contentLayer = ui.newLayer()
    self.contentBg = contentLayer
    contentLayer:setLocalZOrder(3)
    contentLayer:setContentSize(bgSize)
    ui.addChildEx(contentLayer, self)


    if not sprInfo then
        gprint("没有配置sprInfo")
        return
    end

    local sprTag = sprInfo[1]
    if sprTag == "word" then
        local word = sprInfo[2]

        local label = gui.newLabel("", ui.color.white, 38, cc.size(600, 0))
        self.wordLabel = label
        self.wordLabel.word = word
        ui.addChildEx(label, contentLayer, 0.5, 0.5, cc.p(0.5, 1), 0, 50)

        if not tolua.isnull(self.wordLabel) then
            --逐字显示
            self.showWord = gData.GuideData.showWordOneByOne(
                self.wordLabel, 
                word, 
                0.03, 
                function() 
                    if not tolua.isnull(self) then
                        self.showWord = nil -- 先清空为nil
                        updateNextStep(self)
                    end
                end
            )
            self.showWord("on")
        end
    elseif sprTag == "image" then
        local bgSpr = ui.newSpr("#guideTip/image1.jpg")
        ui.addChildEx(bgSpr, contentLayer)
        ui.fadeIn(bgSpr, 0.5, 0)

        local textSpr = ui.newSpr("#guideTip/image2.png")
        ui.addChildEx(textSpr, bgSpr, 0, 0, cc.p(0.5, 0), 790, 350)
        -- ui.fadeInOut(textSpr, 0, 0.1, 0.5, 2)

        -- local emitter = gui.newParticle({path="res/particles/ashe.plist"})
        -- ui.addChildEx(emitter, bgSpr)
        self.guideSpr = ui.newSpr("#guideTip/finger1.png")
        self.guideSpr:setAnchorPoint(cc.p(1, 1))
        self.guideSpr:setPosition(717, 485)
        bgSpr:addChild(self.guideSpr)

        local action = cc.RepeatForever:create(cc.Sequence:create(
            createFingerAction(self.guideSpr),
            cc.DelayTime:create(0.4)
        ))
        self:runAction(action)
    end
end

function createContent(self)
    ui.removeNode(self.contentBg)

    local stepInfo = self.stepInfo
    local bgSize = stepInfo.size
    
    local blackBg = ui.new9Spr("#guideTip/bg.png", bgSize, cc.rect(36, 35, 12, 12))
    ui.addChildEx(blackBg, self, 0.5, 391, cc.p(0.5, 1))
    self.contentBg =  blackBg

    local contentLayer = ui.newLayer()
    self.contentLayer = contentLayer
    contentLayer:setLocalZOrder(3)
    contentLayer:setContentSize(bgSize)
    ui.addChildEx(contentLayer, blackBg)


    local label = gui.newLabel("(点击任意区域下一步)", ui.color.green, 24, cc.size(400, 0))
    ui.addChildEx(label, contentLayer, 0.5, 1, cc.p(0.5, 0.5), 500, -400)


    local spr = ui.newSpr("#guideTip/npcHead.png")
    self.npcHeadSpr = spr
    spr:setLocalZOrder(-1)
    ui.addChildEx(spr, blackBg, 0.5, 1, cc.p(0.5, 0), 0, -30)
    ui.fadeIn(spr, 0.5, 0)
    
    -- 图片
    createSpr(self)


    -- 内容
    local textLayer = createText(self)
    ui.addChildEx(textLayer, contentLayer, 0.5, 0.5)

    -- 光效
    if stepInfo.effectTag and effectFunc[stepInfo.effectTag] then
        effectFunc[stepInfo.effectTag](self)
    end

    -- 按钮
    createBtn(self)
end


function createSpr(self)
    local sprInfo = self.stepInfo.sprInfo
    if not sprInfo then
        return
    end
    local sprTag = sprInfo[1]
    local size = self.stepInfo.size

    if sprTag == "chest" then
        local spr = ui.newSpr("#guideTip/chest.png")
        ui.addChildEx(spr, self.contentLayer, 40, 0.5, cc.p(0, 0.5))
    elseif sprTag == "weapon" then
        local category = gData.RoleData.model.category
        local weaponSpr = ui.newSpr("#guideTip/weapon" .. category .. ".png")
        ui.addChildEx(weaponSpr, self.contentLayer)

        local spr = ui.newSpr("#guideTip/duang.png")
        ui.addChildEx(spr, self.npcHeadSpr, 0, 0, cc.p(1, 0.5), 7, 95)
        ui.splashEffect(spr, self)
    elseif sprTag == "pet" then

        local petModel = gData.PetData.getPetModelByCf(sprInfo[2])
        local anim = SimpleAnim.create({
            animName = tonumber(petModel.image),
            actionName = "stand",
            direction  = 2,
        })
        anim:setPositionY(35)
        anim:setPositionX(size.width / 2)
        self.contentLayer:addChild(anim)

        TimerManager.addTimeOut(function()
            local spr = ui.newSpr("#guideTip/petName.png")
            ui.addChildEx(spr, self.npcHeadSpr, 0, 0, cc.p(1, 0.5), 7, 95)
            ui.splashEffect(spr, self)
        end, 0.3)
    elseif sprTag == "huba" then
        local spr = ui.newSpr("#guideTip/huba.png")
        ui.addChildEx(spr, self.contentLayer, 0.5, 1, cc.p(0.5, 1), 0, -26)
        ui.splashEffect(spr, self)

        local spr = ui.newSpr("#guideTip/hubaName.png")
        ui.addChildEx(spr, self.npcHeadSpr, 0, 0, cc.p(1, 0.5), 7, 95)
        ui.splashEffect(spr, self)
    end
end

local gOffsetY = 3
function createText(self)
    local stepInfo = self.stepInfo
    local bgSize = stepInfo.size

    local textLayer = ui.newLayer()
    textLayer:setLocalZOrder(3)
    textLayer:setContentSize(bgSize)

    if type(stepInfo.text) == "table" then

        local offsetY = 0

        local x = stepInfo.x
        local y = bgSize.height + stepInfo.y

        for k, v in pairs(stepInfo.text) do
            local label = gui.newLabels(v)
            if not v.align or v.align == 1 then
                label:setPosition(x, y)
                label:setAnchorPoint(cc.p(0, 1))           
            elseif v.align == 2 then
                label:setPosition(w/2, y)
                label:setAnchorPoint(cc.p(0.5, 1))  
            elseif v.align == 3 then
                label:setAnchorPoint(cc.p(1,1))
                label:setPosition(w-x, y)
            end
            textLayer:addChild(label, 20)
            y = y - label:getContentSize().height - gOffsetY
        end
    end
    return textLayer
end


 -- 按钮
function createBtn(self)
    ui.removeNode(self.nextBtn)

    local btn = gui.easyBtn("", "#guideTip/btn.png", function()
        updateNextView(self)
    end)
    self.nextBtn = btn

    ui.addChildEx(btn, self.contentLayer, 0.5, 0, cc.p(0.5, 1), 0, -8)
    btn:setGuideTag(self.__cname, "ok")

    if type(self.stepInfo.btnName) == "table" then
        local label = gui.newLabels({self.stepInfo.btnName})
        label:setLocalZOrder(10)
        ui.addChildEx(label, btn)
    else
        btn.font:setString(self.stepInfo.btnName)
    end
end

function guideFinish(self)
    -- 领取新号奖励
    ctl.GuideController:requestFetctPeriodReward()

    -- 任务统计
    ctl.GuideMissionController:requestStat(11)
    
    if self.currentPeriodId == 1 then
        -- ctl.DialogController:openGuideDialogViewNoCheck(1000001)
    end

    if not tolua.isnull(self) then
        self:close()
    end
    
    -- 执行下一引导
    -- GuideManager.nextStep()
end


effectFunc["gold"] = function(self)
    local effect = gui.newPar_gold(0.9, 1000)
    effect:setLocalZOrder(10)
    ui.addChildEx(effect, self, 0.25, 1)

    local effect = gui.newPar_gold(0.9, 1000)
    effect:setLocalZOrder(10)
    ui.addChildEx(effect, self, 0.75, 1)
end


-- 手指动作
function createFingerAction(node)
    return cc.Sequence:create(
        cc.CallFunc:create(function()
            local array = {}
            array[#array + 1] = cc.MoveBy:create(0.1, cc.p(-10, 10))
            array[#array + 1] = cc.Spawn:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    ui.changeSpr(node, "#guideTip/finger2.png")
                end)
            )
            array[#array + 1] = cc.Spawn:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    ui.changeSpr(node, "#guideTip/finger1.png")
                end)
            )
            array[#array + 1] = cc.MoveBy:create(0.1, cc.p(10, -10))
            if not tolua.isnull(node) then
                node:runAction(cc.Sequence:create(array))
            end
        end),
        cc.DelayTime:create(0.4)
    )
end


return tClass