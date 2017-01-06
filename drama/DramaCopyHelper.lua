------------------------------------------------------
--作者:	YuZhenJian
--日期:	2014年1月2日
--描述:	剧情副本助手
--		定义了剧情副本的数据、计数、动作标签Tag等
------------------------------------------------------

module("DramaCopyHelper", package.seeall)

-- 触发剧情条件的值
dramaOnValue = {}

lastStep = 0
currentStep = 0


-- 索引用于配置文件
condiction = {
	--- 场上怪物个数
	[1] = 0,
	--- 2时间
	[2] = 0,
	--- 3人物攻击次数
	[3] = 0,
	--- 4 已击杀的怪物个数
	[4] = 0,
	--- 主角tileX位置
	[5] = 0,
	--- 主角tileY位置
	[6] = 0,
}


----1 场上怪物个数
--remainCountMonster = nil
----2时间
--passedTime = 0
---- 3人物攻击次数
--attackCountRole = 0
----4 已击杀的怪物个数
--killedCountMonster = 0




-- 怪物攻击次数
monsterAttackCount = nil
attackMaxCountRole = 999
attackCountRole = 0
directionRole = nil
walkEndDelay = 0
isRoleMoving = false

stopActionTags = {
	[1] = 0,
	[2] = 0,
}

-- 其他
-- 怪物移动到主角的范围
monsterMoveRange = 3 --tile
monsterAttackRange = 120 --pixel
monsterKickOffRange = 50 --pixel

monsterToMoveCount = 9999
monsterToAttackCount = nil

walkEndRunNext = false
dialogOverRunNext = false
dialogDelay = 0


-- 需要事件返回错误处理计时
errorTick = 0


--------------------------------------
-- 下面是动作标签
--------------------------------------

-- 怪物移动
MONSTERMOVETAG = 1000

-- 初始化条件
local function initCondictions()
	dramaOnValue = {}
	
	lastStep = 0
	currentStep = 0
	
	condiction = {
		--- 场上怪物个数
		[1] = 0,
		--- 2时间
		[2] = 0,
		--- 3人物攻击次数
		[3] = 0,
		--- 4 已击杀的怪物个数
		[4] = 0,
		[5] = 0,
		[6] = 0,
	}
end

function initAllStates()
	-- 还原系统状态
	if myRole then
		myRole.model.isCanFighting = true
		if myRole.model then
			myRole.model.needSyncTile = true
		end
		myRole.isManualViewPort = false
	end
	
	GameConfig.isSimulateFight = false
	GameConfig.isActive = true
--	LogConfig.logInfoType = true
	
	initCondictions()
	
	--- 还原DramaCopyHelper中数据的初始值

	-- 怪物攻击次数
	monsterAttackCount = nil
	attackMaxCountRole = 999
	directionRole = nil
	walkEndDelay = 0
	
	stopActionTags[1] = 0
	stopActionTags[2] = 0
	
	monsterToMoveCount = 9999
	monsterToAttackCount = nil
	
	walkEndRunNext = false
	dialogOverRunNext = false
	dialogDelay = 0
	
	errorTick = 0

end


-- 拷贝npc model
function npcModelCopy(modelId)
	local model = NpcDataCenter.getNpcById(modelId)
	local npcModel = NPCModel.new()
	npcModel.id = modelId
	npcModel.skin = model.skin
	npcModel.name = model.name
	npcModel.npcType = model.npcType
	npcModel.lovelyWords = model.lovelyWords
	return npcModel
end

function monsterModelCopy(model)
	local newModel = MonsterDataCenter.getMonsterById(math.floor(model.id / 100))
	newModel.hp = model.max_hp
	newModel.max_hp = model.max_hp
	newModel.id = model.id
	newModel.autoReload = model.autoReload
	newModel.type = model.type
	newModel.typeId = model.typeId
	newModel.attackParam = model.attackParam
	newModel.move_speed = model.move_speed
	newModel.damage = model.damage
	
	newModel.tileX = model.oldTileX or model.tileX
	newModel.tileY = model.oldTileY or model.tileY
	
	newModel.oldTileX = newModel.tileX
	newModel.oldTileY = newModel.tileY
					
	newModel.max_attack = model.max_attack
	newModel.dir = model.dir
	return newModel
end

-- 获得椭圆攻击范围
-- lRadius 长半轴
function getEllipseAttackRange(lRadius, disType)
	if disType == 1 then
		local getPoint = function(dx, dy)
			local k = math.abs(dy /dx)
			local x = lRadius / math.sqrt(1 + 4 * k * k)
			x = dx > 0 and x or - x
			local y = dy> 0 and k * x or -k * x
			return ccp(x, y)
		end 
		return function(element)
			local line = CCRenderTexture:create(2 * lRadius, 2 * lRadius)
			line:begin()
			ccDrawColor4B(200, 0, 0, 255)
			ccDrawCircle(ccp(lRadius, lRadius),
					lRadius,
					math.rad(360),
					50,
					true)
			line:endToLua()
			--创建一个椭圆
			local circle = CCSprite:create()
			circle:addChild(line)
			circle:setAnchorPoint(ccp(0, 0))
			local roleSize = myRole:getContentSize()
			circle:setPosition(ccp(roleSize.width * 0.25, roleSize.height * 0.085))
			local scaleY = math.sin(math.rad(30))
			circle:setScaleY(scaleY)
			circle:setScaleX(scaleY * 2)
			element:addChild(circle)
			
			local elementPos = ccp(element:getPosition())
	--		Log.info("---------elementPos:(".. elementPos.x ..", " .. elementPos.y .. ")" )
			local rolePos = ccp(myRole:getPosition())	
			local dx = elementPos.x - rolePos.x
			local dy = elementPos.y - rolePos.y
	--		Log.info("---------dx:(".. dx ..", dy" .. dy .. ")" )
			local crossPoint = getPoint(dx, dy)
	--		Log.info("CrossPoint:(".. crossPoint.x ..", " .. crossPoint.y .. ")" .. ",RolePoint:(".. rolePos.x ..", " .. rolePos.y .. ")")
			local disCross = ccpLength(ccpSub(crossPoint, ccp(dx, dy)))
			local disElement = ccpLength(ccpSub(elementPos, rolePos))
			Log.info("-------CrossLength".. disCross ..", ElementLength:" .. disElement .. ")")
		--返回是否在范围内
			return disElement <= disCross
		end
	elseif disType == 2 then
		return function(element)
			local elementPos = ccp(element:getPosition())
