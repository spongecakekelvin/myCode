------------------------------------------------------
--作者:	#name
--日期:	#time
--描述:	数据中心
------------------------------------------------------
local BaseClass = require "gamecore/ui/uiBaseClasses/BaseModel"
#modulenameModel = class("#modulenameModel", BaseClass)

------------------------------------------------------
--		定义model的数据
------------------------------------------------------
function #modulenameModel:initModel()
    self.m_data = {}
end

--@brief 取得所有数据
function #modulenameModel:getData()
	return self.m_data
end

------------------------------------------------------
--		该model的提供的接口
------------------------------------------------------




local instance
---单例类的实现
function #modulenameModel:getInstance()
	if not instance then
		instance = #modulenameModel.new()
	end
	return instance
end
