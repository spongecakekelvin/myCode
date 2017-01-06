------------------------------------------------------
--作者:	YuZhenjian
--日期:	2013年12月26日
--描述:	剧情播放处理类
------------------------------------------------------
DramaCopyManager = class("DramaCopyManager")

require "DramaCopyHelper"

---actionType :1 :移动 2:攻击，3:刷npc，4: 对话npc，5:释放技能 6：移除怪物，7：退出
--		{1, 方向, 距离, 时间},
--		{2, 攻击id, 次数，间隔时间，方向},
--		{3, 增加npcid, 位置，方向}，
--		{4，说话对象id，内容}
--		{5，释放技能id, 目标对象}
--		{6，消失怪物id}
--		{7，退出副本}
--		{8，移动窗口}

-- 怪物 --key:model.id , value:model
local elementArr = nil
-- 死掉的怪物
local elementToDieArr = {}
local elementToDieModelArr = {}
-- 场景中所有元素
local allElements


local sharedScheduler = CCDirector:sharedDirector():getScheduler()


local 	roleMoveHandler
local 	roleAttackHandler
local	createElementHandler
--local	removeElementHandler
local	dialogHandler
--local	skillReleaseHandler
local 	updateRoleStateHandler
local 	setViewPortHandler
local 	monsterAttackHandler
local 	monsterMoveHandler
local 	sayHandler
local 	delayHandler
--local 	tipMessageHandler
local	dramaOnHandler
local 	dramaOffHandler
local 	screenEffectHandler
local	createSkillButtonHandler
local 	addStateLayerHandler


-- 辅助函数
local 	tocMonsterFunc
local 	getElementFromAll

--- 事件监听
local 	simulateFightHandler
local 	dramaDialogOverHandler
local 	iWalkEndHandler

local roleLoginInfoHandler


local startIndex

function DramaCopyManager:init(dramaModel, mapId)

	--------------------------------------
	-- function(self, action, bool)
	-- self:
	-- action:动作
	-- bool:是否下一步
	--------------------------------------
	self.actionCallbackFunc = {
		[1] = roleMoveHandler,
		[2] = roleAttackHandler,
		[3] = createElementHandler,
		[4] = self.removeElementHandler,
		[5] = dialogHandler,
		[6] = self.skillReleaseHandler,
		[7] = updateRoleStateHandler,		--completeDramaCopyHandler,
		[8] = setViewPortHandler,
		[9] = monsterAttackHandler,
		[10] = monsterMoveHandler,
		--[11]为场景开始的检测动作
		[12] = sayHandler,
		[13] = delayHandler,
		[14] = self.tipMessageHandler,
		[15] = dramaOnHandler,
		[16] = dramaOffHandler,
		[17] = screenEffectHandler,
		[18] = createSkillButtonHandler,
		[19] = addStateLayerHandler,
	}

	self.dramaModel = dramaModel
	self.mapId = mapId
	self.finger = false

	elementArr = {}
	elementToDieArr = {}
	elementToDieModelArr = {}
	allElements = SceneDataCenter.getAllElements()

	-- 开启单机剧情模式
	-- walk
	myRole.model.needSyncTile = false
	-- attack
	GameConfig.isSimulateFight = true

	--	LogConfig.logInfoType = true
	--	GameConfig.isActive = false
	
	self.roleInfo = nil
end

function DramaCopyManager:start(dramaView)
	
	----加载技能效果相关资源
	ResourceManager.addPlist("images/skillEffect/categoryEff/gongnu/dujian.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/gongnu/gongnupugong.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/gongnu/huojianpao.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/gongnu/jiguang.plist")
	
	
	----加载技能效果相关资源
	ResourceManager.addPlist("images/skillEffect/categoryEff/zhongjian/shanxinghuo.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/zhongjian/xuanfengzhan.plist")
	
	----加载技能效果相关资源
	ResourceManager.addPlist("images/skillEffect/categoryEff/fashi/baofengxue.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/fashi/diuqiu.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/fashi/fashipugong.plist")
	ResourceManager.addPlist("images/skillEffect/categoryEff/fashi/huozhu.plist")
	
	self.view = dramaView

	DramaCopyHelper.lastStep = 0
	DramaCopyHelper.currentStep = 0

	--	self.lastScene = CCDirector:sharedDirector():getRunningScene()

	EventDispatcher.addEventListener(EventType.SIMULATE_FIGHT_ATTACK_TOS, simulateFightHandler, self)

	if self.view.mapId == DramaDataCenter.firstSceneId then
		EventDispatcher.addEventListener(EventType.SIMULATE_MAP_ENTER_TOC, roleLoginInfoHandler, self)
	end
end

function roleLoginInfoHandler(self, param)
	
	self.roleInfo = param.roleInfo
	
	EventDispatcher.removeEventListener(EventType.SIMULATE_MAP_ENTER_TOC, roleLoginInfoHandler, self)
end

