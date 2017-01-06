------------------------------------------------------
--作者:	YuZhenJian
--日期:	2014年1月27日
--描述:	剧情副本的场景 
--说明:  和主场景的部分功能一致
------------------------------------------------------

DramaScene = CCclass("DramaScene", BaseLayer)

require "Player"
require "PlayerModel"
require "RoleModel"
require "MapElement"
require "NPCModel"
require "NPC"
require "MonsterModel"
require "Monster"
require "SkillManager"
require "MapElementModel"
require "NpcDataCenter"
require "MapFindPath"
require "GameMusic"
require "MapUtil"
require "FindPathParam"
require "EffectFactory"
require "EffSkillHurt"
require "ArcherPlayer"
require "MagePlayer"
require "CategoryDeal"
require "SkillFactory"

--等待添加的地图元素
local toAddMapImgArr = {}

local sharedScheduler = CCDirector:sharedDirector():getScheduler()

--地图切片数据字典
local fragmentVoDic
--加载了的切片
local loadedFragmentDic
local npcModelArr
--场景元素数组
local elementArr = false
--等待添加的元素
local toAddElementArr = {}
--等待删除的元素
local toRemoveElementArr = {}

--寻路
local findPath

--游戏场景层，也是最底层
local gameScene
--地图层
local mapLayer
--测试层
--local debugLayer
--效果层
local effectLayer
--元素层
local elementLayer

local clickEffect = false

local hangUpScheduleId
local visibleRect = VisibleRect
local visileWidth = visibleRect:getVisibleRect().size.width
local visibleHeight = visibleRect:getVisibleRect().size.height

local forceUpdateScene = false
local haveEnterScene = false
local isInJumpPoint = false
--------------------------------------
-- 以下是私有方法定义
--------------------------------------
local createRole
local createElement
local updateGameScene
local initMapFragment
local updateViewArea
local setViewPortCenter
--local clearSceneElement
local createNPC
local doubleClicked
local addElement
local onTouchBegan
local onTouchMoved
local onTouchEnded
local iWalkEndHandlerEx
local removeMapElementFromArrHandlerEx
local moveToPoint
local sceneChangedHandlerEx
local findPathMove
local checkIsNeedToFight
local setElementSelected
local lockElement
local selectedElement
local releaseSkillHandlerEx
local selectedAElementHandlerEx
local getNearestElement
local fightNextOneHandlerEx
local setViewPortCenterHandlerEx


local isNewFind = false
local selectedModel
local mapTileLoaded
local setElementSelectedHandlerEx
local isInAttackRange
local fightActionTag = 501

local isFirstEnterScene = true
local isManualViewPort = true --- 默认手动控制,由事件SET_VIEW_PORT_CENTER中的参数param.isManual改变

local updateSceneScheduleId

function DramaScene:init()
--	TipMessage.show("Drama Scene")
	elementArr = SceneDataCenter.getAllElements()
	
	isFirstEnterScene = true
	isManualViewPort = true
	
	local function onTouch(eventType, x, y)
		if eventType == "began" then
			return onTouchBegan(self, x, y)
		elseif eventType == "moved" then
			return onTouchMoved(self, x, y)
		else
			return onTouchEnded(self, x, y)
		end
	end

	self:registerScriptTouchHandler(onTouch, false, 0, false)
	self:setTouchEnabled(true)
	findPath = SceneDataCenter.getFindPath()

	--游戏场景层
	gameScene = CCLayer:create()
--	gameScene:setPositionY(visibleRect:getVisibleRect().size.height);
	self:addChild(gameScene)

	--元素层
	elementLayer 	= CCLayer:create()
	effectLayer		= CCLayer:create()
	--	debugLayer		= MapLayer:create()
	mapLayer		= CCLayer:create()

	gameScene:addChild(mapLayer)
	--	gameScene:addChild(debugLayer)
	gameScene:addChild(elementLayer)
	gameScene:addChild(effectLayer)

	--	clickEffect = CCSprite:createWithSpriteFrameName("common/clickEffect.png")
	--	clickEffect:setAnchorPoint(ccp(0.5, 0))
	--	effectLayer:addChild(clickEffect)
	myModel = RoleModel.new()

	haveEnterScene = false
	
	self.controller = false
	self.requestDropthingPickHandler = false
	self.requestCollectHandler = false

	--把场景元素从数组中删除
	EventDispatcher.addEventListener(EventType.REMOVE_MAP_ELEMENT_FROM_ARR, removeMapElementFromArrHandlerEx, self)
	
	--设置元素的选择与否
	EventDispatcher.addEventListener(EventType.SET_ELEMENT_SELECTED, setElementSelectedHandlerEx, self)
	
end

function DramaScene:removeRoleListener()
	
	EventDispatcher.removeEventListener(EventType.I_WALK_END, iWalkEndHandlerEx, self)
	--跳转状态监听函数
	EventDispatcher.removeEventListener(EventType.SCENE_CHANGED, sceneChangedHandlerEx, self)
	---放技能
	EventDispatcher.removeEventListener(EventType.FIGHT_BY_SKILL, releaseSkillHandlerEx, self)
	---点中场景元素
	EventDispatcher.removeEventListener(EventType.SELECTED_A_ELEMENT, selectedAElementHandlerEx, self)
	---攻击下个目标
	EventDispatcher.removeEventListener(EventType.FIGHT_NEXT_ONE, fightNextOneHandlerEx, self)
	---设置可视区中心点，格子坐标
	EventDispatcher.removeEventListener(EventType.SET_VIEW_PORT_CENTER, setViewPortCenterHandlerEx, self)
end


