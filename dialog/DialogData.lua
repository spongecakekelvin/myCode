module("DialogData", package.seeall)

-- 字符分段
local function segment(dialogs, subStr)
    -- 分割字
    local function safeSub(w, posBeg, posEnd, isColor)
        if posBeg <= posEnd then
--            gprint("sub word = " .. w)
            local word = string.sub(w, posBeg, posEnd)
            if word and word ~= "" then 
--                gprint(posBeg .. "/" .. posEnd ..", " .. word)
                return {word,  isColor and ui.color.gold or ui.color.white} 
            end
        end
    end
    
    --分割一句
    local function splitWord(word)
        local wordTab = {}
        local len = string.len(word)
        while true do
            if not word then
                break
            else
                local posBeg, posEnd = string.find(word, subStr)
                if posBeg and posEnd then
                    wordTab[#wordTab + 1] = safeSub(word, 1, posBeg - 1)
                    wordTab[#wordTab + 1] = safeSub(word, posBeg, posEnd, true)
                    if posEnd >= len then
                        break
                    end
                    word = string.sub(word, posEnd + 1)
                else
                    break
                end
            end
        end
            wordTab[#wordTab + 1] = {word, ui.color.white}
        return wordTab
    end
    
	-- 将字符串转化成表{text}}
    for i, info in ipairs(dialogs) do
        if type(info[2]) == "string" then
            info[2] = splitWord(info[2])
        end
    end
    return dialogs
end

-- 检查标识 #username#
local function checkMarks(dialogs)
--    printTab(dialogs)

    dialogs = segment(dialogs, "%#username%#")
    local roleName = gData.RoleData.model.name
    
    for i, info in ipairs(dialogs) do
        if type(info[2]) == "table" then
            local needBlank = true --需要空格
            for j, w in ipairs(info[2]) do
                if type(w[1]) == "string" then
                    if needBlank then
                        w[1] = "    " .. string.gsub(w[1], "#username#", roleName)
                        needBlank = false
                    else
                        w[1] = string.gsub(w[1], "#username#", roleName)
                    end
                end
            end
        else
            info[2] = "    " .. string.gsub(info[2], "#username#", roleName)
        end
    end
--    printTab(dialogs)
    return dialogs
end

-- 对话的长度
local function checkLen(dialogs)
    for i, info in ipairs(dialogs) do
        if type(info[2]) == "string" then
            info.len = string.len(info[2])
        else
            info.len = 0
            for k, w in ipairs(info[2]) do
                info.len = info.len + string.len(w[1])
            end
        end
    end
end

local bossTab = {}

-- boss对话
function getConfig(barrierId)
    if bossTab[barrierId] then
        return bossTab[barrierId]
    end
    
    local dialogs = gfile.dialogConfig[barrierId]
    if dialogs then
        checkLen(dialogs)
        checkMarks(dialogs)
    end
    bossTab[barrierId] = dialogs
    return dialogs
end

local missionTab = {}

-- 任务对话
function getConfigByMissionId(missId)
    if missionTab[missId] then
        return missionTab[missId]
    end
    
    local dialogs = gfile.guideDialogConfig[missId]
    if dialogs then
        checkLen(dialogs)
        checkMarks(dialogs)
    end
    missionTab[missId] = dialogs
    return dialogs
end


-- 获取并检查任务对话是否存在 ,返回 boolean, dialogs
function checkGuideDialog(missId)
--    gprint(" ====  checkGuideDialog= === ")
    if not missId then
        return false
    end
    local dialogs = gData.DialogData.getConfigByMissionId(missId)
    if not dialogs or #dialogs == 0 then
        return false
    end
    return true, dialogs
end