function DramaCopyManager:runNextDrama()
	if not tolua.isnull(self.view) then
		--		if currentIndex then
		--			Log.info("start Index:" .. DramaCopyHelper.currentIndex)
		--			DramaCopyHelper.currentStep = DramaCopyHelper.currentIndex
		--			startIndex = currentIndex
		--		end
		DramaCopyHelper.lastStep = DramaCopyHelper.currentStep
		DramaCopyHelper.currentStep = DramaCopyHelper.currentStep + 1
		Log.info("当前步骤:" .. DramaCopyHelper.currentStep .. ",总步骤数:" .. (#self.dramaModel))

		if DramaCopyHelper.currentStep > #self.dramaModel then
			Log.info("完成所有步骤了")
			self:completeDramaCopyHandler()
			return
			--		DramaCopyHelper.currentStep = startIndex + 1
		end

		local action = self.dramaModel[DramaCopyHelper.currentStep]
		local actionType = action[1]
		Log.info("actionType  == " .. actionType)

		-- 条件
		if actionType == 11 then
			self.view.stateChecking = false
			local keepCondictionTable = action[4]
			self.view.condIndexTable = {}

			-- 剧情重新开始
			for index, v in pairs(action[2]) do
				self.view.condIndexTable[index] = v
			end

			local valueTable = action[3]
			local valueIndex = 1

			-- 更新条件索引
			for _, condInx in pairs(self.view.condIndexTable) do
				DramaCopyHelper.dramaOnValue[condInx] = valueTable[valueIndex]
				valueIndex  = valueIndex + 1
			end

			-- 清空原来的条件
			if not keepCondictionTable then
				for _, condIndx in pairs(self.view.condIndexTable) do
					DramaCopyHelper.condiction[condIndx] = 0
				end
			else
--				for _, condIndx in pairs(self.view.condIndexTable) do
--						DramaCopyHelper.condiction[condIndx] = 0
--				end
			end
			self.view.stateChecking = true
			--			self.view:stopAllActions()
			--			DramaCopyHelper.currentStep = DramaCopyHelper.currentStep + 1

			--			printTable(self.view.condIndexTable)
			--			printTable(DramaCopyHelper.dramaOnValue)
		else
			self.actionCallbackFunc[actionType](self, action, true)
		end
	else

		Log.debug("DramaCopyView居然没有了")

		DramaCopyHelper.initAllStates()
		-- 撤销监听
		EventDispatcher.removeEventListener(EventType.SIMULATE_FIGHT_ATTACK_TOS, simulateFightHandler, self)

		-- 推出副本
		--抛出更新排名列表信息
		local eventParam = EventParam.create()
		eventParam.isGlobal = true
		eventParam.isQuit = true
		EventDispatcher.dispatchEvent(EventType.ENTER_QUIT_COMMON_COPY, eventParam)

		self:removeFromParentAndCleanup(true)
		return
	end
end

function DramaCopyManager:runDramaIndexed(dramaIndex)

	local action = self.dramaModel[dramaIndex]
	local index = action[1]
	self.actionCallbackFunc[index](self, action, false)

end


-- 模拟攻击 (人物发起)
function simulateFightHandler(self, param)
--	Log.info("主角攻击")
	--------------------------------------
	-- 模拟收到tos数据
	--------------------------------------
	local tosMsg = param

	--------------------------------------
	-- 模拟服务器处理tos数据
	--------------------------------------
	local targets = tosMsg.targets
	local lockedTarget = nil	--用于定攻击方向
	local tocResult = {}
	local roleDamage
	
	local mapTileWidth = MapUtil.TILE_WIDTH --= 22
	local mapTileHeight = MapUtil.TILE_HEIGHT --= 21
	
	local desTileX, desTileY
	
	for i = 1, #targets, 2 do
		local element = allElements[ElementTypeName[targets[i]] .. targets[i + 1]]
		if element then
			Log.info("-- " .. i .. " -- HP:" .. element.model.hp)
			if not lockedTarget then
				lockedTarget = element
			end
			
			if element.model.damage then
				roleDamage = element.model.damage
			else
				local min = myRole.model.min_phy_attack
				local max = myRole.model.max_phy_attack
				if min > max then
					min, max = max, min
				end
				roleDamage = math.random(min, max)
			end

			desTileX, desTileY = nil, nil
			
			-- 怪物受击的击飞效果
			if myRole.model.category == 1 then
				local rolePos = ccp(myRole:getPosition())
				local elementPos = ccp(element:getPosition())
				
				local originTilePos = MapUtil.getTilePoint(elementPos)
--				Log.info(i .. "原来的" .. element.model.tileX .. "," .. element.model.tileY .. "//".. "" .. originTilePos.x .. "," .. originTilePos.y)

				local tilePos = MapUtil.getOffsetPos(rolePos, elementPos, 2)
				desTileX, desTileY = tilePos.x, tilePos.y
				if not MapUtil.canReachPos(tilePos.x, tilePos.y) then
					desTileX, desTileY = nil, nil
					Log.info("不可到达")
				end
			end
			
			tocResult[#tocResult + 1] = {
				is_miss = false,
				is_hunger = false,
				is_block = false,
				is_double_attack = false,
				dest_type = targets[i],	--  ElementType.monster,
				dest_id = targets[i + 1],	-- id
				current_hp = element.model.hp,
				result_type = 1,	-- 0回复1伤害
				result_value = roleDamage,	-- 扣血		
				dest_tile = {
					tx = desTileX,
					ty = desTileY,
				},
			}
--			Log.info("在场景中找到攻击对象，id == " .. targets[i + 1] .. ",类型 == " .. targets[i])
			element.model.hp = element.model.hp - roleDamage
			if element.model.hp <= 0 and element.model.type == ElementType.monster then
				if not elementToDieArr[element.model.id] then
					elementToDieArr[element.model.id] = element
					elementToDieModelArr[element.model.id] = element.model
				end
			end
			element:updateState(ElementState.hurt)--, dir)
			EffectFactory.showNumber(myRole, element, roleDamage, nil, nil, true)

		else
			Log.info("----找不到！，id == " .. targets[i + 1] .. ",类型 == " .. targets[i])
		end
	end -- for
	
	--------------------------------------
	-- 模拟服务器发送toc数据
	--------------------------------------

	local tocDir = tosMsg.dir
	if lockedTarget then
		tocDir = MapUtil.judgeDir(ccp(myRole:getPosition()),ccp(lockedTarget:getPosition()))
	end

	local tocFuncAction = CCCallFunc:create(function()
		local tocMsg  = EventParam.create()
		local newValue = {
			dir = tocDir,
			succ = true,
			skillid = tosMsg.skillid,
			src_type = tosMsg.src_type, -- or ElementType.player,
			dest_pos = {
				tx = myRole.model.tileX,		--需计算
				ty = myRole.model.tileY,		--需计算
				dir = tocDir,					--需计算
				px = "undefined",
				py = "undefined",
			},
			return_self = true,
			src_pos = {
				tx = myRole.model.tileX,
				ty = myRole.model.tileY,
				dir = "undefined",		--需计算
				px = "undefined",
				py = "undefined",
			},
			result =  tocResult,
			src_id = myRole.model.id, --角色id
		}
		tocMsg.newValue = newValue

		self.view:runAction(CCCallFunc:create(function()
				EventDispatcher.dispatchEvent(EventType.SIMULATE_FIGHT_ATTACK_TOC, tocMsg)	
			end))

		DramaCopyHelper.condiction[3] = DramaCopyHelper.condiction[3] + 1
		if DramaCopyHelper.attackMaxCountRole and DramaCopyHelper.condiction[3] > DramaCopyHelper.attackMaxCountRole then
			myRole:stopMove()
			DramaCopyHelper.attackMaxCountRole = nil
		end

	end)	-- tocFuncAction
	
	self.view:runAction(tocFuncAction)
	
	
	-- 存在死亡单位
	for id, elementToDie in pairs(elementToDieArr) do
	
		local array = CCArray:create()
		
		array:addObject(CCCallFunc:create(function()
			-- 播放死亡效果
			if not tolua.isnull(elementToDie) then
				elementToDie:playDeath(myRole)
			end
		end))
		
		array:addObject(CCDelayTime:create(0.2))
		array:addObject(CCCallFunc:create(function()
			-- 移除怪物
			local elementModel = elementToDieModelArr[id]
			if elementModel then
				local eventParam = EventParam.create()
				eventParam.isGlobal = true
				eventParam.newValue = elementModel
				EventDispatcher.dispatchEvent(EventType.REMOVE_MAP_ELEMENT_FROM_ARR, eventParam)
				Log.info("RELOAD 怪物ID：" .. id)
			end
		end))
		
		if elementToDie.model.autoReload then
			elementToDie.isDead = false
			Log.info("需要重新加载怪物")
			array:addObject(CCDelayTime:create(0.7))
			array:addObject(CCCallFunc:create(function()
				-- 重载怪物
					local elementModel = elementToDieModelArr[id]
					if elementModel then
						local eventParam = EventParam.create()
						eventParam.isGlobal	= true
						
						local model = DramaCopyHelper.monsterModelCopy(elementModel)
						eventParam.newValue = model
						elementArr[id] = model
						
						EventDispatcher.dispatchEvent(EventType.ADD_ELEMENT_TO_SCENE, eventParam)
						Log.info("怪物：" .. id .. "成功装载")
						
					else
						Log.info("加载时出错")
					end
			end))
		else
			
			elementArr[id] = nil
			Log.info("bug需要重新加载怪物")
			-- 场上怪物数
			DramaCopyHelper.condiction[1] = DramaCopyHelper.condiction[1] - 1
		end
		-- 已击杀数
		DramaCopyHelper.condiction[4] = DramaCopyHelper.condiction[4] + 1
		
		GameView.windowLayer:runAction(CCSequence:create(array))
		
	end	-- for 存在死亡单位
	
--	self.view:runAction(CCSequence:createWithTwoActions(
--		CCDelayTime:create(0.8),
--		CCCallFunc:create(function()
--			elementToDieArr = {}
--		end)
--	))
	elementToDieArr = {}
	
end	-- function simulateFightHandler(self, param)



tocMonsterFunc = function(element, roleStop)
	if not element then return end

	local tocMonsterResult = {
		[1] = {
			dest_type = ElementType.player,	--1
			is_miss = false,
			is_hunger = false,
			result_type = 1, -- 0恢复/1伤害
			is_block = false,
			result_value = element.model.max_attack or 999,		--需配置
			dest_tile = "undefined", 	--
			dest_id = myRole.model.id,
			current_hp  = myRole.model.hp,
		}
	}

	tocMonsterResult[1].result_type = element.model.max_attack
	--	myRole.model.hp = myRole.model.hp - element.model.max_attack


	local dir = MapUtil.judgeDir4(ccp(element:getPosition()), ccp(myRole:getPosition()))
	Log.info("======= DIRECTION:: " .. dir .." 怪物DIR ::" .. element.model.dir)
	element.model.dir = dir
	local tocMsg = {
		succ = true,
		return_self = false,
		skillid = 1,
		src_type = ElementType.monster,
		dir = dir,		--需计算
		dest_pos = {
			tx = 0,--myRole.model.tileX,
			ty = 0,--myRole.model.tileY,
			dir = "undefined",
			px = "undefined",
			py = "undefined",
		},
		src_pos = {
			tx = 0,--element.model.tileX,
			ty = 0,--element.model.tileY,
			dir = dir,		-- 需计算
			px = "undefined",
			py = "undefined",
		},
		result = tocMonsterResult,
		src_id = element.model.id,
	}
	if roleStop then
		myRole:stopMove()
		myRole:stopAttack()
		myRole:updateState(ElementState.stand)
	end

	local eventParam = EventParam.create()
	eventParam.isGlobal = true
	eventParam.newValue = tocMsg
	--	element:stopMove()

	EventDispatcher.dispatchEvent(EventType.SIMULATE_FIGHT_ATTACK_TOC, eventParam)

end	-- function tocMonsterFunc(element)



-- 模拟攻击 （怪物发起）
function monsterAttackHandler(self, action, runNext)
	DramaCopyHelper.monsterAttackCount = DramaCopyHelper.monsterAttackCount or action[2]
	local delayTime = action[3] or 0.7
	--------------------------------------
	-- 计算战斗结果result
	--------------------------------------
	local canFightState = myRole.model.releasingSkill
	myRole.model.releasingSkill = true

	-- 发送事件模拟的m_fight_attack_toc
	for id, element in pairs(allElements) do
		if element.model.type == ElementType.monster then
			element:stopMove()
			tocMonsterFunc(element, true)

			myRole:updateState(ElementState.hurt)
			local action = CCSequence:createWithTwoActions(
			CCDelayTime:create(0.5),
			CCCallFunc:create(function()
				myRole:updateState(ElementState.stand)
			end)
			)
			myRole:runAction(action)
		end
	end

	if DramaCopyHelper.monsterAttackCount > 1 then
		DramaCopyHelper.monsterAttackCount = DramaCopyHelper.monsterAttackCount - 1
		local action = CCSequence:createWithTwoActions(CCDelayTime:create(delayTime),
		CCCallFunc:create(function()
			monsterAttackHandler(self, action, runNext)
		end))
		self.view:runAction(action)
	else
		DramaCopyHelper.monsterAttackCount = nil
		myRole.model.releasingSkill = canFightState
		if runNext then
			self:runNextDrama()
		end
	end
end




-- 移动
function roleMoveHandler(self, action, runNext)
	DramaCopyHelper.walkEndRunNext = runNext
	DramaCopyHelper.directionRole = action[5]
	DramaCopyHelper.walkEndDelay = action[6] or 0
	DramaCopyHelper.isRoleMoving = true

	if DramaCopyHelper.walkEndRunNext then
		EventDispatcher.addEventListener(EventType.I_WALK_END, iWalkEndHandler, self)
	end

	--	myRole.model.releasingSkill = false
	--	myRole:stopMove()

	-- 按相对位移走
	if action[2] == 1 then
		local distance = ccp(action[3], action[4])--ccp(86, 67)	--
		local rolePixelPos = ccp(myRole:getPosition()) -- 像素位置
		local desPixelPos = ccp(rolePixelPos.x + distance.x, rolePixelPos.y + distance.y)

		--	local roleTilePos = myRole:getTilePosition()
		local desTilePos = MapUtil.getTilePoint(desPixelPos)

		if not MapUtil.canReachPos(desTilePos.x, desTilePos.x) then
			if runNext then
				self:runNextDrama()
				return
			end
		end
		myRole:moveToPoint(desTilePos)

		--	myRole.model.needSyncTile = false
		--		local findPathParam = FindPathParam.create()
		--		findPathParam.type = FindPathType.point
		--		findPathParam.point = desTilePos
		--		findPathParam.scene = self.dramaModel.mapId
		--		local eventParam = EventParam.create()
		--		eventParam.isGlobal			= true
		--		eventParam.newValue			= findPathParam
		--		EventDispatcher.dispatchEvent(EventType.FIND_PATH_EVENT, eventParam)
	else
		-- 按格子坐标走
		local desX, desY = action[3] or myRole.model.tileX, action[4] or myRole.model.tileY
		myRole:moveToPoint(ccp(desX, desY))
	end
end


function iWalkEndHandler(self, param)
	EventDispatcher.removeEventListener(EventType.I_WALK_END, iWalkEndHandler, self)
	param.stopEvent = true
	if DramaCopyHelper.directionRole then
		myRole:updateState(ElementState.stand, DramaCopyHelper.directionRole)
		DramaCopyHelper.directionRole = nil
	end
	DramaCopyHelper.isRoleMoving = false

	Log.info("寻路完成")
	if DramaCopyHelper.walkEndRunNext then
		-- 必须放在runNextDrama之前
		DramaCopyHelper.walkEndRunNext = false
		performWithDelay(self.view, function()
			self:runNextDrama()
		end, DramaCopyHelper.walkEndDelay)
		DramaCopyHelper.walkEndDelay = 0
	end
end





function createElementHandler(self, action, runNext)

	local addMonsterFunc = function()
		local monsterType = action[2]
		local monsterTypeId = action[3]
		local monsterNum = action[4] or 1
		local monsterId = action[5]
		local posTable = action[6]
		local attrTable = action[7]

		local monsterCount = 0
		for index = 1, monsterNum do
			local monsterModel
			if monsterType == ElementType.npc then
				monsterModel = DramaCopyHelper.npcModelCopy(monsterTypeId)
			elseif monsterType == ElementType.monster then
				monsterModel = MonsterDataCenter.getMonsterById(monsterTypeId)
				monsterModel.id = monsterTypeId * 100 + monsterId
--									monsterModel.name = "" .. monsterTypeId
--									Log.info(monsterModel.name.. " killed")
				monsterId = monsterId + 1

				monsterCount = monsterCount + 1
			end

			if not monsterModel then
				Log.info("没有找到对应的npc/怪物".. monsterTypeId)
			else
				monsterModel.autoReload = action[8]
				monsterModel.type = monsterType
				monsterModel.typeId = monsterTypeId

				monsterModel.attackParam = {radius = 5}
				
				-- 角色位置
				local rolePos = ccp(myRole.model.tileX, myRole.model.tileY)
				monsterModel.tileX = rolePos.x
				monsterModel.tileY = rolePos.y
				
--				local defaultDir = MapUtil.judgeDir(MapUtil.getPixelPoint(ccp(monsterModel.tileX, monsterModel.tileY)), ccp(myRole:getPosition()))
--				TipMessage.show(defaultDir .. "")
				-- 属性表的数据
				if attrTable then
					monsterModel.max_attack = attrTable[1] or 999
					monsterModel.dir = attrTable[3] or 4
					monsterModel.hp = attrTable[2] or 1
					monsterModel.max_hp = attrTable[2] or 1
					monsterModel.move_speed = attrTable[5] or math.random(80, 150)
					monsterModel.damage = attrTable[6]
				else
					monsterModel.max_attack = 1
					monsterModel.dir = index % 6
					monsterModel.hp = 100000
					monsterModel.max_hp = 100000
					monsterModel.move_speed = math.random(80, 150)
				end
				

				if posTable[index] then
					local posTile = ccp(posTable[index][1], posTable[index][2])

					if attrTable and attrTable[4] and attrTable[4] == 1 then
						--相对主角的格子坐标
						local tileX = rolePos.x + posTile.x
						local tileY = rolePos.y + posTile.y

						if not MapUtil.canReachPos(tileX, tileY) then
							local absX = math.abs(posTile.x)
							local absY = math.abs(posTile.y)
							local minRange = absX > absY and absY or absX

							local pos = MapUtil.findNearbyPoint(rolePos, minRange, minRange + 3)
							if pos then
								monsterModel.tileX = pos.x
								monsterModel.tileY = pos.y
							else
								Log.info("("..tileX ..",".. tileY ..")附近寻找坐标失败")
							end
						else
							monsterModel.tileX = tileX
							monsterModel.tileY = tileY
						end
					else
						--具体坐标
						monsterModel.tileX = posTile.x
						monsterModel.tileY = posTile.y
					end
				end

				monsterModel.oldTileX = monsterModel.tileX
				monsterModel.oldTileY = monsterModel.tileY


				if elementArr[monsterModel.id] then
					Log.info("场景中已存在元素".. monsterModel.id)
					if monsterModel.type == ElementType.monster then
						monsterCount = monsterCount - 1
					end
				else
					elementArr[monsterModel.id] = monsterModel

					--加进场景特效层
					local eventParam = EventParam.create()
					eventParam.isGlobal	= true
					eventParam.newValue = monsterModel
					EventDispatcher.dispatchEvent(EventType.ADD_ELEMENT_TO_SCENE, eventParam)

					Log.info("添加到场景的元素ID：" .. monsterModel.id)
				end
			end
			index = index + 1
		end -- for
		DramaCopyHelper.condiction[1] = DramaCopyHelper.condiction[1] + monsterCount
	end
	addMonsterFunc()

	local action = CCSequence:createWithTwoActions(CCDelayTime:create(0),
	CCCallFunc:create(function()
		Log.info("添加元素到场景结束")
		if runNext then
			self:runNextDrama()
		end
	end))
	self.view:runAction(action)
end


function DramaCopyManager:removeElementHandler(action, runNext)

	local haveMonster = false
	local toDie = action[2]
	local typeId = action[3]
	--	local monsterType = action[3]
	--	local monsterId = action[4]
	local monsterModel
	local monsterTable = {}
	for id, model in pairs(elementArr) do
		haveMonster = true
		break
	end

	local isRole = false

	if haveMonster then
		if typeId == nil then
			local monsterCount = 0
			for _, element in pairs(allElements) do
				if element.model.type == ElementType.monster then
					Log.info("ROMVENPCELEMENT --ID:" .. element.model.id and element.model.id or "(nil)")
					element.model.autoReload = false
					table.insert(monsterTable, element)
					monsterCount = monsterCount + 1
				end
			end
			DramaCopyHelper.condiction[1] = DramaCopyHelper.condiction[1] - monsterCount
		elseif typeId == 0 then
			Log.info("ROMVENPCELEMENT --ID:" .. "主角")
			isRole = true
		else
			-- npc 和 monster
			local monsterCount = 0
			for _, element in pairs(allElements) do
				if element.model.typeId == typeId then
					Log.info("ROMVENPCELEMENT --ID:" .. (element.model.typeId or "(nil)"))
					element.model.autoReload = false
					table.insert(monsterTable, element)
					if element.model.type == ElementType.monster then
						monsterCount = monsterCount + 1
					end
				end
			end
			DramaCopyHelper.condiction[1] = DramaCopyHelper.condiction[1] - monsterCount
		end

		--		if monsterType == nil or monsterType == ElementType.monster then
		--		elseif monsterType == ElementType.npc then
		--			local npc = allElements[ElementTypeName[monsterType] .. monsterId]
		--			if npc then
		--				Log.info("ROMVENPCELEMENT --ID:" .. npc.model.id and npc.model.id or "(nil)")
		--				table.insert(monsterTable, npc)
		--			end

		local array = CCArray:create()
		if toDie then
			if isRole then
				local arr = CCArray:create()
				arr:addObject(CCCallFunc:create(function()
					EffectFactory.addHurtEff()
				end))
				arr:addObject(CCCallFunc:create(function()
					myRole:die()
--					myRole:updateState(ElementState.die)
					--							myRole:playDeath()
					elementArr[myRole.model.id] = nil
				end))
				arr:addObject(CCDelayTime:create(0.7))
				local roleDieAction = CCSpawn:create(arr)

				array:addObject(roleDieAction)
			else
				array:addObject(CCCallFunc:create(function()
					for _, element in pairs(monsterTable) do
						if not tolua.isnull(element) then
						--							element:beAttack(myRole)
						--							element:runAction(CCBlink:create(0.3, 4))
							element:playDeath(myRole)
						end
					end
				end))
			end
			array:addObject(CCDelayTime:create(0.85))
		end

		array:addObject(CCCallFunc:create(function()
			for _, element in pairs(monsterTable) do
				if not tolua.isnull(element) then
    				elementArr[element.model.id] = nil
    --				element:removeFromParentAndCleanup(true)
    				local eventParam = EventParam.create()
    				eventParam.isGlobal	= true
    				eventParam.newValue = element.model
    				EventDispatcher.dispatchEvent(EventType.REMOVE_MAP_ELEMENT_FROM_ARR, eventParam)
    			end
			end

		end))
		--		array:addObject(CCDelayTime:create(1))
		if runNext then
			array:addObject(CCCallFunc:create(function()
				self:runNextDrama()
			end))
		end		
		local action = CCSequence:create(array)
--		self.view:runAction(action)
		GameView.windowLayer:runAction(action)
	else
		Log.info("DATACENTER中找不到可以删除的怪物了")
	end
end



function dialogHandler(self, action, runNext)
	DramaCopyHelper.dialogOverRunNext = runNext
	DramaCopyHelper.dialogDelay = action[3] or 0

	Log.info("对话开始")
	local dialogContent = action[2]
	local npcId = dialogContent[1]

	local npcModel
	if npcId then
		-- npc对话
		npcModel = DramaCopyHelper.npcModelCopy(npcId)
	else
		-- 主角对话
		npcModel = NPCModel.new()
		npcModel.name = myRole.model.name
		npcModel.id = nil
	end

	--- 任务
	local taskModel = TaskModel.new()
	taskModel.isDramaMode = true
	taskModel.id = 0
	taskModel.state = 1
	taskModel.npcDialog[taskModel.state] = dialogContent
	---

	npcModel.taskList = {}
	npcModel.taskList[1] = taskModel


	npcModel.selected = true
	npcModel.type = ElementType.npc

	EventDispatcher.addEventListener(EventType.DRAMA_DIALOG_OVER, dramaDialogOverHandler, self)

	local eventParam = EventParam.create()
	eventParam.isGlobal	= true
	eventParam.newValue = npcModel
	EventDispatcher.dispatchEvent(EventType.SELECTED_A_ELEMENT, eventParam)

--	if self.view.mapId == DramaDataCenter.firstSceneId then
--		self:setGuidance(true, 1, ccp(860, 150))
--	end
end


function dramaDialogOverHandler(self, param)
	self:setGuidance(false)

	EventDispatcher.removeEventListener(EventType.DRAMA_DIALOG_OVER, dramaDialogOverHandler, self)
	Log.info("剧情对话结束")
	if not tolua.isnull(self.view) then
		self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(DramaCopyHelper.dialogDelay or 0),
		CCCallFunc:create(function()
			DramaCopyHelper.dialogDelay = 0
			if DramaCopyHelper.dialogOverRunNext then
				DramaCopyHelper.dialogOverRunNext = false
				self:runNextDrama()
			end
		end)))
	else
		if DramaCopyHelper.dialogOverRunNext then
			DramaCopyHelper.dialogOverRunNext = false
			self:runNextDrama()
		end
	end
