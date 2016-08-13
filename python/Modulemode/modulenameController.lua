------------------------------------------------------
--作者:	#name
--日期:	#time
--描述:	主要负责事件的收发，更新datacenter的数据
------------------------------------------------------
module("#modulenameController", package.seeall)
local curPath = "gamecore/modules/#littlemodulename/"
require (curPath.."#modulenameModel")
local #modulenameModel = #modulenameModel:getInstance()
local #modulenameview

------------------------------------------------------------
--		初始化监听
------------------------------------------------------------
function init()
	Dispatcher.addEventListener(EventType.#allbigmodulename, openClose#modulenameView)
end

------------------------------------------------------------
--	处理界面打开与关闭处理
------------------------------------------------------------
function openClose#modulenameView(param)
	Helper.hotUpdate(curPath.."#modulenameView")

	if not param.tag or param.tag == "open" then
		if not ui.isExist(#modulenameview) then
			ui.addPlist("allPlist/#littlemodulename.plist")
			#modulenameview = require(curPath.."#modulenameView").new(param)
			PanelManager.pushView(#modulenameview)
		end
	else
		ui.removePlist("allPlist/#littlemodulename.plist")
		PanelManager.popView(#modulenameview)
	end
end

------------------------------------------------------------
--		以下是收到协议处理
------------------------------------------------------------


------------------------------------------------------------
--		以下是发送协议处理
------------------------------------------------------------
