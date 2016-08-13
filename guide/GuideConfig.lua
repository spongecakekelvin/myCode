--[[
maxLv 引导的等级上限 （默认无)
times 引导次数(默认1次、-1无次数限制) 

noFightLimit = true  战斗场景不限制（默认限制）  -- 第一引导用
noViewLimit = true  界面不限制（默认限制） -- 第一引导用

引导类型格式
1 手指指向按钮 
{1, 界面名字, 
对象索引 (“close”关闭“ok”确认；主界面按钮为controller；选项卡+100; 其他按钮序号 上->下、左->右分别是 12345..), 
{0没有光效 手指(1上2下3左4右)， "描述"[可选],} [可选],
}
2  打开界面{2, ctl =xx, func=xx, param=xx}


-- checkEquip 确保身上装备穿戴状态，{"checkEquip", exist/notExist/change(更换装备) ,位置, 包含的三步引导的额外参数，跳过步数（默认后面全部）}
-- checkEmbed 宝石镶嵌专用      {"checkEmbed", 位置, 跳过步数（默认后面全部）}
-- sceneState 场景状态检查 fight（战斗中） notFight（非战斗中）, {"sceneState", fight/ notFight, 手指引导(可选)}
-- checkPet 跳过步数（默认后面全部） {"checkPet"}
-- checkMsgBox 有提示窗处理   {checkMsgBox, 1左按钮/2右按钮}
-- checkChangeBtn 主界面切换按钮   {"checkChangeBtn"， true展开/false收起 , 手指引导(可选),} 
-- viewLimit 界面限制 {"viewLimit"}
-- checkEquipSystem 检查某部位装备是否开启了某系统，否跳过{"checkFoster", 部位, 系统标记，跳过步数} 
ps：标记有 foster洗炼, fosterInherit洗炼传承,inherit神器传承, embed镶嵌,devour神器升级, reinforce神炼
-- checkEquipsN {"checkEquipsN", 跳过步数}
-- checkPush 检测推送图标 {"checkPush", id, 跳过步数}
-- checkFamily 家族引导{"checkFamily", {有家族的引导}, {没家族的引导}}
-- checkSkill 是否有技能手指出现 {"checkSkill", skillType(1boss2小怪3竞技)}

-- requestFinish 请求完成任务
]]--

-- 等级引导
local level = {
    --1234.战斗
   --  [0] = {maxLv=2, noFightLimit=true, times=1,
   --       {2, ctl = "GuideController", func="openIntroView", param = {1}},
   -- },

    --宝石镶嵌: 1"detail"详情,2"reinforce"神炼,3 "foster"洗炼,4"fosterInherit"洗炼传承5"embed"宝石镶嵌6"devour"神器升级,7"inherit""神器传承"
    --[12] = {maxLv=30,times=1,
    --    {"checkEmbed", 1,{3,"有可镶嵌的宝石了"}},{1, "EquipView", "embed",{2,"点击宝石镶嵌"}},{1, "EquipView", 501,{1,"打开镶嵌列表"}}, {1, "StoneSelectView", 1,{1,"确定镶嵌"}},{1,"EquipView", "close"},
    --},

--    --双修
--    [13] = {maxLv=30,times=1,
--        {1, "MainUIView", "PetController",{3,"好友双修已开启"}},{1, "PetView", 300,{2,"点这里进入双修"}}, {1, "EquipShareView", 1,{1,"进入选择双修的好友"}},{"viewLimit"},
--    },
--    --检察与引导神将
--    [15] = {maxLv=30,times=1,noFightLimit=true,
--        {"checkPet"},{1, "MainUIView", "PetController",{3,"神将已召唤，这里进入查看"}},{1, "PetShenJiangView", 100,{2,"这里查看已出战的神将信息"}},{"viewLimit"},
--    },  
--    --装备神炼
--    [17] = {maxLv=30,times=1,noFightLimit=true,
--        {1, "MainUIView", "PetController",{3,"神炼功能开启，点击进入"}}, {1, "PetView", "reinforce", {2,"选择神炼"}},{"viewLimit"},
--    },
--
--
--    --装备洗炼
--    [21] = {maxLv=40,times=1,
--        {"checkEquipSystem", 1, "foster"},{1, "MainUIView", "PetController",{3,"洗炼功能开启，点击进入"}}, {1, "RoleView", 1, {2,"选择洗炼的装备"}},{1,"EquipView","foster",{1,"进入洗炼界面"}},{1,"EquipView",301,{1,"点击洗炼"}},
--    },


}