end


function monsterMoveHandler(self, action, runNext)

	local monsterId = action[2]
	local toX, toY = action[3] or myRole.model.tileX, action[4] or myRole.model.tileY
	local duration = action[5]
	local isToMove = action[6]
	local isToAttack = action[7]

	local toMoveElements = {}

	-- 怪物移动
	for id, element in pairs(allElements) do
		if element.model.type == ElementType.monster then
			table.insert(toMoveElements, element)
		end
	end

	local moveToAction = CCSpawn:createWithTwoActions(CCDelayTime:create(duration),
	CCCallFunc:create(function()
		local r = DramaCopyHelper.monsterMoveRange

		local judgeDistance = DramaCopyHelper.getEllipseAttackRange(DramaCopyHelper.monsterAttackRange, 2)

		for id, element in pairs(toMoveElements) do
			if not tolua.isnull(element) and not element.model.frozen then
    			if judgeDistance(element) then
    				element:stopMove()
    				if isToAttack then
    					tocMonsterFunc(element)
    				end
    			else
    				local destination = ccp(toX + math.random(-r, r), toY + math.random(-r - 1, r + 1))
    				if not MapUtil.canReachPos(destination.x, destination.y) then
    					repeat
    						destination = ccp(toX + math.random(-r, r), toY + math.random(-r - 1, r + 1))
    						Log.info("再次移动".. destination.x .. "," .. destination.y)
    					until MapUtil.canReachPos(destination.x, destination.y)
    
    					element:moveToPoint(destination)
    				else
    					element:moveToPoint(destination)
    				end
				end
    		end
		end
	end))
	local action = CCSequence:createWithTwoActions(moveToAction,
	CCCallFunc:create(function()
		--				Log.info("怪物到达目的地")

		if runNext then
			self:runNextDrama()
		end

		if isToMove then
			monsterMoveHandler(self, action)
		else
		end

	end))
	action:setTag(DramaCopyHelper.stopActionTags[2])
	DramaCopyHelper.stopActionTags[2] = DramaCopyHelper.stopActionTags[2] + 1
	self.view:runAction(action)
