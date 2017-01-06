------------------------------------------------------
--作者:	YuZhenJian
--日期:	2014年1月27日
--描述:	desc
------------------------------------------------------

DramaSceneController = class("DramaSceneController", Controller)

require "MonsterDataCenter"
require "NpcDataCenter"
require "SkillEffectDataCenter"
require "MapFindPath"
require "DramaScene"
require "SceneDataCenter"
require "CategoryFightDataCenter"
require "ArcherPlayer"
require "MagePlayer"
require "SwordPlayer"
require "SkillDataCenter"

local createElementModelsEx

local findPathHandlerEx

local addElementToSceneHandlerEx

local simulateMapEnterhandlerEx
local createNewRoleHandlerEx

local fakeSceneData
local fakeModel

local toAddElementArr = false

local roleInfo = nil
local slideModel

function DramaSceneController:init()
	-- 模拟进入场景
	EventDispatcher.addEventListener(EventType.SIMULATE_MAP_ENTER_TOC, simulateMapEnterhandlerEx, self)
	--
--	EventDispatcher.addEventListener(EventType.INIT_DRAMA_SCENE_LISTENER, self.initGameScene, self)
--	Log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1")

end


function DramaSceneController:initGameScene()
--	--初始化游戏场景
--	self:initGameScene()
	SkillDataCenter.setShortCutSkills({1, 1, 1})
	
	
	--创建游戏场景
	local gameScene = DramaScene:new()
	gameScene.controller = self
	self:setView(gameScene)
	GameView.sceneLayer:addChild(gameScene)
	
	roleInfo = {
		id = 1,
		category = 3,
	}
	
	--监听事件
	self:initListener()
	toAddElementArr = self.view:getToAddElementArr()
end


--初始化监听，包括协议监听和事件监听
function DramaSceneController:initListener()
	---对地图元素进行选择点击使用等的操作
	EventDispatcher.addEventListener(EventType.CLICK_A_ELEMENT_DEAL, self.clickAElementDealHandlerEx, self)
	---模拟点击场景元素事件
	EventDispatcher.addEventListener(EventType.CLICK_A_ELEMENT, self.clickAElementHandlerEx, self)
	
	---寻路
	EventDispatcher.addEventListener(EventType.FIND_PATH_EVENT, findPathHandlerEx, self, self)
	---添加场景元素到场景
	EventDispatcher.addEventListener(EventType.ADD_ELEMENT_TO_SCENE, addElementToSceneHandlerEx, self)
	
	EventDispatcher.addEventListener(EventType.CREATE_NEW_ROLE, createNewRoleHandlerEx, self)
end


function DramaSceneController:removeListener()
	---寻路
	EventDispatcher.removeEventListener(EventType.CLICK_A_ELEMENT_DEAL, self.clickAElementDealHandlerEx, self)
	---添加场景元素到场景
	EventDispatcher.removeEventListener(EventType.CLICK_A_ELEMENT, self.clickAElementHandlerEx, self)
	
	---寻路
	EventDispatcher.removeEventListener(EventType.FIND_PATH_EVENT, findPathHandlerEx, self, self)
	---添加场景元素到场景
	EventDispatcher.removeEventListener(EventType.ADD_ELEMENT_TO_SCENE, addElementToSceneHandlerEx, self)
	
	-- 模拟进入场景
	EventDispatcher.removeEventListener(EventType.SIMULATE_MAP_ENTER_TOC, simulateMapEnterhandlerEx, self)
	
	EventDispatcher.removeEventListener(EventType.CREATE_NEW_ROLE, createNewRoleHandlerEx, self)
end

---点击场景的一个元素，这个会寻路过去附近才进行真正的操作
function DramaSceneController:clickAElementHandlerEx(param)
	local element = param.newValue
	self.view:clickAElement(element)
end

---点击了一个场景元素对其使用操作，比如怪物就打，采集物就采集
function DramaSceneController:clickAElementDealHandlerEx(param)
	local element = param.newValue
	self.view:clickAElementHandler(element)
end