function DramaScene:unScheduleUpdateScene()
	Log.info("定时器停！" .. (updateSceneScheduleId or "nil"))
	if updateSceneScheduleId then
		Log.info("updateSceneScheduleId")
		
		sharedScheduler:unscheduleScriptEntry(updateSceneScheduleId)
		
		updateSceneScheduleId = nil
		
		haveEnterScene = false
		
		self:removeRoleListener()
		
		--把场景元素从数组中删除
		EventDispatcher.removeEventListener(EventType.REMOVE_MAP_ELEMENT_FROM_ARR, removeMapElementFromArrHandlerEx, self)
		--设置元素的选择与否
		EventDispatcher.removeEventListener(EventType.SET_ELEMENT_SELECTED, setElementSelectedHandlerEx, self)

	else
		Log.info("没有停止定时器！！！！1")
	end
end


local oldTileX, oldTileY, oldDir
function DramaScene:creatNewRole(roleModel)
	-- 删除旧主角
	if myRole then
--		myRole:updateTile()
		oldTileX = myRole.model.tileX
		oldTileY = myRole.model.tileY
		oldDir = myRole.model.dir
		
		local roleId = myRole.model.id
		elementArr["player" .. roleId] = nil
		myRole:setVisible(false)
		
--		myRole:removeAllChildrenWithCleanup(true)
		myRole:removeFromParentAndCleanup(true)
		
		myRole = false
		myModel = false
		
		if updateSceneScheduleId then
			sharedScheduler:unscheduleScriptEntry(updateSceneScheduleId)
			updateSceneScheduleId = nil
		end
		
		self:removeRoleListener()
	end
	
	-- 重新建主角
	local model = roleModel
	if model then
		if oldDir then
			model.dir = oldDir
		end
		if oldTileX and oldTileY then
			model.tileX = oldTileX
			model.tileY = oldTileY
		end
		self:setMyModel(model)
		createRole(self, model)
	end
end

local moduleName

function createRole(self, model)
	local model = model or myModel
	
--	Log.info("创建tileX:" .. myRole.model.tileX .. ",tileY:" .. myRole.model.tileY)
	
	if not myRole then
		
		package.loaded["Role"] = nil
		_G["Role"] = nil
		package.loaded["SwordRole"] = nil
		_G["SwordRole"] = nil
		package.loaded["ArcherRole"] = nil
		_G["ArcherRole"] = nil
		package.loaded["MageRole"] = nil
		_G["MageRole"] = nil
		
		if moduleName then
			package.loaded[moduleName] = nil
			_G[moduleName] = nil
		end
		
		require "Role"
		require "SwordRole"
		require "ArcherRole"
		require "MageRole"
		if model.category == 1 then
			myRole = SwordRole.new(model)
		elseif model.category == 2 then
			myRole = ArcherRole.new(model)
		elseif model.category == 3 then
			myRole = MageRole.new(model)
		end
--		myRole.model.lockRange = 11
--		myRole.model.attackRange = 11
		
--		myRole:showName(false)
		
--		Log.info("!!!!!!!!!!!!!!3tileX:" .. myRole.model.tileX .. ",tileY:" .. myRole.model.tileY)

		local myPoint
		if oldTileX and oldTileY then
			myPoint = MapUtil.getPixelPoint(ccp(oldTileX, oldTileY))
		else
			myPoint = MapUtil.getPixelPoint(ccp(model.tileX, model.tileY))
		end
		
		
	
		myRole:setPosition(myPoint)
		if not myRole:getParent() then
			if DramaDataCenter.roleNameColor then
				myRole.nameColor = DramaDataCenter.roleNameColor
			end
			elementLayer:addChild(myRole, 10000 - myPoint.y)
			
--			myRole:updateName("Kobe Bryant")

--			myRole:showName(true)
--			elementLayer:addChild(element, 10000 - element:getPositionY())
		end
--		myRole:updateTile()
		
		--寻路完成
		EventDispatcher.addEventListener(EventType.I_WALK_END, iWalkEndHandlerEx, self)
		--跳转状态监听函数
		EventDispatcher.addEventListener(EventType.SCENE_CHANGED, sceneChangedHandlerEx, self)
		---放技能
		EventDispatcher.addEventListener(EventType.FIGHT_BY_SKILL, releaseSkillHandlerEx, self)
		---点中场景元素
		EventDispatcher.addEventListener(EventType.SELECTED_A_ELEMENT, selectedAElementHandlerEx, self)
		---攻击下个目标
		EventDispatcher.addEventListener(EventType.FIGHT_NEXT_ONE, fightNextOneHandlerEx, self)
		---设置可视区中心点，格子坐标
		EventDispatcher.addEventListener(EventType.SET_VIEW_PORT_CENTER, setViewPortCenterHandlerEx, self)
		
		elementArr["player" .. model.id] = myRole
			
		updateSceneScheduleId = sharedScheduler:scheduleScriptFunc(function()updateGameScene(self)end, 0, false)
	else
		Log.info("!!!!!!!!!!!!myRole已经存在!!!!!!!!!!!!!!!!!!!！")
	end

end

--进入场景，初始化
function DramaScene:enterScene(sceneId)
	self:clearSceneElement()
	--读取地图信息
	currentSceneModel = MapUtil.getMapMCMData(sceneId)
	--设置寻路信息
	findPath:setMapData(currentSceneModel.tileMatrix, currentSceneModel.tileRow, currentSceneModel.tileColumn)
	initMapFragment()
	createNPC(self)
	forceUpdateScene = true
	haveEnterScene = true
	
	createRole(self)
	local myPoint = MapUtil.getPixelPoint(ccp(myModel.tileX, myModel.tileY))
	myRole:setPosition(myPoint)
	myRole:updateTile()
	
	----运行队列处理器
--	SceneDataCenter.runDealTable()
	
	isInJumpPoint = false
	updateGameScene(self)
	GameConfig.haveEnterScene = true
end

local findPathVo = false
local continueFind = false