-- 功能开启引导
local funcOpen = {

    --10.战神殿
    --["RnkmController"] = {maxLv=25,
    --  {"sceneState", "notFight"},{1, "MainUIView", "RnkmController",{2,"战神殿可获得威望奖励"}},{1, "RnkmView", 1,{2,"点击挑战"}},
    }

-- 打开界面 
local view = {
    }

-- 其他特殊的引导条件（需要程序处理）
local other = {
    --battleType 参考FightConfig.lua中battleType
    -- id 关卡id
    -- 战斗结束 (endFight_battleType_id)

    ["endFight1_1"] = {maxLv = 10,times=1, noFightLimit = true,
        --穿戴装备 (主武器-白)
        {"sceneState", "fight"}, {"checkEquip", "exist", 1,{{3,"当有更好装备时，会出现N标识"}, {1,"点击选择装备"}, {1,"点击装备"}}, 1},{1,"PetView", "close"},
        -- 挑战BOSS（第二关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",1,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    --{"sceneState", "fight"},{1, "MainUIView", "FbController",{3,"实力提升了，快来虐待BOSS"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },


    ["endFight1_2"] = {maxLv = 20,times=1, noFightLimit = true,
        -- {"checkPush",1,4},{"sceneState", "fight"},{1,"PushView",1,{1,"这里快速进入领奖"}},{1,"AchievementView",200,{4,"选择成就奖励进行领取"}},{"viewLimit"},
        -- {"checkPush",6,3},{"sceneState", "fight"},{1,"PushView",6,{3,"点击使用扫荡小怪符"}},{"viewLimit"},
        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},
        -- 更换装备（主武器-紫） 身上如果没有装备或更好装备就跳过后5步
        -- {"sceneState", "fight"},{"checkEquip", "change", 6, nil, 5}, 
        --{1, "NewFightView", "PetController",{3,"有新装备可更换"}}, {1, "RoleView", 1, {2,"点这里更换"}},{1,"EquipView",103,{1,"点击选择"}},{1,"EquipSelectView",1,{3,"点击装备进行替换"}},{"viewLimit"},

        -- 挑战BOSS（第三关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",1,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },

    ["endFight1_3"] = {maxLv = 20,times=1, noFightLimit = true,
        {"checkPush",1,4},{"sceneState", "fight"},{1,"PushView",1,{1,"这里快速进入领奖"}},{1,"AchievementView",200,{4,"选择成就奖励进行领取"}},{"viewLimit"},
        {"checkPush",6,3},{"sceneState", "fight"},{1,"PushView",6,{3,"点击使用扫荡小怪符"}},{"viewLimit"},
        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},
        -- 挑战BOSS（第四关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",2,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },

    ["endFight1_4"] = {maxLv = 20,times=1, noFightLimit = true,
        --扫荡两小时
        {"sceneState", "fight"},{1, "NewFightView", "saodang",{4,"可瞬间获得大量装备与经验"}},{1, "MsgBox", 2},{1,"FightHangOffView", "ok"},{"viewLimit"},
        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},
        -- 挑战BOSS（第五关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",2,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },


    ["endFight1_5"] = {maxLv = 30,times=1, noFightLimit = true,
        --8.装备熔炼
        {"sceneState", "fight"},{1, "MainUIView", "EquipBuildController",{3, "在这里可以进入装备熔炼与打造"}},{1, "EquipBuildView", 2,{1,"确定熔炼"}}, {"checkMsgBox", 2},{"viewLimit"},
        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},

        --引导技能      
        {"sceneState", "fight"},{"checkChangeBtn", true,{3,"点这里展开隐藏面板"}}, {1,"MainUIView", "SkillController",{1,"点这里查看与更换技能"}},{1, "SkillView", 1,{1,"恭喜你获得新技能，请点击更换"}},
        {1, "SkillSelectView", 1,{2,"选择技能"}},{1, "SkillSelectView", "ok",{1,"确定保存技能"}},{"viewLimit"},
        -- 挑战BOSS（第六关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",2,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },
   


    ["endFight1_6"] = {maxLv = 20,times=1, noFightLimit = true,
        --引导装备打造
        {"sceneState", "fight"},{1, "MainUIView", "EquipBuildController",{3, "尝试用威望值打造高级装备吧"}},{1, "EquipBuildView",200,{2,"进入装备打造"}},{1, "EquipBuildView",4,{3,"确定打造"}}, {"viewLimit"},
        --{"checkEquip", "change", 9, nil, 2}, 
        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},

        -- 挑战BOSS（第七关）
        {"sceneState", "fight"},{1, "NewFightView", "return",{3,"这里可到回主城"}},{1,"MainFbView",3,{4,"选择关卡"}},{1, "MirrorView", 1, {1,"挑战BOSS，开启高级挂机地图"}},
    },
   




    ["endFight1_7"] = {maxLv = 30,times=1, noFightLimit = true,
        --小师妹共享
        {"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"小师妹共享装备咯，点击进入"}},{1, "PetView", 300,{2,"点这里进入双修"}}, {1, "EquipShareView", 3,{1,"同步后，就可以共享她的装备哦"}},{1, "PetView", "close"},

        {"checkEquipsN", 3},{"sceneState", "fight"},{1, "MainUIView", "PetController",{3,"有新装备可更换"}},{"viewLimit"},
        --打开副本界面
        {"sceneState", "fight"},{1, "MainUIView", "FbController",{3,"这里也可打开关卡界面"}},
    },


    ["endFight1_8"] = {maxLv = 30,times=1, noFightLimit = true, 
        --更换竞技技能
        {"sceneState", "notFight"},{"checkChangeBtn", true,{3,"点这里展开隐藏面板"}}, {1,"MainUIView", "SkillController",{1,"设置竞技技能，准备战神殿"}},{1, "SkillView", 102,{1,"点这里设置竞技技能"}},
        {1, "SkillView", 1,{1,"点击进入更换"}},{1, "SkillSelectView", 1,{2,"选择技能"}},{1, "SkillSelectView", "ok",{1,"确定保存技能"}},{1, "SkillView", "close"},
        --打竞技场
        {"sceneState", "notFight"},{1, "MainUIView", "RnkmController",{2,"战神殿可获得威望奖励"}},{1, "RnkmView", 1,{2,"点击挑战"}},
    },


    ["endFight1_9"] = {maxLv = 30,times=1, noFightLimit = true, 
        --家族
        {"sceneState", "notFight"},{"checkChangeBtn", true,{3,"点这里展开隐藏面板"}},{1, "MainUIView", "FamilyController", {1,"来加入或创建自己的帮派吧"}},     
    },
    ["endFight1_10"] = {maxLv = 30,times=1, noFightLimit = true,    
        --猎宝
        {"sceneState", "notFight"},{1, "MainUIView", "HuntForTreasController",{2,"猎宝可获得珍贵道具"}}, {1, "HuntForTreasView", 1,{2,"点击可免费猎宝一次"}}, {1, "HuntForTreasView", "close",{2,"10连猎有额外奖励哦"}},  
    },

    --["endFight1_11"] = {maxLv = 30,times=1, noFightLimit = true,  
    --双修
    --   {1, "MainUIView", "PetController",{3,"好友双修已开启"}},{1, "PetView", 300,{2,"点这里进入双修"}}, {1, "EquipShareView", 1,{1,"进入选择双修的好友"}},{"viewLimit"},
    --},

    ["pet"] = {maxLv = 30,times=1, noFightLimit = true,    
        --检察与引导神将
        {"sceneState", "fight"},{"checkPet"},{1, "MainUIView", "PetController",{3,"神将已召唤，这里进入查看"}},{1, "PetShenJiangView", 100,{2,"可为神将穿戴装备"}},{"viewLimit"},
        {"checkEmbed", 1,{3,"有可镶嵌的宝石了"}},{1, "EquipView", "embed",{2,"点击宝石镶嵌"}},{1, "EquipView", 501,{1,"打开镶嵌列表"}}, {1, "StoneSelectView", 1,{1,"确定镶嵌"}},{1,"EquipView", "close"},
    },

    ["endFight1_13"] = {maxLv = 30,times=1, noFightLimit = true,    
        --神将熔炼+经脉
        {"sceneState", "notFight"}, {1, "MainUIView", "EquipBuildController",{3, "神将熔炼功能已开启"}},{1, "EquipBuildView", 6,{1,"一键放多余召唤符"}},{1, "EquipBuildView", 2,{1,"确定熔炼获得真气值"}}, {"checkMsgBox", 2}, {1, "EquipBuildView", "close",{2,"真气值可修练经脉"}},
        {1, "MainUIView", "RoleInfoController",{4,"经脉系统已开放"}},{1, "RoleInfoView", 200,{2,"这里进入"}},{1,"JingMaiView","ok",{1,"确定提升人物属性"}},{"viewLimit"},
    },
}



return {
    --
     level = level,
    --    funcOpen = funcOpen,
    --    view = view,
    --    other = other,

    -- 引导步骤 {引导表，表索引} --用于登录时检索 （ps: 不能填other中的引导）
    steps = {
        {"level", 0},
    },


    -- 配置或测试用
 -- guideMode = true ,
 guideMode = false ,

    -- 当前任务index少于该值，闲置时任务图标出现光效
    indexForMissionBtnLight = 31,

    -- 任务引导不自动触发
    missionGuideLimit = {
        -- [listenerType] = {关卡达到限制(barrierId), 与level等级达到限制(level)}
		 
["main_fb_boss3"] = {barrierId = 1, level = 0},
["family_share"] = {barrierId = 1, level = 0},
["embed_stone"] = {barrierId = 1, level = 0},
["pet_jinghua"] = {barrierId = 1, level = 0},
["role_level"] = {barrierId = 1, level = 0},
--["grab"] = {barrierId = 1, level = 0},


--        ["equip_rebuild"] = {barrierId = 7, level = 9},
    },
    
    -- 不用前端请求完成的任务
    noRequestFinish= {
    ["main_fb_little"] = true,
        ["pet_jinghua"] = true, --神将进化
	["role_level"] = true, --人物升级

    },

}