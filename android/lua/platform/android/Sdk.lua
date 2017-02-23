------------------------------------------------------
--作者: yhj
--日期: 2015年5月25日
--描述: 获取当前系统的sdk对象
------------------------------------------------------
Sdk = module("Sdk", package.seeall)

local curSdkInstance
local initInfo = {}
local noSdk = false

function getCurSdk()
	if noSdk then
		-- yzjprint("=========== no sdk found !")
		return
	end
	
	if curSdkInstance then
		return curSdkInstance
	end

	if not DataGlobal.isNoSdkPlatform() then
		if GameGlobal.isAndroid then
			curSdkInstance = (require "gamecore/platform/android/AndroidFusionSdk").new()
		elseif GameGlobal.iosPlat then
		end
	end

	if curSdkInstance == nil then
		noSdk = true
	end 

	return curSdkInstance
end