end


function roleAttackHandler(self, action, runNext)
	if runNext then
		self:runNextDrama()
	end

	-- 主角攻击
	--		local attacker = myRole
	--		myRole:playAttack()
	local targetType = action[2]
	local targetId = action[3]
	local delayBeforeAtt = action[4] or 0

	myRole.model.isCanFighting = true
	--	myRole.isFightEnd = true

	DramaCopyHelper.attackMaxCountRole = action[4]
	-- 攻击次数
	--	DramaCopyHelper.condiction[3] = 0

	local attackFunc = function()
		local element = allElements[ElementTypeName[targetType] .. targetId]
		--			for id, model in pairs(elementArr) do
		--				element = SceneDataCenter.getElementById(model.type, id)
		--				if element then
		--					break
		--				end
		--			end
		local eventParam = EventParam.create()
		eventParam.isGlobal = true

		if element then
			--					local fightVo = FightVo.new()
			--					fightVo.attacker = myRole
			--					fightVo.result = {}
			--					fightVo.result[1] = {
			--							dest_id = element.model.id,
			--							result_value = 40
			--						}
			--					element:beAttack(myRole)
			--					element:hurt(fightVo)

--			element.model.hp = element.model.hp + 40
			eventParam.oldValue = 1
			eventParam.newValue = element
			
			SceneDataCenter.setLockElement(element)
			Log.info("攻击目标ID" .. element.model.id)

		else
			Log.info("寻找攻击对象失败")
		end
		
		EventDispatcher.dispatchEvent(EventType.FIGHT_NEXT_ONE, eventParam)
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delayBeforeAtt))

	local attactAction = CCSpawn:createWithTwoActions(
	CCCallFunc:create(function()
		attackFunc()
	end),
	CCDelayTime:create(0))
	array:addObject(attactAction)

	array:addObject(CCCallFunc:create(function()
		Log.info("攻击动作结束")
	end))

	local action = CCSequence:create(array)
	action:setTag(DramaCopyHelper.stopActionTags[1])
	DramaCopyHelper.stopActionTags[1] = DramaCopyHelper.stopActionTags[1] + 1

	self.view:runAction(action)

end




function sayHandler(self, action, runNext, sayIndex)
	local monsterType = action[2]
	local monsterId = action[3]

	if not monsterId and monsterType == ElementType.player then
		monsterId = myRole.model.id
	end

	local index = sayIndex or 1
	local content = action[4][index] or "世界你好！"
	local duration = action[4][index + 1] or 1
	local bgType = action[5] or 1

	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function()
		local element = SceneDataCenter.getElementById(monsterType, monsterId)
		if element then
			element:say(content, duration, bgType)
		else
			Log.info("没有头顶说话对象:" .. monsterId)
		end
	end))
	array:addObject(CCCallFunc:create(function()

		if runNext then
			self:runNextDrama()
		end

	end))
	local action = CCSequence:create(array)
	action:setTag(monsterId)
	self.view:runAction(action)
end



function setViewPortHandler(self, action, runNext)
	Log.info("----------SET VIEW PORT")
	local newViewPortPos
	local isManual = action[2]
	local duration = action[3] or 1
	
	local scale = action[5]
	
	local array = CCArray:create()
	if isManual then
		local moveInfo = action[4]
		local moveType = moveInfo[1]
	
	-- 手动设置
		if moveType == 1 then
			-- 格子坐标
			newViewPortPos = ccp(moveInfo[2], moveInfo[3])
		elseif moveType == 2 then
			local monsterType = moveInfo[2]
			local monsterId = moveInfo[3]
			
			repeat 
				if monsterType == 1 then
					newViewPortPos = ccp(myRole.model.tileX, myRole.model.tileY)
					isManual = false
					break
				end
				
				-- 人物坐标
				local element = SceneDataCenter.getElementById(monsterType, monsterId)
				if element then
					newViewPortPos = ccp(element.model.tileX, element.model.tileY)
				else
					Log.info("没有找到视口移动的对象".. monsterType .. ",id:" .. monsterId)
				end
			until true
			
		else
			-- 相对格子坐标
			
		end
	else
	-- 移动回主角身上
		newViewPortPos = ccp(myRole.model.tileX, myRole.model.tileY)
	end
		
	array:addObject(CCSequence:createWithTwoActions(
	CCCallFunc:create(function()
		myRole.isManualViewPort = true
		
		local eventParam = EventParam.create()
		eventParam.isGlobal			= true
		eventParam.point			= newViewPortPos
		eventParam.duration			= duration
		eventParam.isManual			= isManual
		EventDispatcher.dispatchEvent(EventType.SET_VIEW_PORT_CENTER, eventParam)
		
	--		if scale and scale > 0 then
	--			GameView.sceneLayer:runAction(CCScaleTo:create(duration, scale))
	--		end
	end),
--	CCDelayTime:create(duration)
	CCDelayTime:create(0)
	))
	
	if not isManual then
		array:addObject(CCCallFunc:create(function()
			myRole.isManualViewPort = false
		end))
	end
	
	if runNext then
		array:addObject(CCCallFunc:create(function()
			self:runNextDrama()
		end))
	end
	
	local action = CCSequence:create(array)
	self.view:runAction(action)

end

