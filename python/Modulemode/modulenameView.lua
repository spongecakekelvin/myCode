------------------------------------------------------
--作者:	#name
--日期:	#time
--描述:	#desc
------------------------------------------------------
local BaseClass = ui.#parent
local #modulenameView = class("#modulenameView",BaseClass)
local #modulenameModel = #modulenameModel:getInstance()
local curPath = "gamecore/modules/#littlemodulename/"
------------------------------------------------------
--界面初始化
------------------------------------------------------
function #modulenameView:ctor(param)
	BaseClass.ctor(self)
	self.param = param or {}
	self.layout = ui.newLayoutUtil#yourshortname("#modulenameView", true)
end


function #modulenameView:onEnter()
	BaseClass.onEnter(self)
	
end


function #modulenameView:onExit()
	BaseClass.onExit(self)
end


function #modulenameView:onCloseClickedHandler()
    Helper.throwEvent(EventType.#allbigmodulename, {tag = "close"})
end


return #modulenameView
