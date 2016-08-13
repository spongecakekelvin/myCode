-- GuideFistrEnterConfig.lua
--作者：余振健
--新手弹窗 前端配置
--后端：cfg_period_reward
return {

-- size是文字框的尺寸
-- x, y 是文字的位置，以文字框的左上角做原点
-- effectTag = 特效参数，"gold" ：金币掉落
-- text 是文字内容，可选填★
-- btnName = 按钮文字
-- sprInfo  = 要显示的图片参数(图片打包在GuideTip里面) 
--           "chest"：宝箱图片，铜币那里用到
--           "weapon"：武器，武器1-3代表3个职业
-- 			"huba"胡巴
--           {"pet", 神将id}：神将形象，如果改了形象，记得改神将名字美术字

-- [阶段id] = {步骤内容}
[1] = {

	-- [1] = {
	-- 	size = cc.size(630, 180),
	-- 	x = 50, y = -75,  
	-- 	text= {
	--         --{{" 留神啦！",ui.color.gold, 24},{" 战（gua）斗（ji）",ui.color.green, 24},{" 开始啦！",ui.color.gold, 24}},
	-- 		--{{" 即使退出游戏也根本",ui.color.gold, 24},{" 停！不！下！来！",ui.color.green, 24}},
	-- 		--{{" 只要您再次",ui.color.gold, 24},{"回到游戏",ui.color.green, 24}},
	-- 		--{{" 经验、铜钱和极品装备就会",ui.color.gold, 24},{"爆满全身！",ui.color.green, 24}},
	-- 		--{{" 您唯一要做的就是",ui.color.gold, 24}},
	-- 		--{{" 干干BOSS，收收小蜜，",ui.color.green, 24},{"快乐爽翻天！",ui.color.gold, 24}},
	--         {{" 万万没想到，俺老孙被这五行山一压就是五百年。",ui.color.gold, 24}},
	--     },
	--     btnName = {"大圣莫慌，我来救你", ui.color.white, 26},
	-- },
	[1] = {
		sprInfo = {"word", "万万没想到，\n俺老孙被这五行山一压就是五百年!"},
	},
	[2] = {
		sprInfo = {"image"},
	},
	[3] = {
		size = cc.size(395, 220),
		x = 60, y = -77,  
		text= {
			{{" 救我出来，送你三根毫毛",ui.color.gold, 24}},
			{{" 现在实现你",ui.color.gold, 24},{"第一个愿望",ui.color.green, 24}},
	    },
	    btnName = {"我要一只最厉害的妖兽", ui.color.white, 24},
	},
	[4] = {
		size = cc.size(450, 347),
		x = 45, y = -280, 
		sprInfo = {"huba"},
		text= {
			{{" 竟然召唤出了小妖王——胡小巴",ui.color.gold, 24}},
	    },
	    btnName = {"噗，这不就是一只小萝卜", ui.color.white, 26},
	},



},

--第二部分

[2] = {
	[1] = {
		size = cc.size(480, 165),
		x = 50, y = -65,  
		text= {
			{{" 本大圣没有看错，你果然可堪大任。",ui.color.gold, 24}},
	    },
	    btnName = {"突然冒出来，吓死宝宝了", ui.color.white, 26},
	},

	[2] = {
		size = cc.size(485, 165),
		x = 50, y = -65,  
		text= {
			{{" 第二根毫毛，满足你的",ui.color.gold, 24},{"第二个愿望。",ui.color.green, 24}},
	    },
	    btnName = {"我要极品装备！", ui.color.white, 26},
	},

	[3] = {
		size = cc.size(266, 204),
		--x = 34, y = -32,  
		sprInfo =  {"weapon"},
	    btnName = {"亮瞎~！那我就收下咯！", ui.color.white, 26},
	},

},


--第三部分

[3] = {
	[1] = {
		size = cc.size(440, 165),
		x = 50, y = -65,  
		text= {
			{{" 是时候实现你的",ui.color.gold, 24},{"第三个愿望",ui.color.green, 24},{"了！",ui.color.gold, 24}},
	    },
	    btnName = {"我要厉害的神将", ui.color.white, 26},
	},

	--[2] = {
	--	size = cc.size(300, 310),
	--	x = 45, y = -280, 
	--	sprInfo =  {"pet", 30000101},
	--	--text= {
	--	--	{{" Duang~送你一枚神将助你开天辟地！",ui.color.gold, 24}},
	--    --},
	--    btnName = {"天啦撸，真是任性", ui.color.white, 26},
	--},

	--[2] = {
	--	size = cc.size(550, 185),
	--	x = 255, y = -80, 
	--	effectTag = "gold",
	--	sprInfo   =  {"chest"},
	--	text= {
	--        {{" 恭喜获得",ui.color.gold, 24},{" ★70万铜币★",ui.color.green, 24}},
	--    },
	--    btnName = {"好多钱，可以给喵星人买apple watch了", ui.color.white, 26},
	--},
},

[4] = {
	[1] = {
		size = cc.size(454, 205),
		x = 64, y = -55,  
		text= {
			{{"三个愿望都已经实现了",ui.color.gold, 24}},
			{{"接下来轮到你表演真正的技术了",ui.color.gold, 24}},
			{{"俺老孙去也！",ui.color.gold, 24}},
	    },
	    btnName = {"踏上捉妖的旅程", ui.color.white, 26},
	},
}, 




}