local targetElements
function DramaCopyManager:skillReleaseHandler(action, runNext)
	if runNext then
		self:runNextDrama()
	end

	-- type, id, skillId
	local skillInfo = action[2]
	local power
	local skillId
	local title = action[3]
	local skillDuration = action[4]
	local typeIdTable = action[5]

	targetElements = {}

	if typeIdTable then
		for _, typeId in pairs(typeIdTable) do
			if typeId == 0 then
				table.insert(targetElements, myRole)
			else
				for _, element in pairs(allElements) do
					if element.model.typeId == typeId then
						table.insert(targetElements, element)
					end
				end
			end
		end
	else
		for _, element in pairs(allElements) do
			if element.model.type == ElementType.monster then
				table.insert(targetElements, element)
			end
		end
	end

	local array = CCArray:create()
	local skillReleaser
	-- 施法者特效
	if skillInfo and type(skillInfo) == "table" then
		skillId = skillInfo[3]
		local powerDuration = skillInfo[4] or 0.5

		--		if runNext then
		--			self.view:runAction(CCSequence:createWithTwoActions(
		--				CCDelayTime:create(powerDuration),
		--				CCCallFunc:create(function()
		--					self:runNextDrama()
		--				end)
		--			))
		--		end

		local powerEmitter
		array:addObject(CCSpawn:createWithTwoActions(
		CCCallFunc:create(function()
			skillReleaser = getElementFromAll(skillInfo[1], skillInfo[2])
			if skillReleaser and powerDuration ~= 0 then
				-- 主角施法转向
				if skillReleaser.model.id == myRole.model.id and not tolua.isnull(targetElements[1]) then
--                	FuncManager.emptyFuncTable()
					myRole.model.isPlayingSkillNow = true
                	myRole:stopMove()
                	myRole:stopAttack()
					local elementPos = ccp(targetElements[1]:getPosition())
					local dir = MapUtil.judgeDir4(ccp(skillReleaser:getPosition()), elementPos)
					skillReleaser:updateState(ElementState.skill, dir)
				end
				
				powerEmitter = CCParticleSystemQuad:create("particles/star flare.plist")
				powerEmitter:setDuration(powerDuration)
				local rlserSize = skillReleaser:getContentSize()
				powerEmitter:setPosition(rlserSize.width * 0.5 , rlserSize.height * 0.5)
				if skillId and skillId == 2 then
					-- 毒绿
					powerEmitter:setStartColor(ccc4f(0, 1, 0.75, 1))
					powerEmitter:setEndColor(ccc4f(0, 1, 0, 1))
				elseif skillId == 3 then
					-- 法球紫
					powerEmitter:setStartColor(ccc4f(0.75, 0.35, 0.85, 1))
				elseif skillId == 5 then
					-- 火红
					powerEmitter:setStartColor(ccc4f(1.0, 0.25, 0, 1))
					powerEmitter:setEndColor(ccc4f(0.04, 0, 0, 1))
				else
					-- 冰蓝
					powerEmitter:setStartColor(ccc4f(0, 0.75, 1, 1))
					powerEmitter:setEndColor(ccc4f(0, 0, 1, 1))
				end
				skillReleaser:addChild(powerEmitter)
				Log.info("粒子来了！")

				self.quan = createAnimation("yuanQiLang/%05d.png", 4, 0.3, true, 0, true)
				self.quan:setPosition(ccp(skillReleaser:getPosition()))
				self.quan:setAnchorPoint(ccp(0.5, 404 / 800))
				self.quan:setOpacity(70)
				self.quan:setScale(0.7)

				---加进场景特效层
				local eventParam = EventParam.create()
				eventParam.isGlobal	= true
				eventParam.node = self.quan
				eventParam.layerType = 2
				EventDispatcher.dispatchEvent(EventType.ADD_ELEMENT_TO_SCENE, eventParam)
			end
		end),
		CCDelayTime:create(powerDuration)
		))
		array:addObject(CCCallFunc:create(function()
			if powerEmitter then
				powerEmitter:stopSystem()
				powerEmitter:removeFromParentAndCleanup(true)
			end
			-- 地上尘土
			if not tolua.isnull(self.quan) then
				self.quan:runAction(CCSequence:createWithTwoActions(
				CCFadeOut:create(0.7),
				CCCallFunc:create(function()
					self.quan:removeFromParentAndCleanup(true)
				end)
				))
			end
			--				local shakeAction = CCShaky3D:create(2, CCSizeMake(15,10), 5, false)
			--				GameView.sceneLayer:runAction(shakeAction)
			--				self.gameScene = GameView.sceneLayer:getChildByTag(2222)
			--				self.gameScene:runAction(CCTintTo:create(1, 200, 0, 0))
			--				GameView.sceneLayer:runAction(CCScaleTo:create(1, 1.5))
--			if title then
--				TipMessage.show(title)
--			end
		end))
	end

	array:addObject(CCSpawn:createWithTwoActions(
	CCDelayTime:create(skillDuration),
	CCCallFunc:create(function()
		--- 技能特效
		if skillId and skillId == 2 then
			-- 毒箭雨
			if skillReleaser then
				local rlsPos = ccp(skillReleaser:getPosition())
				local perTime = 0.3
				local count = math.ceil(skillDuration / perTime)
				for _, element in pairs(targetElements) do
					if not tolua.isnull(element) then
						local elementPos = ccp(element:getPosition())
	
						local array1 = CCArray:create()
						for i = 1, count do
							array1:addObject(CCCallFunc:create(function()
								BulletFactory:sendDuArrow(ccpAdd(elementPos, ccp(-100 + math.random(-200, 150), 300)),  ccpAdd(elementPos, ccp(math.random(-20, 20), math.random(60, 70))),1)
							end))
							array1:addObject(CCDelayTime:create(perTime))
						end
						local action1 = CCSequence:create(array1)
						self.view:runAction(action1)
					end
				end

			end
		elseif skillId == 3 then
			-- 法球
			if skillReleaser then
				local perTime = 0.04
				local addUpTime = 0 + 1

				local array = CCArray:create()
				while addUpTime < skillDuration do
					for _, element in pairs(targetElements) do
						if not tolua.isnull(element) then
							local factor = true
							array:addObject(CCSpawn:createWithTwoActions(
							CCCallFunc:create(function()
								if not tolua.isnull(element) then
									local fightVo = {}
									fightVo.target = element
									fightVo.attacker = skillReleaser
									EffectPlayer.fireMagicArrow(fightVo, factor)
								end
	--							BulletFactory:newAMagicBall(skillReleaser, 0.2)
							end),
							CCDelayTime:create(perTime)
							))
	
							if factor then
								factor = false
							end
							addUpTime = addUpTime + perTime
						end
					end
				end
				local action = CCSequence:create(array)
				self.view:runAction(action)
			end
		elseif skillId == 4 or skillId == 5 then
			-- 4爆炸 5扇形火
			if skillReleaser then
				local perTime = 0.5
				local array  = CCArray:create()
				local addUpTime = 0
				local once = false
				
				local elementPos
				local dir
				while addUpTime < skillDuration do
					for _, element in pairs(targetElements) do
						if not tolua.isnull(element) then
							if not once then
							-- 面向方向
								elementPos = ccp(element:getPosition())
								dir = MapUtil.judgeDir4(ccp(skillReleaser:getPosition()), elementPos)
								skillReleaser:updateState(ElementState.stand, dir)
								once = true
							end
							
							if skillId == 4 then
								array:addObject(CCCallFunc:create(function()
									if not tolua.isnull(element) then
										local aimPos = ccpAdd(ccp(element:getPosition()), ccp(0, 60))
										local firePos = CategoryDeal:getNewBulletPos(skillReleaser, skillReleaser.model.dir)
										BulletFactory:sendBigFireBall(firePos, aimPos, 0.2, function()end, 60)
									end
								end))
								array:addObject(CCCallFunc:create(function()
									if not tolua.isnull(element) then
										DramaCopyHelper.elementHurtWithEffect(element, perTime)
									end
								end))
								
							elseif skillId == 5 then
	--							array:addObject(CCCallFunc:create(function()
	--							
	--								local rlsPos = ccp(skillReleaser:getPosition())
	--								local diffElement = CCSprite:create()
	--								local desPos = ccpAdd(rlsPos, ccpSub(rlsPos, elementPos))
	--								
	--								-- 转向
	--								skillReleaser:updateState(ElementState.stand, (dir + 4) % 8)
	--								diffElement:setPosition(desPos)
	----								BulletFactory:fireShanXingHuoYan(ccp(skillReleaser:getPosition()), ccp(element:getPosition()), 1)
	--								DramaCopyHelper.spitFire(diffElement, skillReleaser)
	--							end))
								array:addObject(CCDelayTime:create(0.4))
								array:addObject(CCCallFunc:create(function()
									skillReleaser:updateState(ElementState.stand, dir)
	--								BulletFactory:fireShanXingHuoYan(ccp(skillReleaser:getPosition()), ccp(element:getPosition()), 1)
									if not tolua.isnull(element) then
										DramaCopyHelper.spitFire(element, skillReleaser)
										for _, element in pairs(targetElements) do
											if not tolua.isnull(element) then
												DramaCopyHelper.elementHurtWithEffect(element, skillDuration)
											end
										end
									end
								end))
								break
							end
						end
					end

					if skillId == 4 then
						array:addObject(CCDelayTime:create(perTime))
						addUpTime = addUpTime + perTime
					elseif skillId == 5 then
						break
					end
				end
				array:addObject(CCCallFunc:create(function()
					for _, element in pairs(targetElements) do
						if not tolua.isnull(element) then
							element:updateState(ElementState.stand)
						end
					end
				end))

				local action = CCSequence:create(array)
				self.view:runAction(action)
			end
--		elseif skillId == 6 then
--			--冰柱（原火柱）
--			if skillReleaser then
--				local perTime = skillDuration / #targetElements
--				skillDuration = #targetElements * perTime
--				local elementPos
--				local dir
--
--				local array  = CCArray:create()
--				for _, element in pairs(targetElements) do
--					if not tolua.isnull(element) then
--					
--						-- 面向方向
--						elementPos = ccp(element:getPosition())
--						dir = MapUtil.judgeDir4(ccp(skillReleaser:getPosition()), elementPos)
--						
--						array:addObject(CCCallFunc:create(function()
----							skillReleaser:updateState(ElementState.stand, dir)
--							if not tolua.isnull(element) then
--								local aimPos = ccpAdd(ccp(element:getPosition()), ccp(0, 60))
--								BulletFactory:fireHuoZhu(aimPos)
--								element:flyUpAndDown()
--							end
--						end))
--						array:addObject(CCDelayTime:create(perTime))
--						
----						DramaCopyHelper.elementHurtWithEffect(element, perTime)
--					end
--				end
--				array:addObject(CCDelayTime:create(0.2))
--				array:addObject(CCCallFunc:create(function()
--					for _, element in pairs(targetElements) do
--						if not tolua.isnull(element) then
--							element:updateState(ElementState.stand)
--						end
--					end
--				end))
--
--				local action = CCSequence:create(array)
--				self.view:runAction(action)
--			end
--			
		elseif skillId == 7 then
			--激光
			if skillReleaser then
				local perTime = skillDuration / #targetElements		--0.5
				local array  = CCArray:create()
				local addUpTime = 0
				
				local perTwice = 0
				for _, element in pairs(targetElements) do
					if not tolua.isnull(element) then
						if perTwice == 0 then
							local elementPos = ccp(element:getPosition())
							local dir = MapUtil.judgeDir4(ccp(skillReleaser:getPosition()), elementPos)
											
		--					local dirVec = ccpMult(ccpForAngle(math.rad(MapUtil.getDirValueByAngle(dir))), 2000)
							
		--					while addUpTime < skillDuration do
								array:addObject(CCCallFunc:create(function()
									local firePos = CategoryDeal:getFireLaserPos(skillReleaser, dir)
		--							local aimPos = ccpAdd(firePos, dirVec)
									
									skillReleaser:updateState(ElementState.stand, dir)
									BulletFactory:fireLaser(firePos, elementPos, 0.1, function()
										EffectFactory.shakeScreen()
										if not tolua.isnull(element) then	
											DramaCopyHelper.elementHurtWithEffect(element, perTime)
										end
									end)
								end))
		--						addUpTime = addUpTime + 0.5
								array:addObject(CCDelayTime:create(0.1))
		--					end
		--					break
						end
						perTwice = perTwice + 1
						if perTwice == 1 then
							perTwice = 0
						end
					end
				end

				array:addObject(CCCallFunc:create(function()
					for _, element in pairs(targetElements) do
						if not tolua.isnull(element) then
							element:updateState(ElementState.stand)
						end
					end
				end))

				local action = CCSequence:create(array)
				self.view:runAction(action)
			end
			
--		elseif skillId == 8 then
			--洗衣机
		else
			-- 冰雹
			local elementPos
			for _, element in pairs(targetElements) do
				if not tolua.isnull(element) then
					if elementPos then
						elementPos = ccpMidpoint(ccp(element:getPosition()), elementPos)
					else
						elementPos = ccp(element:getPosition())
					end
				end
			end
			if elementPos then
				if skillId == 1 then
					elementPos = ccpMidpoint(ccp(myRole:getPosition()), elementPos)
				end
			else
				elementPos = ccp(myRole:getPosition())
			end
			
			if skillId == 1 then
				runActionsQ(self.view, {
					CCCallFunc:create(function() 
						GameMusic.playEff("music/effectMusic/fightEff/ice1.mp3")-- 暴风雪
					end),
					CCDelayTime:create(0.2),
					CCCallFunc:create(function() 
						GameMusic.playEff("music/effectMusic/fightEff/ice2.mp3")-- 暴风雪
					end),
					CCDelayTime:create(0.5),
					CCCallFunc:create(function() 
						GameMusic.playEff("music/effectMusic/fightEff/ice3.mp3")-- 暴风雪
					end),
					CCDelayTime:create(0.2),
					CCCallFunc:create(function() 
						GameMusic.playEff("music/effectMusic/fightEff/ice4.mp3")-- 暴风雪
					end),
					CCDelayTime:create(0.2),
					CCCallFunc:create(function() 
						GameMusic.playEff("music/effectMusic/fightEff/ice1.mp3")-- 暴风雪
					end),
				})
				
				EffectFactory.dropIce(elementPos, 455, 10 * skillDuration / 1.5)
--				BulletFactory:dropIce(ccpAdd(ccp(myRole:getPosition()), ccp(0, 120)), 0.6)
			-- 受伤变红
    			for _, element in pairs(targetElements) do
    				BufferLogic["冰冻"](element, skillDuration)
    				element.model.frozen = true
    				element:stopMove()
    				element:updateState(ElementState.hurt)
    --				DramaCopyHelper.elementHurtWithEffect(element, skillDuration)
   				end
			elseif skillId == 6 then
				GameMusic.playEff("music/effectMusic/fightEff/fire"..math.random(1, 2)..".mp3")
				BulletBatchManager:fireManyHuoZhu(elementPos, 210, 6)
				
				runActionsQ(self.view, {
					CCDelayTime:create(0.2),
					CCCallFunc:create(function()
						for _, element in pairs(targetElements) do
							if not tolua.isnull(element) then
                				--变蓝
                                local actAry = CCArray:create()
                            	actAry:addObject(CCTintTo:create(0.1, 0, 50, 200))
                            	actAry:addObject(CCDelayTime:create(skillDuration - 0.2))
                            	actAry:addObject(CCTintTo:create(0.1, 255, 255, 255))
                            	local action = CCSequence:create(actAry)
                                element.body:runAction(action)
                            end
--                          element:flyUpAndDown()
           				end
					end)
				})
				
			end
			
		end

	end) -- CCCallFunc
	))

	array:addObject(CCCallFunc:create(function()
		for _, element in pairs(targetElements) do
			if not tolua.isnull(element) then
				EffectFactory.showNumber(element,{result_value = element.model.hp}, true)
			end
		end
				
				
		skillReleaser = getElementFromAll(skillInfo[1], skillInfo[2])
		if skillReleaser and skillReleaser.model.id == myRole.model.id then
        	myRole.model.isCanFighting = true
		end
		
	--			emitter:setAutoRemoveOnFinish(true)
	--			emitter:setEmissionRate(math.random(-60, -40))
	--			emitter:setAngle(math.deg(ccpToAngle(ccpAdd(ccpSub(destPos, srcPos), ccp(0, 5)))) + math.random(-40, 40))
	--			emitter:setAngleVar(15)

	--			GameView.sceneLayer:runAction(CCTintTo:create(2, 255,255,255))
	--			GameView.sceneLayer:setGrid(nil)
	--			GameView.sceneLayer:runAction(CCScaleTo:create(1, 1))
	end))
	local action = CCSequence:create(array)
	self.view:runAction(action)
	
