------------------------------------------------------
--作者:	YuZhenJian
--日期:	2014年2月24日
--描述:	根据索引返回动作
------------------------------------------------------
module("DramaActionFactory", package.seeall)

local DelayTime = function(duration)
	return CCDelayTime:create(duration)
end

local MoveTo = function(duration, toPos)
	return CCMoveTo:create(duration, toPos)
end

local MoveBy = function(duration, toPos)
	return CCMoveBy:create(duration, toPos)
end

local Shake = function(duration)
	local shakeTime = 0.05
	local shakeCount = duration * 10
	return CCRepeat:create(
		CCEaseSineIn:create(CCSequence:createWithTwoActions(
		    CCMoveBy:create(shakeTime, ccp(10, 0)),
		    CCMoveBy:create(shakeTime, ccp(-10, 0))
		)),
		shakeCount
	)
end

local Float = function(duration, toPos, fromPos)
	local moveTo = MoveTo(duration, toPos)
	local fallHeight = 40
	local bezierConfig = ccBezierConfig()
	bezierConfig.controlPoint_1 = ccp(20, -fallHeight)
	bezierConfig.controlPoint_2 = ccp(120, -fallHeight)
	bezierConfig.endPosition = ccp(140, 0)
	
	local isLeft = (fromPos.x - toPos.x > 0)
	local bezierFloat
	local bezierRight = CCEaseSineIn:create(CCBezierBy:create(duration * 0.7, bezierConfig))
	local bezieLeft = CCEaseSineIn:create(bezierRight:reverse())
	
	if not isLeft then
		bezierFloat =  CCSequence:createWithTwoActions(bezierRight, bezieLeft)
	else
		bezierFloat =  CCSequence:createWithTwoActions(bezieLeft, bezierRight)
--		bezierFloat = bezieLeft
	end

	local floatAction = CCSpawn:createWithTwoActions(moveTo, bezierFloat)	
	
	return floatAction
--	return bezierFloat
end

local Rotate = function(duration, toPos, fromPos, speedFactor)
-- perTime 转一圈的时间 : + 顺时 - 逆时
	local perTime = speedFactor or 4
	local angel = perTime > 0 and 360 or -360
	perTime = math.abs(perTime)
--	local rotateCount = math.ceil(duration / perTime)
--	local action = CCRepeat:create(CCRotateBy:create(perTime, angel), rotateCount)
	local rotateCount = duration / perTime
	angel = angel * rotateCount
	local action = CCRotateBy:create(duration, angel)
	return action
end

local RotateMoveBy = function(duration, toPos, fromPos, speedFactor)
	local rotate = Rotate(duration, nil, nil, speedFactor)
	local moveBy = MoveBy(duration, toPos)
	
	return CCSpawn:createWithTwoActions(rotate, moveBy)
end

local FadeIn = function(duration)
	return CCFadeIn:create(duration)
end

local FadeOut = function(duration)
--	return CCFadeOut:create(duration)
	return FadeIn(duration):reverse()
end

local ScaleTo = function(duration, toPos, fromPos, scaleFactor)
	return CCScaleTo:create(duration, scaleFactor)
end

local ScaleIn = function(duration, scaleFactor)
--	return CCSequence:createWithTwoActions(
--		CCScaleTo:create(0, 0),
--		CCScaleTo:create(duration, 1)
--	)
	return ScaleTo(duration, nil, nil, 1)
end

local ScaleOut = function(duration)
	return ScaleIn(duration):reverse()
end

local Blink = function(duration, toPos, fromPos, blinkCount)
	local blinkCount = blinkCount or 1
	return CCBlink:create(duration, blinkCount)
end

local Laugh = function(duration)
	local speedFactor = 0.5
	local perTime = 0.3 * speedFactor
	local delayTime = 0.05 * speedFactor
	
	local bigger = CCScaleBy:create(perTime, 1.1)
	local smaller = CCScaleBy:create(perTime * 0.5, 0.909)
	
	local array = CCArray:create()
	array:addObject(bigger)
	array:addObject(smaller)
	array:addObject(CCDelayTime:create(delayTime))
	
	local laughAction = CCSequence:create(array)
	
	local laughCount = duration / (1.5 * perTime + delayTime)
	laughAction = CCRepeat:create(laughAction, laughCount)
	
	return laughAction
end