function DramaScene:mapFindPath(findPathParam)
	findPathVo = findPathParam
	continueFind = false
	--跨场景
	if findPathParam.scenePath and #findPathParam.scenePath > 0 then
		local currentMapId = findPathParam.scenePath[1]
		if currentMapId ~= currentSceneModel.sceneId then
			local jumpPoint = elementArr["jumpPoint" .. currentMapId]
			if jumpPoint then
				local findParam = FindPathParam.create()
				findParam.type = FindPathType.point
				findParam.point = ccp(jumpPoint.model.tileX, jumpPoint.model.tileY)
				continueFind = true
				table.remove(findPathParam.scenePath, 1)
				findPathMove(self, findParam)
			else
				TipMessage.show("无法到达目的地")
			end
		else
			myRole.allPathEnd = true
			findPathMove(self, findPathVo)
		end
	else
		myRole.allPathEnd = true
		findPathMove(self, findPathVo)
	end
end

--------------------------------------
--	寻路移动
--------------------------------------
function findPathMove(self, findPathParam)
	local myTile = myRole:getTilePosition()

	--点寻路
	if findPathParam.type == FindPathType.point then
		local isCanReach = MapUtil.canReachPos(findPathParam.point.x, findPathParam.point.y)
		if isCanReach then
			myRole:moveToPoint(findPathParam.point)
		else
			TipMessage.show("不可到达")
		end
	
	--场景元素寻路
	else
		local element = getElementByPathParam(findPathParam)
		if element then--在屏幕上面就直接走过去
			SceneDataCenter.setLockElement(element)
			self:clickAElement(element)
		else--否则就从MCM地图上面找
			SceneDataCenter.setLockElement(false)
			for _, model in pairs(currentSceneModel.mapElementArr) do
				if model.id == findPathParam.targetId then
					local toX, toY = model.tileX, model.tileY
					selectedModel = model
					myRole:moveToPoint(ccp(toX, toY), model.toSelectTileNum, function()
						local element = getElementByPathParam(findPathParam)
						SceneDataCenter.setLockElement(element)
						self:clickAElement(element)
					end)
					break
				end
			end
		end
	end
end


--设置主角数据
function DramaScene:setMyModel(model)
	myModel = model or RoleModel.new()
end




---添加元素模型到等待添加的队列
function DramaScene:addToAddArr(model)
	local key = ElementTypeName[model.type] .. model.id
	toAddElementArr[key] = model
end

function DramaScene:getToAddElementArr()
	return toAddElementArr
end

---通过key（类型+id）查找场景元素
function DramaScene:getElement(key)
	return elementArr[key]
end

function DramaScene:setElementPosition(elementType, id, tx, ty)
	local key = ElementTypeName[elementType] .. id
	local element = elementArr[key]
	if element then
		local point = MapUtil.getPixelPoint(ccp(tx, ty))
		element:setPosition(point)
		element.model.tileX = tx
		element.model.tileY = ty
	end
end


--场景元素的移动
--@id		元素id
--@type		类型，参考MapElementModel里定义的ElementType
--@movePath	行路路径，ccpoint的数组
function DramaScene:elementMove(id, type, movePath ,dir)
	local key = ElementTypeName[type] .. id
	local element = elementArr[key]

	if element then
		element:moveTo(movePath)
	end
end

---添加要删除的元素模型到删除队列，等待删除
--@key typeName+id
function DramaScene:addToRemoveArr(key)
	local element = elementArr[key]
	if not tolua.isnull(element) then
		element:setVisible(false)
		element.isDead = true
		table.insert(toRemoveElementArr, element)
		elementArr[key] = nil
	end
end

--删除场景元素
--@key		类型名加id
function DramaScene:removeElementByKey(key)
	local element = elementArr[key]
	if not tolua.isnull(element) then
		element:removeFromParentAndCleanup(true)
		element = nil
		elementArr[key] = nil
	end
end

--加特效
function DramaScene:addEffect(effNode, layerType)
	if layerType == 1 then
		effectLayer:addChild(effNode)
	elseif layerType == 2 then
		mapLayer:addChild(effNode)
	end
end

function isInAttackRange(element)
	local targetPos = ccp(element:getPosition())
	local myPos = ccp(myRole:getPosition())
	local len = ccpDistance(myPos, targetPos)
	local attackRange = myRole.model.attackRange * MapUtil.TILE_WIDTH
	if len > attackRange + 22 then
		return false
	else
		return true
	end
end

--获得主角身边最近的一个场景元素
function getNearestElement(elementType, radius, elements)
	elementType = elementType or ElementType.monster--默认怪物
	local nearestMonster = nil
	radius = radius or 5000
	elements = elements or elementArr
	for _, element in pairs(elements) do
		if not tolua.isnull(element) and element.model then
			if Helper.isContainValue(myRole.model.canAttackElementType, element.model.type)
			 and not SceneDataCenter.isAMonsterDead(element) then
			 
				local myRolePos = ccp(myRole:getPosition())
				local elementPos = ccp(element:getPosition())
				local dis = ccpDistance(myRolePos, elementPos)

				if dis < radius then
					radius = dis
					nearestMonster = element
				end
				
			end
		end
	end
	return nearestMonster
end


--------------------------------------
--	寻找新的怪物攻击
--------------------------------------
function fightNextOneHandlerEx(self, param)
	
	----判断是否符合攻击类型
	if SceneDataCenter.lockElement and
		SceneDataCenter.lockElement.model and 
		not Helper.isContainValue(myRole.model.canAttackElementType, SceneDataCenter.lockElement.model.type) then
		
		SceneDataCenter.setLockElement(false)
		
	end
	
	
	local monster
	if not SceneDataCenter.isAMonsterDead(param.newValue) then
		monster = param.newValue
	elseif SceneDataCenter.isHaveLockElement() then
		monster = SceneDataCenter.lockElement
	else
		monster = getNearestElement()
	end
	
	
	if not SceneDataCenter.isAMonsterDead(monster) then
		SceneDataCenter.setLockElement(monster)
		
