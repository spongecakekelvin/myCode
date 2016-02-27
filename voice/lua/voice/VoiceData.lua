module("VoiceData", package.seeall)
local luaj
if GameGlobal.isAndroid then
 luaj = require("luaj")
end

-- 是否可执行语音听写
function isVoiceExecutable()
	if GameGlobal.isAndroid then
        return true
    end
-- gprint("== not isAndroid")
    return false
end


-- 安卓版本支持语音
local isAndroidSupported = nil -- 用于只判断一次

function isAndroidVersionSupported()
	if isAndroidSupported ~= nil then
		return isAndroidSupported
	end

	if not GameGlobal.isAndroid then
		return false
	end

	if DataGlobal.getCppVersion() < 10126 then
		isAndroidSupported = false
	else
		isAndroidSupported = true
	end
    
    return isAndroidSupported
end


-- 开发者身份验证密钥
local accessToken = ""

function isVoiceSupported()
	--do return true end -- 暂时屏蔽，等待审核和amr格式优化

	if (not accessToken or accessToken == "") then
		gprint("== isVoiceSupported == 111111111111")
		return false
	end

	if (not isVoiceExecutable()) then
		gprint("== isVoiceSupported == 222222222")
		return false
	end

	if (not isAndroidVersionSupported()) then
		gprint("== isVoiceSupported == 3333333333")
		return false
	end

    return true
end


function setAccessToken(at)
	accessToken = at
--	 gprint(debug.traceback() .. " === setAccessToken==" .. accessToken)
	 --gprint(" === setAccessToken==" .. accessToken)
	if isAndroidVersionSupported() then
		 luaj.callStaticMethod("com/jooyuu/GameUtil", "setAccessToken", {accessToken},"(Ljava/lang/String;)V")
	end
end
    
-- //频道聊天
-- message m_chat_in_channel_tos{
--     required string          channel_sign    = null;//频道标记
--     required string			  msg            = null;//聊天内容
--     optional string          voice_guid      = null;//聊天语音的唯一标识
--     optional int32           voice_len       = 0;   //聊天语音的时长
-- }

-- message m_chat_in_channel_toc{
--     required bool            succ           = true;//成功失败标记
--     optional string          reason         =null;//失败原因
--     optional string          channel_sign   =null;//频道标记
--     optional string          msg            = null;//聊天内容
--     optional string          voice_guid     = null;//聊天语音的唯一标识
--     optional int32           voice_len      = 0;   //聊天语音的时长
--     optional p_chat_role     role_info      = null;//信息发送者角色信息
--     optional int32           tstamp         = 0;//时间戳
-- }


-- message m_chat_req_voice_toc{
--     required bool            succ               = true;//成功失败标记
--     optional string          reason             = null;//失败原因
--     optional string          local_voice_id     = null;//本地的语音文件ID
--     optional string          voice_guid         = null;//聊天内容
--     optional int32           tstamp             = 0;//时间戳
--     optional string          sign               = null;//验证签名
-- }


--[[ 
录音完成 生成本地唯一的local_voice_id 和对应名字的录音文件
发送m_chat_req_voice_tos 字段有local_voice_id
m_chat_req_voice_tosc获得guid,stamp,sign, 根据local_voice_id将本地的录音文件重命名为guid
 if succ then
 	上传录音文件(guid,stamp,sign)
 	上传成功回调中： 发送m_chat_in_channel_tos ：文字,voice_guid,voice_len

----- \/
 	收到m_chat_in_channel_toc 
 	查找guid对应的本地录音文件是否存在
 	if exists then --是本人接收
 		显示在界面中，没红点
 	else --其他玩家接收
 		请求下载
 		下载成功回调： 显示在界面中，读取本地的红点记录
	end
 end

 上传/下载所需参数
 http://s2release.jooyuu.com/api/
..  "put_voice.php"
..  "get_voice.php"
"?guid=xxxx&stamp=xxx&sign=xxx"

]]--

--[[
录音成功 生成本地唯一的local_voice_id 和对应名字的录音文件

http语音识别 获取识别文字

if succ｛
	请求voice_guid 发送m_chat_req_voice_tos 字段有local_voice_id
	重命名本地文件
	上传录音文件 成功{
		发送m_chat_in_channel_tos + 识别文字
	}
｝

]]--

local isPathChanged = false

local function isWritePathChanged()
	return (isPathChanged)
end



local writablePath = nil
--local function getWritablePath()
--	return writablePath or (cc.FileUtils:getInstance():getWritablePath() .. "voice/")
----	return writablePath
--end


local oldWritePath = nil
-- 获取保存录音文件路径
function getWritePath()
	return writablePath
--	local writePath =  getWritablePath()
--	local writePath = cc.FileUtils:getInstance():getWritablePath() .. "iflytek/"
	-- local writePath = /storage/emulated/0/iflytek/