local ScaleMoveTo = function(duration, toPos, fromPos, scaleFactor)
	local moveTo = MoveTo(duration, toPos)
	local scaleTo = ScaleTo(duration, nil, nil, scaleFactor)
	return CCSpawn:createWithTwoActions(moveTo, scaleTo)
end	


local MoveToFadeIn = function(duration, toPos)
	local moveTo = MoveTo(duration, toPos)
	local fadeIn = FadeIn(duration)
	return CCSpawn:createWithTwoActions(moveTo, fadeIn)
end

local MoveToFadeOut = function(duration, toPos)
	local moveTo = MoveTo(duration, toPos)
	local fadeOut = FadeOut(duration)
	return CCSpawn:createWithTwoActions(moveTo, fadeOut)
end

local ShakeFadeIn = function(duration)
	local shake = Shake(duration)
--	local fadeIn = CCEaseSineOut:create(FadeIn(duration))
	local fadeIn = FadeIn(duration)
	local shakeFadeIn = CCSpawn:createWithTwoActions(shake, fadeIn)
	return shakeFadeIn
end

local ShakeFadeOut = function(duration)
	return ShakeFadeIn(duration):reverse()
end

local ScaleInFadeIn = function(duration, toPos, fromPos, scaleFactor)
	local scaleFactor = scaleFactor or 2
	local scaleIn = CCScaleTo:create(duration, scaleFactor)
	local fadeIn = FadeIn(duration)
	return  CCSpawn:createWithTwoActions(scaleIn, fadeIn)
end

local ScaleOutFadeIn = function(duration)
	local scaleOut = CCScaleTo:create(duration, 0.5)
	local fadeIn = FadeIn(duration)
	return  CCSpawn:createWithTwoActions(scaleOut, fadeIn)
end

local ShakeScaleIn = function(duration)
	local shake = Shake(duration)
	local scaleIn = ScaleIn(duration)
	return 
end

local ShakeScaleOut = function(duration)
	return ShakeScaleIn(duration):reverse()
end

local FadeInAndOut = function(duration, inPos, fromPos, speedFactor)
	local perTime = speedFactor or 1
	local count = duration / (2 * perTime)
	
	local fadeIn = FadeIn(perTime)
	local fadeOut = FadeOut(perTime)
	
	local fadeInAndOut = CCSequence:createWithTwoActions(fadeIn, fadeOut) 
	fadeInAndOut = CCRepeat:create(fadeInAndOut, count)
	
	return fadeInAndOut
end

local RotateFadeIn = function(duration)
	local rotate = Rotate(duration)
	local fadeIn = FadeIn(duration)
	return CCSpawn:createWithTwoActions(rotate, fadeIn)
end

local RotateFadeOut = function(duration)
	local rotate = Rotate(duration)
	local fadeOut = FadeOut(duration)
	return CCSpawn:createWithTwoActions(rotate, fadeOut)
end

local ShakeScaleFadeIn = function(duration, toPos, fromPos, scaleFactor)
	local shake = Shake(duration)
	local scaleIn = ScaleTo(duration, nil, nil, scaleFactor)
	local fadeIn = FadeIn(duration)
	
	local array = CCArray:create()
	array:addObject(shake)
	array:addObject(scaleIn)
	array:addObject(fadeIn)
	
	return CCSpawn:create(array)
end


local shakeScaleMoveFade = function(duration ,toPos, fromPos, scaleFactor)
	local scaleMoveTo = CCEaseSineIn:create(ScaleMoveTo(duration, toPos, nil, scaleFactor))
	local shakeFadeIn = ShakeFadeIn(duration)
	
	local spawnAction = CCSpawn:createWithTwoActions(
		scaleMoveTo,
		shakeFadeIn
	)
	return spawnAction
end

local RotateMoveByScaleTo = function(duration ,toPos, fromPos, speedFactor, scaleFactor)
	local rotateMoveBy = RotateMoveBy(duration ,toPos, fromPos, speedFactor)
	local scaleTo = ScaleTo(duration, nil, nil, scaleFactor)
	return CCSpawn:createWithTwoActions(rotateMoveBy, scaleTo)
end

local ShakeMoveBy = function(duration, toPos)
	local shake = Shake(duration)
	local moveBy = MoveBy(duration, toPos)
	
	return CCSpawn:createWithTwoActions(shake, moveBy)
end