--		if not isInAttackRange(monster) then
			self:clickAElement(monster)
--		else
--			myRole:readyToAttack(monster)
--		end
	else
		SceneDataCenter.setLockElement(false)
	end
end

---设置可视区域中心点，使用格子坐标
function setViewPortCenterHandlerEx(self, param)
	local point = param.point
	local duration = param.duration
	if point and duration then
		point = MapUtil.getPixelPoint(point)
		point.x = visibleRect:center().x - point.x
		point.y = -visibleRect:center().y - point.y -- + visibleHeight
		setViewPortCenter(point.x, point.y, true, duration, param.isManual)
	else
		Log.error("设置可视区的事件参数不对")
	end
	
end


--------------------------------------
-- 以下是一些私有方法
--------------------------------------

local touchBeganX, touchBeganY
local nowX, nowY
local lastClickTime = 0

function onTouchBegan(self, x, y)
	
--	if not myRole or myRole.model.isCanMove == false then
--		Log.debug("角色不能走动~~不反应点击")
--		return false
--	end

    if tolua.isnull(myRole) then
        return false
    end
	
	local clickPoint = gameScene:convertToNodeSpace(ccp(x, y))


	local myPixelX, myPixelY = myRole:getPosition()
	
	isNewFind = false
	local maxZOrder = 100000
	for _, element in pairs(elementArr) do
		if not tolua.isnull(element) then
			local elementRect = element:boundingBox()
			local elementZOrder = element:getZOrder()
			if elementRect:containsPoint(clickPoint) and element ~= myRole and element.model.type ~= ElementType.jumpPoint and element.model.type ~= ElementType.pet then
				if elementZOrder < maxZOrder then
					selectedElement = element
					isNewFind = true
				end
				maxZOrder = elementZOrder
			end
		end
	end
	
	-----------双击地面-------------
    if not myRole.mountAnimation then
		local nowTime = msNow()
        local delay = nowTime - lastClickTime
        if delay < 0.2 then
            if not isNewFind then
                doubleClicked(self, x, y)
            end
            return false
        end
    end
	lastClickTime =  msNow()
	------------------------------
	
	local clickPixselPoint = clickPoint
	clickPoint = MapUtil.getTilePoint(clickPoint)

	
--	---点中了场景中的某个元素
	if isNewFind then
		---变大交互反馈
		local actAry = CCArray:create()
		actAry:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, 1.1)))
		actAry:addObject(CCScaleTo:create(0.1, 1))
		local action = CCSequence:create(actAry)
		selectedElement:runAction(action)
		
		
		SceneDataCenter.setLockElement(selectedElement)
		if myRole:clickElementLogic(selectedElement) then
			----设置当前角色选中的目标，让主界面显示还有地下画圈圈的标志
			self:clickAElement(selectedElement)
		end
		
		
	---点了地图（点地面）
	else
		---地标效果
		local eff = createAnimation("dibiao/%05d.png", 2, 0.4, false, 0, true)
		eff:setPosition(clickPixselPoint)
		eff:setAnchorPoint(ccp(0.5, 401 / 800))
		mapLayer:addChild(eff)
		
		
		local moveToPoint = ccp(clickPixselPoint.x, clickPixselPoint.y)
		
		---------可以走就走过去-------------
		myRole:clickMapLogic(clickPixselPoint, clickPoint)
		--------------------------------
		
	end

	
	
	return true
end

--------------------------------------
--	主角移动到元素旁边
--	aimElement				要移动到哪个元素
--	moveDoneCallBack		移动结束后调用的回调
--------------------------------------
function DramaScene:moveToElement(aimElement, moveDoneCallBack)
		----防止怪物删掉
	if SceneDataCenter.isAMonsterDead(aimElement) or type(aimElement) == "boolean" then
		SceneDataCenter.setLockElement(false)
		return
	end
	

	local tileNum = aimElement.model.toSelectTileNum
	local elementType = aimElement.model.type
	
--	if elementType == ElementType.monster and myRole.model.category ~= 1 then
--		tileNum = tileNum - 4
--	end
	
	local titlePos = aimElement:getTilePosition()
	return myRole:moveToPoint(titlePos, tileNum, moveDoneCallBack)
end


--------------------------------------
--	用户点击了屏幕内场景的某个元素的处理函数
--	参数：
--		element		哪个元素
--------------------------------------
function DramaScene:clickAElement(element)
	--移动到选择的场景元素周围
	local function afterMoveCallback()
		if SceneDataCenter.isAMonsterDead(element) or type(element) == "boolean" then
			SceneDataCenter.setLockElement(false)
			return
		end
		self:clickAElementHandler(element)
	end
	if not self:moveToElement(element, afterMoveCallback) then---真的有行走就会返回true，不是true就要手动调用回调
		afterMoveCallback()
	end
end


function doubleClicked(self, x, y)
	local clickPoint = gameScene:convertToNodeSpace(ccp(x, y))
	local myTilePos = MapUtil.getTilePoint(ccp(clickPoint.x, clickPoint.y))
	
	if myRole then
	   myRole:stopMove()
	   myRole:stopReleaseSkill()
	   myRole:requestFlashTo(clickPoint)
	end
end


function onTouchMoved(self, x, y)
	nowX, nowY = x, y
end

function onTouchEnded(self, x, y)
end