end -- function skillReleaseHandler



function updateRoleStateHandler(self, action, runNext)
	local state = action[2]
	local direction = action[3]
	local array = CCArray:create()
	local killerId = action[5]
	local isMonster = action[6]
    if isMonster then
    	if killerId then
        	for _, element in pairs(allElements) do
        	
        		if not tolua.isnull(element) then
        			if element.model.type == ElementType.monster and element.model.typeId == killerId then
        				Log.info("monster update State -->" .. element.model.id)
        				element:updateState(state, direction)
        			end
        		end
			end
		end
    else
    	local killer
    	if killerId then
    		killer = allElements[ElementTypeName[ElementType.monster] .. killerId]
    	end
    	if state == ElementState.die then
    		array:addObject(CCSpawn:createWithTwoActions(
    		CCCallFunc:create(function()
    			--沙子特效
    			local stroke = CCParticleSystemQuad:create("particles/boilingFoam.plist")
    			stroke:setAutoRemoveOnFinish(true)
    			stroke:setPosition(myRole:getPosition())
    			stroke:setPositionType(kCCPositionTypeRelative)
    
    
    
    			local arr = CCArray:create()
    			if killer then
    				local killerPos = ccp(killer:getPosition())
    				local elementPos = ccp(myRole:getPosition())
    
    				local backLen = 100--击飞距离
    				local backSpeed = 400--击飞移动速度
    				local jumpHeight = 50--飞起高度
    				local dirVec = ccpNormalize(ccpSub(elementPos, killerPos))
    				if ccpDistance(elementPos, killerPos) <= 0 then--距离小于0时防止BUG
    					dirVec = ccp(1, 0)
    				end
    				arr:addObject(CCEaseExponentialOut:create(
    				CCMoveBy:create(backLen / backSpeed, ccpMult(dirVec, backLen))
    				))
    
    				--特效也移动
    				stroke:runAction(CCEaseExponentialOut:create(
    				CCMoveBy:create(backLen / backSpeed, ccpMult(dirVec, backLen))
    				))
    			end
    			--加进场景特效层
    			local eventParam = EventParam.create()
    			eventParam.isGlobal	= true
    			eventParam.node = stroke
    			eventParam.layerType = 1
    			EventDispatcher.dispatchEvent(EventType.ADD_ELEMENT_TO_SCENE, eventParam)
    
    			arr:addObject(CCBlink:create(0.3, 3))
    			local action = CCSequence:create(arr)
    
    			myRole:runAction(action)
    		end),
    		CCDelayTime:create(0)
    		))
    	elseif state == ElementState.hurt then
    		DramaCopyHelper.elementHurtWithEffect(myRole, 0.4, direction)
    	end
    
    	array:addObject(CCCallFunc:create(function()
    		myRole:updateState(state, direction)
    		myRole.model.isCanFighting = false
    	end))
	
	end
	
	array:addObject(CCDelayTime:create(action[4] or 0))
	array:addObject(CCCallFunc:create(function()
		if runNext then
			self:runNextDrama()
		end
	end))
	local action = CCSequence:create(array)
	self.view:runAction(action)

end	-- function updateRoleStateHandler


function DramaCopyManager:completeDramaCopyHandler()