local actionCallbackFunc = {
	[0] = DelayTime,
	[1] = MoveTo,
	[2] = Shake,
	[3] = Laugh,
	[4] = Float,
	[5] = Rotate,
	[6] = FadeIn,
	[7] = FadeOut,
	[8] = ScaleIn,
	[9] = ScaleOut,
	[10] = MoveBy,
	[11] = ScaleTo,
	[12] = Blink,
	
	[510] = RotateMoveBy,
	[51011] = RotateMoveByScaleTo,
	[111] =  ScaleMoveTo,
	[16] =  MoveToFadeIn,
	[17] =  MoveToFadeOut,
	[26] =  ShakeFadeIn,
	[27] =  ShakeFadeOut,
	[28] = 	ShakeScaleIn,
	[29] = 	ShakeScaleOut,
	[86] = 	ScaleInFadeIn,
	[96] = 	ScaleOutFadeIn,
	[67] = 	FadeInAndOut,
	[56] = RotateFadeIn,
	[57] = RotateFadeOut,
	[268] = ShakeScaleFadeIn,
	[11126] = shakeScaleMoveFade,
	[210] = ShakeMoveBy,
}


function createAction(actionTag, duration, fromPos, toPos, factor, factor2)
--	printTable(actionCallbackFunc)
	local action = actionCallbackFunc[actionTag](duration, toPos, fromPos, factor, factor2)
	
	return action
end


local Blacken = function()

end
local Shaken = function()

end


function runScreenEffect(effectTag, duration)
	
end

function fallingLeaves(self, pos, duration, speedFactor)
	
	
	local leaf = CCParticleSnow:create()
    leaf:setDuration(duration)
    leaf:setPosition(pos)
    leaf:setTotalParticles(4)
    leaf:setGravity(ccp(0,-1))
    leaf:setLife(3)
	leaf:setLifeVar(1)
	leaf:setSpeed(speedFactor)
	leaf:setSpeedVar(30)
	leaf:setEmissionRate(leaf:getTotalParticles()/leaf:getLife())
	leaf:setTexture(CCTextureCache:sharedTextureCache():addImage("images/drama/1-5.png"))
    --加进场景特效层
    self:addChild(leaf, 3)
end

local function Eclosion(spr, yuHuaRange, color)
	for i = 1, yuHuaRange do
		
		for rot = 0, 360, 45 do
			local newSpr = CCSprite:createWithSpriteFrame(spr:displayFrame())
			local blen = ccBlendFunc()
			blen.src = GL_ONE_MINUS_SRC_ALPHA
			blen.dst = GL_ONE
			newSpr:setBlendFunc(blen)
			local orgOp = (255 - 255 * i / yuHuaRange) / 3
			newSpr:setOpacity(orgOp)
			local oR = 255 * i / (color.r == 0 and 1 or color.r)
			local oG = 255 * i / (color.g == 0 and 1 or color.g)
			local oB = 255 * i / (color.b == 0 and 1 or color.b)
			newSpr:setColor(ccc3(oR, oG, oB))
			local pos = ccp(spr:getPosition())
			newSpr:setPosition(ccpAdd(pos, ccpMult(ccpForAngle(math.rad(rot)), i)))
			
			newSpr:setScaleX(spr:getScaleX())
			newSpr:setScaleY(spr:getScaleY())
			
			local parent = spr:getParent()
			local zOr = spr:getZOrder()
			if not tolua.isnull(parent) then
				parent:addChild(newSpr, zOr - 1)
			end
			
			--动态发光
			local actAry = CCArray:create()
			actAry:addObject(CCFadeTo:create(1, orgOp))
			actAry:addObject(CCFadeTo:create(1, 0))
			actAry:addObject(CCDelayTime:create(1))
			newSpr:runAction(CCSequence:create(actAry))
		end
	end
end