--初始化地图切片，计算他们位置
function initMapFragment()

	fragmentVoDic = {}
	loadedFragmentDic = {}
	local totalRow = math.ceil(currentSceneModel.mapHeight / MapUtil.MAP_FRAGMENT_HEIGHT)
	local totalColumn = math.ceil(currentSceneModel.mapWidth / MapUtil.MAP_FRAGMENT_WIDTH)
	local url = ""
	local key = ""
	for row = 0, totalRow - 1 do
		for column = 0, totalColumn - 1 do
			url = ResourceConfig.mapFragementRootPath .. currentSceneModel.pictureId .. "/" .. row .. "_" .. column .. ".jpg"
			local fragmentVo = {}
			fragmentVo["imageURL"] = url
			fragmentVo["row"] = row
			fragmentVo["column"] = column
			fragmentVo["x"] = column * MapUtil.MAP_FRAGMENT_WIDTH
			fragmentVo["y"] = - row * MapUtil.MAP_FRAGMENT_HEIGHT

			--如果是异步加载保存url，非异步加载保存key
			if GameConfig.isMapAsyncLoading then
				fragmentVoDic[url] = fragmentVo
			else
				key = row .. "_" ..column
				fragmentVoDic[key] = fragmentVo
			end
		end
	end
end

local left = MapUtil.MAP_FRAGMENT_WIDTH + MapUtil.MAP_FRAGMENT_WIDTH / 2
local right = visileWidth + MapUtil.MAP_FRAGMENT_WIDTH / 2
local down = MapUtil.MAP_FRAGMENT_HEIGHT / 2
local up = visibleHeight + MapUtil.MAP_FRAGMENT_HEIGHT + MapUtil.MAP_FRAGMENT_HEIGHT / 2

local function isInViewArea(pixelX, pixelY)
	local mapX, mapY = gameScene:getPosition()
	local screenX, screenY = mapX + pixelX, mapY + pixelY
	if screenX < right and screenX + left > 0
	and screenY + down > 0 and screenY < up then
		return true
	else
		return false
	end
end

--非异步加载时需要更新
local function loopLoadMapFragment(self)
	if not GameConfig.isMapAsyncLoading then
		local count = 0
		local tmpTab = {}
		for key, fragmentVo in pairs(toAddMapImgArr) do
			-- toAddMapImgArr[key] = nil
			table.insert(tmpTab, key)
			local fragmentSprite = CCSprite:create(key)
			if fragmentSprite then
				fragmentSprite:setAnchorPoint(ccp(0, 1))
				fragmentSprite:setPosition(fragmentVo.x, fragmentVo.y)
				mapLayer:addChild(fragmentSprite)
				--添加到已加载字典
				loadedFragmentDic[key] = fragmentSprite
			end
			count = count+1
			if count >=2 then
				break
			end
		end

		for k, v in pairs(tmpTab) do
			toAddMapImgArr[v] = nil
		end
	end
end

function mapTileLoaded(eventName, texture)
	local texture = tolua.cast(texture, "CCTexture2D")
	if texture then
		local path = texture:getPath()
		if path then
			local index = string.find(path, "images")
			local relativePath = string.sub(path, index)
			local fragmentVo = fragmentVoDic[relativePath]
			if fragmentVo then
				local fragmentSprite = CCSprite:createWithTexture(texture)
				if fragmentSprite then
					fragmentSprite:setAnchorPoint(ccp(0, 1))
					fragmentSprite:setPosition(ccp(fragmentVo.x, fragmentVo.y))
					mapLayer:addChild(fragmentSprite)
					--添加到已加载字典
					loadedFragmentDic[relativePath] = fragmentSprite
				end
			end
		end
	end
end

function updateViewArea(self)

	--同步或异步加载地图
	if GameConfig.isMapAsyncLoading then

		local fragmentSprite
		local mapTile
		for url, fragmentVo in pairs(fragmentVoDic) do
			mapTile = loadedFragmentDic[url]
			if isInViewArea(fragmentVo.x, fragmentVo.y)  then
				if not mapTile then
					CCTextureCache:sharedTextureCache():addImageAsync(url, mapTileLoaded, false)
				end
			else
				if mapTile then
					loadedFragmentDic[url] = nil
					mapTile:setVisible(false)
					table.insert(toRemoveElementArr, mapTile)
				end
			end
		end
	else
		local url
		local fragmentSprite
		local mapTile
		for _, fragmentVo in pairs(fragmentVoDic) do
			url = fragmentVo["imageURL"]
			mapTile = loadedFragmentDic[url]
			if isInViewArea(fragmentVo.x, fragmentVo.y)  then
				--		   不存在，创建新的添加
				if not mapTile then
					toAddMapImgArr[url] = fragmentVo
				end
			else
				if mapTile then
					--				mapTile:removeFromParentAndCleanup(true)
					loadedFragmentDic[url] = nil
					mapTile:setVisible(false)
					table.insert(toRemoveElementArr, mapTile)
				end
			end
		end
	end

	--更新可视区的npc
	for _, npcModel in pairs(npcModelArr) do
		local key = "npc" .. npcModel.id
		local npc = elementArr[key]
		local pixelNpcPoint = MapUtil.getPixelPoint(ccp(npcModel.tileX, npcModel.tileY))
		if isInViewArea(pixelNpcPoint.x, pixelNpcPoint.y)  then
			--不存在，创建新的添加
			if not npc and tolua.isnull(npc) then
				self:addToAddArr(npcModel)
			end
		else
			if npc and (not tolua.isnull(npc)) then
				self:addToRemoveArr(key)
			end
		end
	end
	
end

---预留边界10个像素
local extraEdge = 30
local updateViewPortActionTag = 190
--设置可视区域中心
function setViewPortCenter(pointX, pointY, isAction, delay, isManual)
	
	 --pointY = pointY + visibleHeight
    --pointY = pointY + frameHeight
    pointY = pointY + 640

	if pointX > visibleRect:left().x then
		pointX = visibleRect:left().x
	elseif pointX < -currentSceneModel.mapWidth + visibleRect:right().x then
		pointX = -currentSceneModel.mapWidth + visibleRect:right().x
	end

	if pointY < 640 then
		pointY = 640
	elseif pointY > currentSceneModel.mapHeight then
		pointY = currentSceneModel.mapHeight
	end
	
	--慢慢移动可视区，剧情需要
	if isAction then
		local actionArr = CCArray:create()
		actionArr:addObject(CCMoveTo:create(delay or 1, ccp(pointX, pointY)))
		actionArr:addObject(CCDelayTime:create(0.1))
		actionArr:addObject(CCCallFunc:create(function()
			isManualViewPort = isManual
		end))
		local sequence = CCSequence:create(actionArr)
		sequence:setTag(updateViewPortActionTag)
		gameScene:stopActionByTag(updateViewPortActionTag)
		gameScene:runAction(sequence)
	else
		gameScene:setPosition(ccp(pointX, pointY))
		myRole.mapPoint = ccp(pointX, pointY)
	end