function createNewRoleHandlerEx(self, param)
	local roleInfo = param.roleInfo
	
	if roleInfo then
		
		local roleModel = fakeModel(roleInfo)
		
		if roleInfo.category then
			GameConfig.CTPlayer = roleInfo.category == 1 and SwordPlayer or (roleInfo.category == 2 and ArcherPlayer or MagePlayer)
		end
		self.view:creatNewRole(roleModel)
		
		roleInfo.id = roleInfo.id + 1
	else
		Log.info("职业类型未赋值 param.category（in DramaSceneController--createNewRoleHandlerEx）")
	end
end

--require "LoginDataCenter"

function createElementModelsEx(self, elementModelTab, type)
	--添加怪物
	if type == ElementType.monster then
		for _, v in pairs(elementModelTab) do
			local monsterModel = MonsterDataCenter.getMonsterById(v.typeid)
			if not monsterModel then
				Log.error("客户端没有怪物%d的配置", v.typeid)
				monsterModel = MonsterModel.new()
			end
			local pos = v.pos
			monsterModel.id = v.monsterid
			monsterModel.typeId = v.typeid
			monsterModel.state = 0
			monsterModel.serverState = v.state
			monsterModel.hp = v.hp
			monsterModel.mp = v.mp
			monsterModel.max_mp = v.max_mp
			monsterModel.max_hp = v.max_hp
			monsterModel.move_speed = 60
--			monsterModel.name = v.monster_name
			monsterModel.tileX = pos.tx
			monsterModel.tileY = pos.ty
			monsterModel.dir = pos.dir
			monsterModel.type = ElementType.monster --表示怪物
			Log.info("服务器请求添加怪物id：%d, typeid:%d", monsterModel.id, monsterModel.typeId)
			self.view:addToAddArr(monsterModel)
		end
	---创建NPC
	elseif type == ElementType.npc then
		for _, v in pairs(elementModelTab) do
			local npcModel = NpcDataCenter.getNpcById(v.type_id)
			if not npcModel then
				Log.error("客户端没有npc%d的配置", v.type_id)
--				npcModel = NPCModel.new()
			else
				local pos = v.pos
				npcModel.id = v.npc_id
				npcModel.typeId = v.type_id
				npcModel.name = v.npc_name
				npcModel.npc_kind_id = v.npc_kind_id
				npcModel.state = 0
				npcModel.max_mp = v.max_mp
				npcModel.max_hp = v.max_hp
				npcModel.hp = v.hp
				npcModel.mp = v.mp
				npcModel.map_id = v.map_id
				npcModel.tileX = pos.tx
				npcModel.tileY = pos.ty
				npcModel.dir = pos.dir
				npcModel.move_speed = v.move_speed
				npcModel.npc_country = v.npc_country
				npcModel.type = ElementType.npc
				self.view:addToAddArr(npcModel)
				if npcModel.serverNPC then
					Log.info("controller---------------创建了SeverNpc:%d", npcModel.id)
				end
			end
		end
	---创建玩家
	elseif type == ElementType.player then
		for _, v in pairs(elementModelTab) do
			local playerModel = PlayerModel.new()
			local pos = v.pos
			playerModel.id =  v.role_id
			playerModel.name = v.role_name
			playerModel.tileX = pos.tx
			playerModel.tileY = pos.ty
			playerModel.dir = pos.dir
			playerModel.body = v.skin
			playerModel.move_speed = v.move_speed
			playerModel.fighting_power = v.fighting_power
			playerModel.type = ElementType.player
			playerModel.sex = v.sex
			playerModel.level = v.level
			playerModel.hp = v.hp
			playerModel.max_hp = v.max_hp
			playerModel.category = v.category
			playerModel.cur_title = v.cur_title
			playerModel.cur_title_color = v.cur_title_color
			playerModel.resMountURL = ""
			playerModel.resURL = playerModel:getAnimation()
			
			--家族战
			playerModel.serverState = v.state				--服务器的状态
			playerModel.family_name = v.family_name
			--家族战
			if v.last_walk_path ~= "undefined" then
				playerModel.walkPath = exchangePath(v.last_walk_path.path)
			end
			self.view:addToAddArr(playerModel)
		end
	end
end


function simulateMapEnterhandlerEx(self, param)
	local clearElements = nil
	if param then
		clearElements = param.clear
	end
	