--	ResourceManager.removePlist("images/skillEffect/categoryEff/gongnu/dujian.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/gongnu/gongnupugong.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/gongnu/huojianpao.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/gongnu/jiguang.plist")
--	
--	
--	ResourceManager.removePlist("images/skillEffect/categoryEff/fashi/baofengxue.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/fashi/diuqiu.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/fashi/fashipugong.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/fashi/huozhu.plist")
--	
--	ResourceManager.removePlist("images/skillEffect/categoryEff/zhongjian/shanxinghuo.plist")
--	ResourceManager.removePlist("images/skillEffect/categoryEff/zhongjian/xuanfengzhan.plist")
	
	--	Log.info(self.view.mapId .. "/000")

	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function()
	--			self:dramaOff()
	end
	))
	--	array:addObject(CCDelayTime:create(1.5))
	array:addObject(CCCallFunc:create(function()

		DramaCopyHelper.initAllStates()

		-- 撤销监听
		EventDispatcher.removeEventListener(EventType.SIMULATE_FIGHT_ATTACK_TOS, simulateFightHandler, self)

		--				CCDirector:sharedDirector():replaceScene(self.lastScene)
		--				local tempScene = CCScene:create()
		--				CCDirector:sharedDirector():replaceScene(tempScene)
		--				tempScene:release()

		Log.info(self.view.mapId .. "/111")
		if self.view.mapId and self.view.mapId == DramaDataCenter.firstSceneId then
			local slideModel = DramaDataCenter.getDramaSlideById(1)
			if slideModel then
				local slideView = DramaSlideView.new(slideModel)
				slideView:setPosition(VisibleRect:center())
				GameView.tipLayer:addChild(slideView)
			end
	
--		-- 清除剧情副本场景
--			local eventParam = EventParam.create()
--			eventParam.clear = true
--			EventDispatcher.dispatchEvent(EventType.SIMULATE_MAP_ENTER_TOC, eventParam)

		else
			-- 退出副本
			local eventParam = EventParam.create()
			eventParam.isGlobal = true
			eventParam.isQuit = true
			EventDispatcher.dispatchEvent(EventType.ENTER_QUIT_COMMON_COPY, eventParam)
		end

--		self.view:onExit()
		self.view:removeFromParentAndCleanup(true)
	end
	))

	local action = CCSequence:create(array)

	self.view:runAction(action)
end


function delayHandler(self, action, runNext)
	local action = CCSequence:createWithTwoActions(
	CCDelayTime:create(action[2]),
	CCCallFunc:create(function()
		if runNext then
			self:runNextDrama()
		end
	end)
	)
	self.view:runAction(action)
end

--{14,内容,效果类型,{属性表}}
--			ps: 效果1普通提示nil ; 2 技能提示{技能ID（参考动作6）,弹入方向（1左2右）,持续时间} 
--ps: 技能ID： 1、冰暴（冰封地狱）2、毒箭 3、法球（持续时间 不能大于怪物消失时间）4、爆炸箭  5、扇形火（佛怒火莲）

local skillHintTag = 12306
function DramaCopyManager:tipMessageHandler(action, runNext)
	local msgName = action[2]
	local msgType = action[3]
	
	if msgType == 2 then
		-- 技能效果
		Log.info(msgName)
		
		local attrTable = action[4]
		local id = attrTable[1]
		local dir = attrTable[2]
		local duration = attrTable[3]
		
		local array = CCArray:create()
		array:addObject(CCCallFunc:create(function()
			
			
			local msgLayer = CCLayerColor:create(ccc4(0, 0, 0, 0))
			msgLayer:setZOrder(3)
			msgLayer:setPosition(ccpAdd(VisibleRect:center(), ccp(0, 91)))
	--		msgLayer:setAnchorPoint(ccp(0.5, 0.5))
	--		msgLayer:setPosition(ccp(0, 0))
			
			local scalePic = 1.74
			local scaleWord = 1.175
			
			local light = CCScale9Sprite:create("images/task/skillHint/" .. id .. "-" .. 3 .. ".png")
			light:setPreferredSize(CCSizeMake(1136, 113 * scalePic))
			msgLayer:addChild(light)
			
			
			
			local deltaTime = 0.13
			local particlePath = "images/task/skillHint/" .. id .. "-" .. 2 .. ".png"
			local originX = 800
			
			local addupTime = 0
			while addupTime < duration do
				local particle = CCSprite:create(particlePath)
				particle:setPosition(ccp(originX, 0))
				particle:setScaleY(scalePic)
				msgLayer:addChild(particle)
				
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(addupTime))
				arr:addObject(CCMoveBy:create(deltaTime, ccp(-2 * originX, 0)))
				arr:addObject(CCCallFunc:create(function()
							particle:removeFromParentAndCleanup(true)
						end))
				particle:runAction(CCSequence:create(arr))
--				originX = originX + offsetX
--				deltaTime = deltaTime + math.random() 0.01
				addupTime = addupTime + deltaTime
			end
			
		
			local wordPos = ccp(0, 0)
			local title = CCSprite:create("images/task/skillHint/" .. id .. "-" .. 1 .. ".png")
			title:setPosition(wordPos)
			msgLayer:addChild(title)
			
--			local size = title:getContentSize()
--			local offset = ccp(size.width * 0.5 + 16, - size.height * 0.5 - 10)
--			local desc = CCSprite:create("images/task/skillHint/" .. id .. "-" .. 4 .. ".png")
--			desc:setPosition(ccpAdd(wordPos, offset))
----			desc:setScale(scaleWord)
--			msgLayer:addChild(desc)
			
			
			msgLayer:setTag(skillHintTag)
			GameView.tipLayer:addChild(msgLayer)
			
		end)) -- array:addObject()
		
		array:addObject(CCDelayTime:create(duration))
		
		array:addObject(CCCallFunc:create(function()
			GameView.tipLayer:removeChildByTag(skillHintTag, true)
			if runNext then
				self:runNextDrama()
			end
		end))
		
		self.view:runAction(CCSequence:create(array))
		
		
	else
		-- 提示
		if runNext then
			self:runNextDrama()
		end
		TipMessage.show(msgName)
	end

end

function dramaOnHandler(self, action, runNext)
	local array = CCArray:create()
	local duration =  action[2] or 0.5
	array:addObject(CCSpawn:createWithTwoActions(
	CCCallFunc:create(function()
		self:dramaOn(duration)
	end),
	CCDelayTime:create(duration)
	))
	array:addObject(CCCallFunc:create(function()
		if runNext then
			self:runNextDrama()
		end
	end))
	local act = CCSequence:create(array)
	self.view:runAction(act)
end

function dramaOffHandler(self, action, runNext)
	local array = CCArray:create()
	local duration =  action[2] or 0.5
	array:addObject(CCSpawn:createWithTwoActions(
	CCCallFunc:create(function()
		self:dramaOff(duration)
	end),
	CCDelayTime:create(duration)
	))
	array:addObject(CCCallFunc:create(function()
		if runNext then
			self:runNextDrama()
		end
	end))
	local act = CCSequence:create(array)
	self.view:runAction(act)
end


local topBlackTag = 501
local bottomBlackTag = 502
function DramaCopyManager:dramaOn(duration, height)

	Log.info("Drama on")
	self.view.dramaOn = true
	myRole.model.isCanFighting = false

	local height = height or 66
	--- 电影黑边
	local scaleFactor = 640 / VisibleRect:getVisibleRect().size.height
	local topAction = CCEaseOut:create(CCMoveTo:create(duration, ccpAdd(VisibleRect:leftTop(), ccp(480, -height))), 1.1)
	self.topBlack = CCLayerColor:create(ccc4(0, 0, 0, 200))	
	self.topBlack:setContentSize(CCSizeMake(960, 195))
	self.topBlack:ignoreAnchorPointForPosition(false)
	self.topBlack:setAnchorPoint(ccp(0.5, 0))
	self.topBlack:setPosition(480, 640 + 195)
	self.topBlack:setScaleX(scaleFactor)
	self.topBlack:runAction(topAction)
	topAction:setTag(topBlackTag)

	local bottomAction = CCEaseOut:create(CCMoveTo:create(duration, ccpAdd(VisibleRect:leftBottom(), ccp(480, height))), 1.1)
	self.bottomBlack = CCLayerColor:create(ccc4(0, 0, 0, 200))
	self.bottomBlack:setContentSize(CCSizeMake(960, 195))
	self.bottomBlack:ignoreAnchorPointForPosition(false)
	self.bottomBlack:setAnchorPoint(ccp(0.5, 1))
	self.bottomBlack:setPosition(480, - 195)
	self.bottomBlack:setScaleX(scaleFactor)
	self.bottomBlack:runAction(bottomAction)
	bottomAction:setTag(bottomBlackTag)

	self.view:addChild(self.topBlack)
	self.view:addChild(self.bottomBlack)
end


function DramaCopyManager:dramaOff(duration)
	self.view.dramaOn = false
	myRole.model.isCanFighting = true
	
	if self.topBlack and self.bottomBlack then
		local topAction = CCEaseOut:create(CCMoveTo:create(duration, ccp(480, 640 + 195)), 0.9)
		self.topBlack:runAction(topAction)
		local bottomAction = CCEaseOut:create(CCMoveTo:create(duration , ccp(480, - 195)), 0.9)
		self.bottomBlack:runAction(bottomAction)
		Log.info("剧情结束")
	end
end


function getElementFromAll(elementType, id)
	if not allElements then
		Log.info("场景中的allElements为nil值，获取场景元素失败！")
		return
	end

	local element
	if elementType == ElementType.player then
		--主角des
		element = myRole
	elseif elementType == ElementType.monster or elementType == ElementType.npc then
		-- 怪物/npc
		element = allElements[ElementTypeName[elementType] .. id]
	else
		Log.info("获取的场景元素类型不正确:" .. (elementType or "-1"))
	end
	return element