end


function addElement(self, element)
--	local time = msNow()
	if element:getParent() then
		return
	end
	element.isDead = false
	elementLayer:addChild(element, 10000 - element:getPositionY())
--	element:updateTile()
--	Log.debug("创建花费：%f", msNow()-time)
end

---创建元素
function createElement(self, model)
	local key = ElementTypeName[model.type] .. model.id
	--已经存在了
	if elementArr[key] then
		elementArr[key].isDead = false
		return;
	end
	--	Log.info("添加"..model.id)
	local element = false
	local label = false
	if model.type == ElementType.monster then
		--model.resURL = "monster" .. model.imageID
		element = Monster.new(model)
		element:setPosition(MapUtil.getPixelPoint(ccp(model.tileX, model.tileY)))
		addElement(self, element)
		element:graduallyAppear()
		elementArr[key] = element
		if model.dir then
			element:updateState(ElementState.stand, model.dir)
		end
	elseif model.type == ElementType.npc then
		--model.resURL = model.skin
		if not model.skin then
			model.resURL = "player13"
			TipMessage.show("找不到动画 npc: ".. model.typeId)
		else
			model.resURL = model.skin
		end
		--		model.name = model.id

		if model.serverNPC then
			Log.info("--------创建了SeverNpc:%s", key)
			key = ElementTypeName[ElementType.serverNpc] .. model.id
		end
		element = NPC.new(model)
		if model.id == 11100888 then
			model.toSelectTileNum = 15
		end
		element:setPosition(MapUtil.getPixelPoint(ccp(model.tileX, model.tileY)))
		addElement(self, element)
		element:graduallyAppear()
		elementArr[key] = element
	elseif model.type == ElementType.player then
		if model.category == 1 then
			element = SwordPlayer.new(model)
		elseif model.category == 2 then
			element = ArcherPlayer.new(model)
		else
			element = MagePlayer.new(model)
	    end
	
		element:setPosition(MapUtil.getPixelPoint(ccp(model.tileX, model.tileY)))
		
		addElement(self, element)
		
		elementArr[key] = element
		if model.walkPath and #model.walkPath then
			self:elementMove(model.id, model.type, model.walkPath)
		end
		local state = SysSetupDataCenter.getHideOtherPlayer()
		local mapModel = MapDataCenter.getMapModelById(currentSceneModel.sceneId)
		if mapModel.mainUIType == 3 or mapModel.mainUIType == 6 or mapModel.mainUIType == 13 then
		else
			if myRole.model.id ~= model.id then
				element:setPlayerVisible(state)
			end
		end
	else
		local name = string.format("%d(%d, %d)", model.type, model.tileX, model.tileY)
		label = ComponentFactory.createLabel(name, GameConfig.getAutoSizeFont(20))
		label:setPosition(MapUtil.getPixelPoint(ccp(model.tileX, model.tileY)))
		addElement(self, label)
	end
	
end


function DramaScene:clearSceneElement()
	setElementSelected(self, false)
	SceneDataCenter.setLockElement(false)
	if mapLayer then
		mapLayer:removeAllChildrenWithCleanup(true)
	end
	if effectLayer then
		effectLayer:removeAllChildrenWithCleanup(true)
	end
	---删除场景元素，除了主角
	for key, element in pairs(elementArr) do
		if element ~= myRole and not tolua.isnull(element) then
			element:removeFromParentAndCleanup(true)
			elementArr[key] = nil
		end
	end
	---清除待删除队列的元素
	for key, element in pairs(toRemoveElementArr) do
		if not tolua.isnull(element) then
			element:removeFromParentAndCleanup(true)
			toRemoveElementArr[key] = nil
		end
	end
    if myRole then
        myRole:stopAttack()
    end
	-- CCTextureCache:sharedTextureCache():removeUnusedTextures()
	-- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end

local time = 0
local checkJumpTimer = 0
--上一次的坐标
local lastX = 0
local lastY = 0
local myOldX, myOldY
local myPositionChanged

--更新场景
function updateGameScene(self)
	local start = msNow()
	if tolua.isnull(myRole) then
		Log.error("************主角被删除了，但是场景定时器还在继续*****************")
		return
	end

	time = time + 1
	if time > 10000 then
		time = 0
	end

	local roleState = myRole.model.state
	local roleModel = myRole.model
	
	
	local myPositionX, myPositionY = myRole:getPosition()
	if myPositionX ~= myOldX or myPositionY ~= myOldY then
		myPositionChanged = true
		myRole.isMoving = true
		myRole:watchAroundLogic()
	else
		myRole.isMoving = false
		myPositionChanged = false
	end
	
	
--	myRole:watchAroundLogic()
	myOldX, myOldY = myPositionX, myPositionY
	