--	Log.info("simulate map!!1")
	if clearElements then
--		local currentScene = CCDirector:sharedDirector():getRunningScene()
--		CCDirector:sharedDirector():replaceScene(currentScene)
--		currentScene:release()
--		myRole:removeAllChildrenWithCleanup(true)
		myRole:removeFromParentAndCleanup(true)
		
		myRole = false
		myModel = false
		currentSceneModel = false
		
		SkillDataCenter.emptySkillData()
		SceneDataCenter.emptySceneData()
		
		self:removeListener()
		
		self.view:unScheduleUpdateScene()
		self.view:clearSceneElement()
		self.view:removeFromParentAndCleanup(true)
		
  	 	GameView.sceneLayer:removeAllChildrenWithCleanup(true)
	    GameView.tipLayer:removeAllChildrenWithCleanup(true)
	    GameView.mainUILayer:removeAllChildrenWithCleanup(true)
	    
		GameConfig.haveEnterScene = false
		
		package.loaded["Role"] = nil
		_G["Role"] = nil
		package.loaded["SwordRole"] = nil
		_G["SwordRole"] = nil
		package.loaded["ArcherRole"] = nil
		_G["ArcherRole"] = nil
		package.loaded["MageRole"] = nil
		_G["MageRole"] = nil
		
	-- 创建添加主角界面-
		local eventParam = EventParam.create()
		eventParam.newValue = true
	 	EventDispatcher.dispatchEvent(EventType.REQUEST_OPEN_LOGIN_ADD_ROLE_VIEW, eventParam)
--		Log.info("simulate map!!2")
		
		CCTextureCache:sharedTextureCache():removeUnusedTextures()
		CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	else
		slideModel = DramaDataCenter.getDramaSlideById(0)
		
		if slideModel then
			self:initGameScene()
			
			if param then
				self.view:setMyModel(fakeModel(roleInfo))
				local evnetParam = {}
				evnetParam.newValue = fakeSceneData(roleInfo)
				
				self:mapEnterHandler(evnetParam)
			end
		else
			Log.info("创建开场的幻灯片失败，slideModel为nil，跳到选择角色界面")
			TipMessage.show("选择你的职业")
			local eventParam = EventParam.create()
			eventParam.newValue = DramaDataCenter.firstSceneId
		 	EventDispatcher.dispatchEvent(EventType.REQUEST_OPEN_LOGIN_ADD_ROLE_VIEW, eventParam)
	 	end
	end
end
---收到进入场景的协议，返回场景信息m_map_enter_toc
function DramaSceneController:mapEnterHandler(param)
	local msg = param.newValue
	Log.info("进入开场剧情副本")
	local sceneId, oldSceneId = 0, currentSceneModel and currentSceneModel.sceneId or 0
	if myRole then
		myRole:setMoveEnable(true)
--		myRole:closeAutoFightLogic()
	end

	local pos = msg.pos

	myModel.tileX = pos.pos.tx
	myModel.tileY = pos.pos.ty
	myModel.dir = pos.pos.dir
	--加载场景界面
	sceneId = pos.map_id
	self.view:enterScene(pos.map_id)
	--怪物
--	if msg.monsters ~= "undefined" then
--		createElementModelsEx(self, msg.monsters, ElementType.monster)
--	end
	
	
	-- 开头文字显示
--	local dramaModel = DramaDataCenter.getDramaById(0)
--	if dramaModel then
--		local dramaView = DramaWordView.new(dramaModel)
--		dramaView:setPosition(VisibleRect:center())
--		GameView.tipLayer:addChild(dramaView, 999)
--	end

	local slideView = DramaSlideView.new(slideModel)
	slideView:setPosition(VisibleRect:center())
	GameView.tipLayer:addChild(slideView)

--	local eventParam = EventParam.create()
--	eventParam.isGlobal = true
--	eventParam.newValue = 0
--	EventDispatcher.dispatchEvent(EventType.DRAMA_SLIDE_END, eventParam)
end



