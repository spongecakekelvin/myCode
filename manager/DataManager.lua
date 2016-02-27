--------------------------
-- model数据管理器
-- DataManager 
--------------------------

-- 外部访问
-- e.g. DataManager.TestData.getName()
local modename = "DataManager"
local mt = {
    __index = function(tab, key) -- key是文件名
    	print("====== keyt = " .. key)
    	require("data/" .. key)
        return _G[key]
    end
}
_G[modename] = setmetatable(_G[modename] or {}, mt)
