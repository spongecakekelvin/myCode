------------------------------------------------------
--作者:	lqk
--日期:	2015年1月28日
--描述:	腾讯QQ控制器
------------------------------------------------------
MsdkModel   = class("MsdkModel", BaseClass)

------------------------------------------------------
--		该model的提供的接口
------------------------------------------------------

------------------------------------------------------
--		定义model的数据
------------------------------------------------------
function MsdkModel:initModel()
	self.m_tData = {}
end



---单例类的实现
local instance
function MsdkModel:getInstance()
	if not instance then
		instance = MsdkModel.new()
	end
	return instance
end

return MsdkModel