--	if roleState == ElementState.walk or forceUpdateScene or roleState == ElementState.attack then
	if not isFirstEnterScene then
		if not isManualViewPort then
			local mapX = visibleRect:center().x - myPositionX
			local mapY = -visibleRect:center().y - myPositionY -- + visibleHeight
			-- 设置地图可视区域中心点
			setViewPortCenter(mapX, mapY)
		end
	else
		isFirstEnterScene = false
		local viewportPos = MapUtil.getPixelPoint(DramaDataCenter.viewPortInitPos)
		viewportPos.x = visibleRect:center().x - viewportPos.x
		viewportPos.y = -visibleRect:center().y - viewportPos.y -- + visibleHeight
		setViewPortCenter(viewportPos.x, viewportPos.y)
	end

	-----------------------------行走碰撞的检测(防止贴脸代码)----------------------
	local myTile = MapUtil.getTilePoint(ccp(myPositionX, myPositionY))
	--人物走动时
	if myPositionChanged or forceUpdateScene or myRole.isManualViewPort then
		if not forceUpdateScene and (myTile.x ~= lastX or myTile.y ~= lastY) then
			--记录上一次
			lastX = myTile.x
			lastY = myTile.y
			
			roleModel.tileX = myTile.x
			roleModel.tileY = myTile.y
		end
	end
	
	if math.fmod(time, 30) == 0 or forceUpdateScene then
		updateViewArea(self)
	end
	
	if haveEnterScene then
		--删除场景元素
		for key, element in pairs(toRemoveElementArr) do
			if not tolua.isnull(element) then
				if element.model and element.model.type == ElementType.monster then
					Log.debug("==========真的删除%d", element.model.id)
				end
				element:removeFromParentAndCleanup(true)
				element = nil
			end
			toRemoveElementArr[key] = nil
			break
		end
	end

--	if haveEnterScene and (math.fmod(time, 5) == 0) then
		--场景元素添加
		for key, model in pairs(toAddElementArr) do
			toAddElementArr[key] = nil
			createElement(self, model)
--			break
			Log.info("场景元素添加".. model.id)
		end
--	end
--	local cost = msNow() -  start
--	if cost > 0.05 then
--		Log.debug("====刷新场景花费：%f", cost)
--	end
	loopLoadMapFragment()
	forceUpdateScene = false
end



--创建地图上放置的NPC
function createNPC(self)
	npcModelArr = {}
	for key, element in pairs(currentSceneModel.mapElementArr) do
		if element.type == ElementType.npc then
			local npcModel = NpcDataCenter.getNpcById(element.id)
			if not npcModel then
				Log.error("客户端没有npc%d的配置", element.id)
				npcModel = NPCModel.new()
			end
			npcModel.id = element.id
			npcModel.tileX = element.tileX
			npcModel.tileY = element.tileY
			npcModel.type = element.type
			npcModel.idontKnow = element.idontKnow
			--			createElement(self, npcModel)
			table.insert(npcModelArr, npcModel)
		end
	end
end