--	if not cc.PlFileLoader:isDirectoryExist(writePath) then
--		cc.PlFileLoader:createDirectory(writePath)
--	end
--
--
--
--	if oldWritePath and writePath ~= oldWritePath then
--		isPathChanged = true
--	else
--		isPathChanged = false
--	end
--
--	oldWritePath = writePath
--
--	return writePath
end


local voiceUrl = "http://cc-static.jooyuu.com/voice/"
--local voiceUrl = "http://172.22.10.117/api/"
function setUrl(url)
	voiceUrl = url
end

local urlType = {
	["put"] = "put_voice.php?",
	["get"] = "get_voice.php?",	
}

-- 	 生成上传/下载URL
local function genVoiceUrl(typeStr, guid, tstamp, sign)
--  http://s2release.jooyuu.com/api/
-- ..  "put_voice.php"
-- ..  "get_voice.php"
-- "?guid=xxxx&stamp=xxx&sign=xxx"
	local str = voiceUrl .. typeStr .. "guid=" .. guid

	if tstamp then
		str = str .. "&" .. "tstamp=" .. tstamp
	end

	if sign then
		str = str .. "&" .. "sign=" .. sign
	end

	return  str
end

function getAbsFileUrl(voiceId)
--	if not voiceId then
--		gprint(debug.traceback())
--	end
	return getWritePath() .. voiceId .. ".amr"
end



local localVoiceId = 0

local resultStr = ""

local voiceInfo = {
	local_voice_id     = "",	--//本地的语音文件ID
	voice_guid         = "", --//聊天内容
	tstamp             = 0;	--//时间戳
	sign               = "", --//验证签名
}

local channelIndexKeyMap = {} --local_id 对应channelIndex

function saveRecognizeVoiceId(voiceId)
	localVoiceId = voiceId
	channelIndexKeyMap[voiceId] = 5
--	channelIndexKeyMap[voiceId] = ctl.ChatController:getViewPageIndex()
end

function getChannelIndex(localVoiceId)
	return channelIndexKeyMap[localVoiceId]
end

-- 生成唯一的本地录音id, （type为string） 第一次可能循环多次
local lastGenId = 0
local maxGenTimes = 500

function genLocalVoiceId()
	local id = lastGenId -- 先用0.pcm文件 测试
	local filename 

	local count = 0 --大于最大生成次数就跳出, 使用0

	while true do
		id = id + 1
		filename = getAbsFileUrl(id)
		-- 查找该文件是否已存在 (本地 和 内存)
		if not (cc.PlFileLoader:getFileLength(filename) > 0) 
			and (not channelIndexKeyMap[id]) then
			break
		end
		
		count = count + 1
		if count > maxGenTimes then
			id = 0 
			break
		end
	end

	lastGenId = id
	return tostring(id)
end


function saveResultStr(str)
	resultStr = str

    if (not resultStr) or (resultStr and resultStr == "") then
    	ui.showTip("无效的语音!")
    	return 
    end

    VoiceController.requestVoiceInfo(localVoiceId) -- 这里localVoiceId会有延时
end


function saveCurrentVoiceInfo(msg)
	voiceInfo = {
		local_voice_id = msg.local_voice_id ,	--//本地的语音文件ID
		voice_guid     = msg.voice_guid     , --//聊天内容
		tstamp         = msg.tstamp         ;	--//时间戳
		sign           = msg.sign           , --//验证签名
	}
	--printTable(voiceInfo)
	--gprint("=== voiceInfo ==== ")
	
	--- 重命名
	if voiceInfo.local_voice_id and voiceInfo.local_voice_id ~= "" then
		VoiceController.renameFile(VoiceData.getAbsFileUrl(voiceInfo.local_voice_id), VoiceData.getAbsFileUrl(voiceInfo.voice_guid))
	end

	putVoiceByLoader(voiceInfo.voice_guid, voiceInfo.tstamp, voiceInfo.sign, function()
		-- 上传成功回调中： 发送m_chat_in_channel_tos ：文字,voice_guid,voice_len
		if not resultStr then
			resultStr = "语音未识别"
		end
		if resultStr=="" then
			resultStr = "语音未识别"
		end
		ccprint("putVoiceByLoader*********************")

		local msgstr = resultStr
		if string.len(resultStr) > 90 then
			local substr = string.sub(resultStr,1,90)
			msgstr = StringUtil.lua_string_removechar(substr)
		end

--		ctl.ChatController:sendChannelMsg(getChannelIndex(voiceInfo.local_voice_id), resultStr, voiceInfo.voice_guid, getVoiceTime(voiceInfo.local_voice_id))
		local chatchannel = getChannelIndex(voiceInfo.local_voice_id)

		if chatchannel == 3 then ---行会频道
			if DataGlobal.role.base.family_id == 0 then
				ui.showTip("当前没在行会中！")
				return 
			end
		elseif chatchannel == 4 then ---组队频道
			if myRole.team_id == 0 then
				ui.showTip("当前没在队伍中！")
				return
			end
		end
		Dispatcher.dispatchEvent(EventType.SEND_CHAT_MESSAGE,{channelIndex = chatchannel, msg = msgstr, voice_guid=voiceInfo.voice_guid,voice_len=getVoiceTime(voiceInfo.local_voice_id)})
	end)