---寻路,点寻路时类型为-1，并且参数为一个格子坐标点
function findPathHandlerEx(self, param)
	local findPathParam = param.newValue
	myRole.allPathEnd = false
	if findPathParam.type == FindPathType.npc then
		findPathParam.scene = math.floor(findPathParam.targetId / 1000)
	end
	
	findPathParam.scene = findPathParam.scene or currentSceneModel.sceneId
	
	--传送类型
	if findPathParam.flyType then
		if findPathParam.targetId then
			findPathParam.point = MapUtil.getElementPositionFromMCM(findPathParam.targetId, findPathParam.scene, true)
			if not findPathParam.point then
				TipMessage.show("找不到目标位置")
				return
			end
		end
		if findPathParam.flyType == 3 then
			self.view:flyTo(findPathParam)
		else
			requestFlyHandler(self, findPathParam)
		end
		return
	end
	
	if findPathParam.scene ~= currentSceneModel.sceneId then
		findPathParam.scenePath = MapFindPath.find(currentSceneModel.sceneId, findPathParam.scene)
		if #findPathParam.scenePath < 1 then
--			TipMessage.show("无法到达目的地")
			return
		else
			table.remove(findPathParam.scenePath, 1)
		end
	end
	--寻场景元素
	self.view:mapFindPath(findPathParam)
end

function addElementToSceneHandlerEx(self, param)
	local element = param.node
	local layerType = param.layerType
	if element then
		self.view:addEffect(element, layerType)
	else
		local model = param.newValue
		if model then
			self.view:addToAddArr(model)
		end
	end
end



function fakeSceneData(loginInfo)
--	GameConfig.CTPlayer = MagePlayer
	if not loginInfo then
		Log.info("loginInfo是空的！！")
		return
	end
	
	local bornPos = DramaDataCenter.roleInitPos
	local mapId = DramaDataCenter.firstSceneId
	local newValue = {
		succ = true,
		pos = {
			role_id= loginInfo.roleId or 100086, -- myRole.model.id
			map_id = mapId, -- 开场剧情副本
			pos = {
				tx = bornPos.x, -- 主角出生点
				ty = bornPos.y,
				dir = 4,
				px = "undefined",
				py = "undefined",
			},
--			{
--				skin = {},
--				level = 1,
--				max_hp = 100,
--				max_mp = 100,
--				move_speed = 100,
--				hp = 1000,
--				mp =100,
--				pos = {}
--			},
		},
		role_map_info = "undefined",
		return_self = true,
		
	--- 空的数据
		grafts = {},
		roles = {},
		trap_list = {},
		monsters = {},
		server_npcs = {},
		dropthings = {},
		dolls = {},
		pets = {},
	-----
	}
	return newValue
end
-- required int32              role_id =1;
--    required string             role_name =2;
--    required int32              sex  =3;
--    required int32              faction_id=4;
--    required int32              head =5;
--    required int32              category=6;
function fakeModel(info)
	local playerModel = PlayerModel.new()
	if not info then
		Log.info("fakeModel need parameter info not nil")
		return nil
	end
	
	playerModel.type = ElementType.player
	playerModel.level = 1
	playerModel.max_hp = 100
	playerModel.max_mp = 100
	playerModel.move_speed = 170
	playerModel.attack_speed = 50
	playerModel.hp = 1000
	playerModel.mp =100
	playerModel.pos = {}
	playerModel.id = info.roleId or 100086
	playerModel.tx = 24
	playerModel.ty = 16
	playerModel.tileX = 24
	playerModel.tileY = 16
	playerModel.min_phy_attack = 10
	playerModel.max_phy_attack = 11
	playerModel.hitCount = 0
	playerModel.resURL = info.resURL or "player113" --"player213"
	
	local skin = {
		assis_weapon = 0,
		fashion_wing = 0,
		mounts = 0,
		clothes = 0,

		hair_color = 1,
		hair_type = 1,
		fashion = 0,
		skinid = 1,
		light_code = "\0",
		weapon = 0,
	}
	playerModel.body = skin
	playerModel.name = DramaDataCenter.roleName
	playerModel.dir = 4
	playerModel.state = ElementState.stand
	playerModel.category = info.category 	-- swordPlayer
	GameConfig.CTPlayer = playerModel.category == 1 and SwordPlayer or (playerModel.category == 2 and ArcherPlayer or MagePlayer)

	return playerModel
end

return DramaSceneController