function Thunder(self, pos, duration, scaleFactor)
	local bgSpr = CCSprite:create("images/drama/5-23.png")
	
	if bgSpr then
	
		local pos = pos or ccp(480, 320)
		bgSpr:setPosition(pos)
		if scaleFactor then
			bgSpr:setScale(scaleFactor)
		end
		bgSpr:setZOrder(10)
		bgSpr:setOpacity(0)
		
		local perTime = timeFactor or 0.8
		local count = math.ceil(2 / (perTime * 3))
	    self:addChild(bgSpr)
	    
	    
		local actAry = CCArray:create()
		actAry:addObject(CCCallFunc:create(function()
			local actAry = CCArray:create()
			actAry:addObject(CCEaseSineOut:create(CCFadeIn:create(perTime - 0.2)))
			actAry:addObject(CCEaseSineOut:create(CCFadeOut:create(perTime)))
			actAry:addObject(CCEaseSineOut:create(CCFadeIn:create(0.2)))
			actAry:addObject(CCDelayTime:create(perTime * 2))
			local action = CCSequence:create(actAry)
			bgSpr:runAction(action)
			
	    	Eclosion(bgSpr, 2, ccc3(80, 80, 80))
--	    	EffectFactory.feather({orgNode = bgSpr, yuHuaRange = 2, color = ccc3(80, 80, 80), justLightOnce = true})
	    end))
		actAry:addObject(CCDelayTime:create(perTime - 0.1))
		actAry:addObject(CCCallFunc:create(function()
	    	Eclosion(bgSpr, 8, ccc3(80, 80, 80))
--	    	EffectFactory.feather({orgNode = bgSpr, yuHuaRange = 8, color = ccc3(80, 80, 80), justLightOnce = true})

			local actAry = CCArray:create()
			actAry:addObject(CCEaseSineOut:create(CCFadeIn:create(0.1)))
			actAry:addObject(CCDelayTime:create(perTime * 2))
			actAry:addObject(CCEaseSineOut:create(CCFadeOut:create(perTime)))
			actAry:addObject(CCCallFunc:create(function()
				bgSpr:removeFromParentAndCleanup(true)
		    end))
			local action = CCSequence:create(actAry)
			bgSpr:runAction(action)
	    end))
		local action = CCSequence:create(actAry)
	    self:runAction(action)
	end
end


local minDisplace = 2
local maxDisplace = 200
local numBolts = 2
--local lc = ccc3(255, 255, 255)
local white = {0, 0, 0, 255}
local black = {0, 0, 0, 0}

local function drawLightning(p1, p2, displace)
	if displace < minDisplace then
		ccDrawLine(p1, p2)
	else
		local midX = (p1.x + p2.x) * 0.5
		local midY = (p1.y + p2.y) * 0.5
		midX = midX + (math.random() - 0.5) * displace
		midY = midY + (math.random() - 0.5) * displace
		local midP = ccp(midX, midY)
		drawLightning(p1, midP, displace * 0.5)
		drawLightning(p2, midP, displace * 0.5)
	end
end


local sharedScheduler = CCDirector:sharedDirector():getScheduler()
local tex
local scheduleId
local count = 0
local maxCount = 1
local addUpTime = 0
local maxTime = 0.8
function Lightning(self, p1, p2)
	addUpTime = 0
	local rate = ccpLength(ccpSub(p1, p2)) / 500 
	local curMaxDisplace = math.ceil(maxDisplace * rate)
	
	local winSize = ccp(960, 640)
	local midPoint = ccp(winSize.x * 0.5, winSize.y * 0.5)
	local height = math.abs(p2.y - p1.y) * 2
	local width = math.abs(p2.x - p1.x) * 2
--	local radius = (height > width and height or width)
	
	tex = CCRenderTexture:create(winSize.x , winSize.y)
	tex:setPosition(midPoint)
	self:addChild(tex, 20)
	
	
	local offsetY = 14
	local drawFunc = function(dt)
		addUpTime = addUpTime + dt
		if addUpTime > maxTime then
			if scheduleId then
				sharedScheduler:unscheduleScriptEntry(scheduleId)
				scheduleId = nil
				tex:removeFromParentAndCleanup(true)
			end
		else
			tex:beginWithClear(unpack(black))
--			local r, g, b = 80, 80, 200 
--			math.random() * 255, math.random() * 255, math.random() * 255
			ccDrawColor4B(unpack(white))
--			tex:clear(r, g, b)
			local dir = 1
			local y = p1.y
			for i = 1, numBolts do
				drawLightning(ccp(p1.x, y), ccp(p2.x, y), curMaxDisplace)
			 	y = p1.y + dir * offsetY --* math.random()
				dir = dir * -1
			end
			tex:endToLua()
		end
	end

--  转换成可runAction的CCSprite类型
--	local texSprite = CCSprite:createWithTexture(tex:getSprite():getTexture())

	scheduleId = sharedScheduler:scheduleScriptFunc(function() drawFunc(0.05) end, 0.05, false)
end