---[[
-- 在某路径基础上在目标点附近找另一个目标点创建一个新路径



--根据指定路径移动主角到目标点
function moveToPoint(self, point)
	local tileNum
	local elementType = false
	--如果有选中元素，寻路时走到选中元素附近就行了
	if isNewFind and (selectedElement or selectedModel) then
		if selectedElement then
			tileNum = selectedElement.model.toSelectTileNum
			elementType = selectedElement.model.type
		else
			tileNum = selectedModel.toSelectTileNum
			elementType = selectedModel.type
		end
		tileNum = tileNum or 2
	end
	if elementType == ElementType.monster then
		tileNum = myRole.model.attackRange - 2
	end
	myRole:moveToPoint(point, tileNum)
end

function lockElement(self, element, lock)
	if lock then
		isNewFind = true
		if not tolua.isnull(SceneDataCenter.lockElement) then
			SceneDataCenter.lockElement:showName(false)
		end
	end
	if lock then
		SceneDataCenter.setLockElement(element)
	else
		SceneDataCenter.setLockElement(false)
	end
	if not tolua.isnull(element) then
		element:showName(lock)
	end
end

local tryFindId = 0
local tryTimes = 0
local tryMaxTimes = 10

function setElementSelected(self, select)
	--选中
	if select then
		if not tolua.isnull(selectedElement) then
			if selectedElement.selected then
				lockElement(self, selectedElement, true)
				selectedElement:selected(true)
			end
			--通过mcm中找到的
		elseif selectedModel then
			local findPathType = false
			local element = false
			local findPathParam = FindPathParam.create()
			findPathParam.targetId = selectedModel.id
			if selectedModel.type == 5 then
				findPathType = FindPathType.monster
				element = getNearestElement()
			elseif selectedModel.type == ElementType.npc then
				findPathType = FindPathType.npc
				local key = ElementTypeName[ElementType.npc] .. selectedModel.id
				element = elementArr[key]
			elseif selectedModel.type == ElementType.collect then
				findPathType = FindPathType.collect
				element = getNearestElement(ElementType.collect)
			end

			--如果本场景找到了
			if element then
				local sx, sy = element:getPosition()
				local mx, my = myRole:getPosition()
				local dis = MapUtil.distance(ccp(sx, sy), ccp(mx, my))
				--直接选中
				if dis < (element.model.toSelectTileNum * 20 or 40) then
					if not tolua.isnull(element) then
						if element.selected then
							lockElement(self, selectedElement, true)
							element:selected(true)
						end
					end
					return
				end
				findPathParam.targetId = element.model.id
				if findPathType == FindPathType.collect then
					findPathParam.targetId = element.model.typeId
				end
				if findPathType then
					findPathParam.type = findPathType
					findPathMove(self, findPathParam)
				end
				--没找到，可能在其他场景
			else
				if findPathType then
					local function findPath()
						findPathParam.type = findPathType
						local eventParam = EventParam.create()
						eventParam.isGlobal	= true
						eventParam.newValue	= findPathParam
						EventDispatcher.dispatchEvent(EventType.FIND_PATH_EVENT, eventParam)
					end

					if findPathParam.targetId ~= tryFindId then
						tryFindId = findPathParam.targetId
						tryTimes = 0
					else
						tryTimes = tryTimes + 1
					end
					if tryTimes > tryMaxTimes then
						tryTimes = 0
						Log.error("我已经尽力了，还是找不到:%d", tryFindId)
						return
					end
					performWithDelay(self, findPath, 0.5)
				end
			end

		end
		--取消选中
	else

		selectedModel = false
		selectedElement = false
	end
end

function checkIsNeedToFight(self)
	--防止攻击状态下继续检测
	if myRole.model.state ~= ElementState.stand then
		return
	end
	myRole.isCanFightNow = true
	local monster = false
	--没有选中怪物
	if tolua.isnull(SceneDataCenter.lockElement) then
		local elements = SceneDataCenter.getSectorAreaElements(myRole, nil, nil, myRole.model.dir)
		if #elements > 0 then
			monster = getNearestElement(ElementType.monster, nil, elements)
--			myRole:updateState(ElementState.stand)
		end
	--有选中，并且是怪物，那就攻击这个
	elseif SceneDataCenter.lockElement.model.type == ElementType.monster then
		monster = SceneDataCenter.lockElement
	end
	
	if not tolua.isnull(monster) then
		if monster.isDead then
			SceneDataCenter.setLockElement(false)
			fightNextOneHandlerEx(self, {})
		else
			local targetPos = ccp(monster:getPosition())
			local myPos = ccp(myRole:getPosition())
			local len = ccpDistance(myPos, targetPos)
			local lockRange = myRole.model.lockRange * MapUtil.TILE_WIDTH
			if len < lockRange then
				lockElement(self, monster, true)
				fightNextOneHandlerEx(self, {newValue = monster})
--				myRole:fightRequest(monster)
				return
			else
--				myRole:updateState(ElementState.stand)
			end
		end
	end
end

---寻路完成
function iWalkEndHandlerEx(self, param)
end

function sceneChangedHandlerEx(self, param)
	--切换地图后，更改当前背景音乐
	GameMusic.playMusicBySceneChange(param)
	--	if param.newValue ~= 0 then
	EffectFactory.playEnterSceneEffect()
	--	end
	myRole:setMoveEnable(true)
	local sceneId = param.newValue
	if sceneId ~= 0 and continueFind then
		self:mapFindPath(findPathVo)
	end
end

function DramaScene:clickAElementHandler(element)
	----怪物
	if element.model.type ==  ElementType.monster then
		SceneDataCenter.setLockElement(element)
		myRole:readyToAttack(element)
	----普通NPC
	elseif element.model.type ==  ElementType.npc then
		local dir = MapUtil.judgeDir(ccp(myRole:getPosition()), ccp(element:getPosition()))
		myRole:stopMove(true)
		myRole:updateState(ElementState.stand, dir)
		
		local eventParam = EventParam.create()
		eventParam.isGlobal	= true
		eventParam.newValue	= element.model
		EventDispatcher.dispatchEvent(EventType.SELECTED_A_ELEMENT, eventParam)
	else
		TipMessage.show("未知场景元素类型，不处理")
	end
end

--点击了主界面的快捷键要播放技能和发送攻击协议
function releaseSkillHandlerEx(self, param)
	local skillId = param.newValue.id
	print("点击了主界面的快捷键要播放技能和发送攻击协议")
	myRole.model.wantToReleaseSkillID = skillId
	
	local selectedElement = SceneDataCenter.lockElement
	
	if tolua.isnull(selectedElement) then
		if currentSceneModel.sceneId == 10323 then
			selectedElement = SceneDataCenter.getAllElements()
			for _, v in pairs(selectedElement) do
				if v ~= myRole then
					selectedElement = v
					break
				end
			end
		else
			selectedElement = SceneDataCenter.getRecentlyElement(myRole, 700)
		end
	end
	
	if not tolua.isnull(selectedElement) and not Helper.isContainValue(myRole.model.canAttackElementType, selectedElement.model.type) then
		selectedElement = SceneDataCenter.getRecentlyElement(myRole, 700)
	end
	
	
	if selectedElement then
		if selectedElement.model.type == ElementType.monster or currentSceneModel.sceneId == 10323 then
			if SkillEffectDataCenter.isSpecialDeal(skillId) then
				local aimPos = ccp(selectedElement:getPosition())
				local tilePoint = MapUtil.getTilePoint(aimPos)
				
				myRole:moveToPoint(tilePoint, selectedElement.model.toSelectTileNum, function()
					myRole:releaseSkill(skillId, selectedElement)
				end)
				
			else
				local eventParam = EventParam.create()
				eventParam.isGlobal	= true
				eventParam.newValue	= selectedElement
				EventDispatcher.dispatchEvent(EventType.FIGHT_NEXT_ONE, eventParam)
			end
		end
	end
end

---选中一个场景元素
function selectedAElementHandlerEx(self, param)
--	local elementModel = param.newValue
--	local atkSceneIdList = {10501, 10325, 10323}
--
--	if elementModel.type ==  ElementType.monster then
--		myRole.isCanFightNow = true
----		if isInAttackRange(selectedElement) then
--			myRole:fightRequest(selectedElement)
----		else
----			fightNextOneHandlerEx(self, {newValue = selectedElement})
----		end
--	elseif elementModel.type ==  ElementType.npc and elementModel.serverNPC then
--		if elementModel.npc_country ~= myRole.model.faction_id then
----			if isInAttackRange(selectedElement) then
--				myRole:fightRequest(selectedElement)
----			else
----				fightNextOneHandlerEx(self, {newValue = selectedElement})
----			end
--		end
--	elseif elementModel.type ==  ElementType.collect then
--		if self.requestCollectHandler then
--			self.requestCollectHandler(self.controller, elementModel.id)
--		end
--	end

end


---移除场景元素
function removeMapElementFromArrHandlerEx(self, param)
	local elementModel = param.newValue
	if elementModel then
		local key = ElementTypeName[elementModel.type] .. elementModel.id
		self:addToRemoveArr(key)
	end
end

function setElementSelectedHandlerEx(self, param)
	local isSet = param.newValue
	setElementSelected(self, isSet)
end