end


function screenEffectHandler(self, action, runNext)


	local effType = action[2]
	local duration = action[3]
	local attrTable = action[4]
	
	if runNext and effType ~= 6 then
		self:runNextDrama()
	end
	
	local array = CCArray:create()

	local addUpTime = 0
	local deltaTime = 0.1
	if not effType then
	elseif effType == 1 then
		-- 震屏
		while addUpTime < duration do
			array:addObject(CCSpawn:createWithTwoActions(
			CCDelayTime:create(deltaTime),
			CCCallFunc:create(function()
				EffectFactory.shakeScreen()
			end)
			))
			addUpTime = addUpTime + deltaTime
		end
	elseif effType == 2 or effType == 3 then
		-- 2流血 3隐身
		if attrTable then
			--			array:addObject(CCCallFunc:create(function()
			local targets = {}
			for _, typeId in pairs(attrTable) do
				if typeId == 0 then
					table.insert(targets, myRole)
				else
					for _, element in pairs(allElements) do
						if element.model.typeId == typeId then
							table.insert(targets, element)
						end
					end
				end
				for _, element in pairs(targets) do
					if element.model.typeId == typeId then
						if effType == 2 then
							local emitter = CCParticleSystemQuad:create("particles/bloodShed.plist")
							emitter:setDuration(-1)
							emitter:setZOrder(255)
							emitter:setPositionType(kCCPositionTypeRelative)
							emitter:setPosition(55, 60)
							element:addChild(emitter)
						elseif effType == 3 then
							element:runAction(CCFadeOut:create(0.7, 50))
						end
					end
				end
			end
			--			end))-- CCCallFunc
		end
	elseif effType == 4 and self.view.mapId == DramaDataCenter.firstSceneId then
		
		local array = CCArray:create()
		array:addObject(CCSpawn:createWithTwoActions(CCCallFunc:create(function()
				if myRole then
					myRole:runAction(CCScaleTo:create(1, 1.1))
				end
			end),
			CCDelayTime:create(1)
			))
		array:addObject(CCCallFunc:create(function()
				local category = attrTable[1] or 1
			--更换角色形象(1重剑2弓箭3法师)
				local resURL = category == 1 and "player111" or (category == 2 and "player112" or "player113")

				local eventParam = EventParam.create()

				local roleInfo = {}
				roleInfo.id = 1
				roleInfo.category = category
				roleInfo.resURL = resURL
				
				if attrTable[2] and attrTable[3] then
					roleInfo.tileX = attrTable[2]
					roleInfo.tileY = attrTable[3]
				end
				eventParam.roleInfo = roleInfo
				
				DramaDataCenter.roleName = "剑男"
				EventDispatcher.dispatchEvent(EventType.CREATE_NEW_ROLE, eventParam)
			end))
		local action = CCSequence:create(array)
		self.view:runAction(action)
	elseif effType == 5 then
--		self:setGuidance(true, ccp(600, 320), "点击地面移动人物")
		self:setGuidance(true, 1, ccp(attrTable[1], attrTable[2]), attrTable[3], duration)
	elseif effType == 7 then
		-- Go引导
		self:setGuidance(true, 2, ccp(attrTable[1], attrTable[2]), attrTable[3], duration)
	elseif effType == 6 and false then
		-- 幻灯片儿
--		require "DramaSideView"
		
		local slideId = attrTable[1]
		
		local slideModel = DramaDataCenter.getDramaSlideById(slideId)
		if slideModel then
			local slideView = DramaSlideView.new(slideModel)
			slideView:setPosition(VisibleRect:center())
			GameView.tipLayer:addChild(slideView)
			
			local dramaSlideEndHandler
			
			dramaSlideEndHandler = function()
				if runNext then
					self:runNextDrama()
				end
				
				EventDispatcher.removeEventListener(EventType.DRAMA_SLIDE_END, dramaSlideEndHandler, self)
			end 
			
			EventDispatcher.addEventListener(EventType.DRAMA_SLIDE_END, dramaSlideEndHandler, self)
		end
	end
	
	array:addObject(CCCallFunc:create(function()
	end))

	local action = CCSequence:create(array)

	self.view:runAction(action)

end

local fingerTag = 012345
local blackHoleTag = 543210
function DramaCopyManager:setGuidance(switch, style, pos, hint, tipMsgDuration, hasBlackHole, tag)
	if switch then
		if not self.finger and not GameView.tipLayer:getChildByTag(fingerTag) then
			pos = pos or ccp(480, 240)
			
			if style == 2 then
			-- Go
				local go = EffectFactory.gonnaGo(pos)
				go:setTag(fingerTag)
				GameView.tipLayer:addChild(go, 2)
				--			Log.info("Go")
			else
				local fingerFunc = function()
					local finger = EffectFactory.createLadyFinger(true, nil, true)
					finger:setPosition(pos)
	--				local finger = EffectFactory.createFingerEx(pos)
					finger:setTag(fingerTag)
					GameView.tipLayer:addChild(finger, 2)
					--			Log.info("手指")
				end
				
				if hasBlackHole then
					myRole:stopAttack()
					myRole:stopMove()
					
					self.view.blackHole = true
					runActionsQ(GameView.windowLayer, {
						CCCallFunc:create(function()
							
							local initScale = 120
							local scaleBig = CCSprite:create("images/kong.png")
							local srcScale = 26
							scaleBig:setAnchorPoint(ccp(0.5, 0.5))
							scaleBig:setScale(initScale)
							scaleBig:setPosition(pos.x, pos.y + 6)
							scaleBig:setTag(blackHoleTag)
							GameView.tipLayer:addChild(scaleBig, 10)
							scaleBig:runAction(CCScaleTo:create(0.15, srcScale))
						end),
						CCDelayTime:create(0.15),
						CCCallFunc:create(function() fingerFunc() end)
					})
				else
					fingerFunc()
				end
			end
			
			if hint then
				TipMessage.show(hint, nil, tipMsgDuration or 1.2)
			end
		end
		self.finger = true
	else
		if self.finger then
			local blackHole = GameView.tipLayer:getChildByTag(blackHoleTag)
			if blackHole then
--				myRole:startWatch()
				self.view.blackHole = false
				blackHole:removeFromParentAndCleanup(true)
			end
			GameView.tipLayer:removeChildByTag(fingerTag, true)
			self.finger = false
		end
	end
end
--ps: 技能ID： 1、冰暴（冰封地狱）2、毒箭 3、法球（持续时间 不能大于怪物消失时间）4、爆炸箭  5、扇形火（红莲如来）
local skillIdTable = {
	[1] = 31101002, -- 冰封地狱
	[2] = 21101002, -- 血煞毒箭
	[3] = 31101003, -- 万法归宗
	[4] = 21103003,	--火箭炮
	[5] = 12103002, -- 红莲如来
	[6] = 31103001,	--火柱
	[7] = 21101001,	--旋风斩
--	11101001,			--旋风斩
--	12103002,			--佛怒火莲
--	12103001,			--三千雷动
--	21101001,			--激光
--	21103003,			--火箭炮
--	21101002,			--箭雨
--	31103001,			--火柱
--	31101003,			--丢球
--	31101002,			--暴风雪
}
local ICONTAG = 47597
local skillImgTag = 95295
local rotGap = 120
--{18, 技能位置(1/2/3),创建true/关闭false,调用的技能id} 
function createSkillButtonHandler(self, action, runNext)
	if runNext then
		self:runNextDrama()
	end
	
	local skillIndex = action[2]
	if not tolua.isnull(self.view.skillBtns[skillIndex]) then
		self.view.skillBtns[skillIndex]:removeChildByTag(ICONTAG, true)
	end
	
	local switch = action[3]
	if switch then
		local id = action[4]
		if id then
			local skillId = skillIdTable[id]
			if skillId then
				local iconPath = SkillDataCenter.getSkillIconPathById(skillId)
				if iconPath then
					
					runActionsQ(GameView.windowLayer, {
						CCCallFunc:create(function()
							self.view:initFastButtons()
							local size = CCSizeMake(50, 50) --self.backgroundImg:getContentSize()
							
							--技能图片
							local skillImg = CCSprite:create(iconPath)
							if not skillImg then
								TipMessage.show("没有技能图标: " .. self.model.maxico)
								skillImg = CCSprite:createWithSpriteFrameName("common/start.png")
							end
							local pos = ccp(size.width * 0.5, size.height * 0.5)
							skillImg:setPosition(pos)
							skillImg:setTag(skillImgTag)
							skillImg:setRotation((skillIndex - 1) * -rotGap)
							self.view.skillBtns[skillIndex]:addChild(skillImg)
							self.view.skillBtns[skillIndex].id = id
							self.view.skillBtns[skillIndex].iconPath = iconPath
							
							
							local skillUseCount = 2
							if id == 1 then
								skillUseCount = 0
							end
							
							self.view.skillBtns[skillIndex].clickCount = skillUseCount
							self.view.skillBtns[skillIndex].canClick = true
						end),
						CCDelayTime:create(0.3),
--						CCCallFunc:create(function()
--							runActionsQ(self.view.skillBtns[skillIndex], {
--								CCScaleTo:create(0.1, 1.1),
--								CCDelayTime:create(1),
--								CCScaleTo:create(0.1, 1.0),
--							})
--						end),
						CCCallFunc:create(function()
							self:setGuidance(true, 1, self.view.skillFingerPos, nil, nil, true)--skillIndex == 1)
							self.view.skillFinger = true
						end),
					})
				else
					Log.info("没有技能图标")
				end
			else
				Log.info("skillIdTable没有对应skillId")
			end
		end
	end
end


function addStateLayerHandler(self, action, runNext)
	self.view:addStateLayer(function()
		if runNext then
			self:runNextDrama()
		end
	end)
end