end


--function setWritePath()

-- java中传入sd卡路径到lua, 将会调用lua函数 setWritalePath
function setAndoirdWritePath()

--	local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","lua_getExternalStorageDirectory", {}, "()Ljava/lang/String;")
	local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","getDiskCacheDir", {}, "()Ljava/lang/String;")

	if not ok then
		ccprint("setAndoirdWritePath  call return error = ", ret )
		writablePath = (cc.FileUtils:getInstance():getWritablePath() .. "/voice/")
	else
		ccprint("setAndoirdWritePath  call return succ = ", ret )
		writablePath = ret.. "/voice/"
	end

	if not cc.PlFileLoader:isDirectoryExist(writablePath) then
		cc.PlFileLoader:createDirectory(writablePath)
	end


if DataGlobal.getCppVersion() >= 10126 then
--	NotifyOnScreen.add("准备清理语音资源，请等待!")

	TimerManager.addTimeOut(function()
		local ok, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxActivity","DeleteDir", {writablePath}, "(Ljava/lang/String;)V")

		if not ok then
			ccprint("DeleteDir  call return error = ", ret )
		else
			ccprint("DeleteDir  call return succ = ", ret )
		end

		if not cc.PlFileLoader:isDirectoryExist(writablePath) then
			cc.PlFileLoader:createDirectory(writablePath)
		end

	end,0.5)
end




end

-- 上传
local lastspeaktime = 0
function putVoiceByLoader(voice_guid, tstamp, sign, callback)
	local url = genVoiceUrl(urlType.put, voice_guid, tstamp, sign)
	--gprint(url)

	local filename = getAbsFileUrl(voice_guid)
	--gprint(filename)
	
	if not (cc.PlFileLoader:getFileLength(filename) > 0) then -- 文件不存在 
		if isWritePathChanged() then
			local filename = getFilenameFromOldPath(voice_guid)
			--gprint("上传文件不存在,filename==" .. filename)
		
			if not (cc.PlFileLoader:getFileLength(filename) > 0) then -- 文件不存在 
				--gprint("上传文件还是不存在" .. filename)
				return
			end
		else
			--gprint("上传文件不存在" .. filename)
			return
		end
	end



	local callbackEx = function(succ, url, filen)
		--gprint("==== 上传回调 ==== ")
		if succ then
			callback()
			ccprint("==== 上传成功 ==== ")
		else
			NotifyOnScreen.add("语音发送失败")
		end
		lastspeaktime = GameGlobal.serverTime
	end

--	require("gamecore/modules/voice/LuaPutLoader")
--	LuaPutLoader.init()
	LuaPutLoader.putFile(url, filename, callbackEx)
end

function getLastSpeakingTime()
	return lastspeaktime
end


-- 下载
function getVoiceByLoader(voice_guid, callback)
	local url = genVoiceUrl(urlType.get, voice_guid)
	--gprint(url)

	local filename = getAbsFileUrl(voice_guid)
	--gprint(filename)

	if (cc.PlFileLoader:getFileLength(filename) > 0) then -- 文件存在 
		--gprint("下载文件已存在")
		return
	end

	local callbackEx = function(succ, url, filen)
		--gprint("==== 下载回调 ==== ")
		if succ then
			-- 下载成功回调： 显示在界面中，读取本地的红点记录
			callback()
		else
			NotifyOnScreen.add("语音下载失败")
		end
	end

--	require("update/LuaPutLoader")
--	LuaPutLoader.init()
	LuaPutLoader.getFile(url, filename, callbackEx)
end



local timeRecord = {}

-- 记录录音时长
function recordBeganTime(localVoiceId)
	timeRecord[localVoiceId] = getTimer()
end

function recordEndedTime(localVoiceId)
	if timeRecord[localVoiceId] then
		timeRecord[localVoiceId] = math.ceil((getTimer() - timeRecord[localVoiceId])/1000)
	end
end

-- 录音市场
function getVoiceTime()
	local voiceTime = timeRecord[localVoiceId]
	voiceTime = voiceTime or 0
	voiceTime = voiceTime < 0 and 0 or voiceTime
	return voiceTime
end



-- 下载中
local downloadingRecord = {}
function setDownloadingRecord(voice_guid)
	downloadingRecord[voice_guid] = true
end

function getDownloadingRecord()
	return downloadingRecord[voice_guid]
end

-- 未读语音
local unreadRecord = {}

function setUnread(voice_guid, unreadState)
	unreadRecord[voice_guid] = unreadState
end

function getUnread(voice_guid)
	return unreadRecord[voice_guid]
end


function getRecordTime()
	return 15
end