--			Log.info("elementPos(".. elementPos.x ..", " .. elementPos.y .. ")")
			local rolePos = ccp(myRole:getPosition())
--			Log.info("rolePos(".. rolePos.x ..", " .. rolePos.y .. ")")
			local attackRect = CCRect(rolePos.x - 0.8 * lRadius - 20, rolePos.y - lRadius * 0.5, lRadius * 1.6 + 20, lRadius)
--			Log.info("attackRect(".. attackRect.origin.x ..", " .. attackRect.origin.y .. ", ".. attackRect.size.width ..", " .. attackRect.size.height .. ")")
			return attackRect:containsPoint(elementPos)
		end
	else
		return function(element)
			local rolePos = ccp(myRole:getPosition())
			local elementPos = ccp(element:getPosition())
			if elementPos.y > elementPos.x then
				elementPos.y = elementPos.y * 2
			end
			local dis = ccpDistance(elementPos, rolePos)
			
			return dis <= lRadius
		end
	end
end

function elementHurtWithEffect(element, duration, direction)
	if tolua.isnull(element) then
		return
		Log.info("怎么能伤害已经死亡的单位")
	end
	if myRole then
		element:beAttack(myRole)
	end
--	if myRole then
--		element:playDeath(myRole)
--	end
	
--	local actAry = CCArray:create()
--	local perTime = 0.41
--	local addUpTime = 0.0
--	
----	Log.info("受伤累加中。。。。。。。。。。。。。")
--	while addUpTime < duration do
--		actAry:addObject(CCTintTo:create(0.01, 200, 0, 0))
--		actAry:addObject(CCDelayTime:create(0.1))
--		actAry:addObject(CCTintTo:create(0.2, 255, 255, 255))
--		actAry:addObject(CCDelayTime:create(0.1))
--		addUpTime = addUpTime + perTime
--	end
--	local redAction = CCSequence:create(actAry)
--	if element.body then
--		element.body:runAction(redAction)
--	end
--	element:updateState(ElementState.hurt, direction)
end



function rainDevilBall(srcElement, target, newDt)
    local arrowCount = math.random(10, 12)
	local newActAry = CCArray:create()
	for i = 1, arrowCount do
		newActAry:addObject(CCCallFunc:create(function()
			local fightVo = {}
			fightVo.target = target
			fightVo.attacker = srcElement
			EffectPlayer.fireMagicArrow(fightVo, i == 1)
		end))
		newActAry:addObject(CCDelayTime:create(newDt))
	end
	local action = CCSequence:create(newActAry)
	srcElement:runAction(action)
end

function spitFire(target, attacker)
	
	local maxRot = 180
	
	local panyiY = 60
	
	local attackerPos = ccp(attacker:getPosition())
	attackerPos.y = attackerPos.y + panyiY
	
	local targetPos = ccp(target:getPosition())
	targetPos.y = targetPos.y + panyiY
	
	local angle = math.deg(ccpToAngle(ccpSub(attackerPos, targetPos)))
	
	
	for i = 1, maxRot, 10 do
		
		---外环火
		local outFire = createAnimation("shanxinghuo/%05d.png", 8, 0.5, true, 1, true)
		outFire:setPosition(attackerPos)
		outFire:setAnchorPoint(ccp(335 / 800, 405 / 800))
		outFire:setOpacity(200)
		
		local dirNorVec = ccpNormalize(ccpSub(targetPos, attackerPos))
		local dirVec = ccpMult(dirNorVec, 100 + math.random(0, 50))
		---旋转
		local changeRot = -angle + 180 + maxRot / 2 - i + math.random(-10, 10)
		outFire:setRotation(changeRot)
	
		outFire:runAction(CCMoveBy:create(0.8, dirVec))
		outFire:runAction(CCScaleTo:create(0.5, 1.5))
		
		local actAry = CCArray:create()
		actAry:addObject(CCDelayTime:create(0.3))
		actAry:addObject(CCFadeOut:create(0.2))
		actAry:addObject(CCCallFunc:create(function()
			outFire:removeFromParentAndCleanup(true)
		end))
		local action = CCSequence:create(actAry)
		outFire:runAction(action)
		
		--加进场景特效层
		local eventParam = EventParam.create()
		eventParam.isGlobal	= true
		eventParam.node = outFire
		eventParam.layerType = 1
		EventDispatcher.dispatchEvent(EventType.ADD_ELEMENT_TO_SCENE, eventParam)
		
		
	end
	
end



