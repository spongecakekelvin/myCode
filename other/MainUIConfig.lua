
--  开启条件：（任一条件满足）
-- openType = 0手动开启
-- barrierId = xx  通关了xx副本才出现（注意打过了算通关）
-- level = xx 开启等级
-- rect = {w, h} 点击区域
--isShowEff = true--显示N下面的特效
-- clickNoRemoveN, 点击后不删除引导的N, 自己控制
-- 排序是按配置顺序
return {
	-- 下面
	{
        -- 任务（原每日必做）
		-- {icon="activity.png", ctl="ActiveController",level =13},
		{icon="activity.png", ctl="TaskController",level =10, clickNoRemoveN = true},
	    -- 背包
        {icon="beibao.png", ctl="BagController", isShowEff = true},
	    -- 神将
        {tag="fengShen", icon="fengshen.png", ctl="PetController", view="openFengShenView",barrierId =9},
        -- 坐骑
        {icon="zuoqi.png", ctl="MountController",barrierId =15},
        -- 技能
        {icon="jineng.png", ctl="SkillController",barrierId =6},
        -- 捉妖录
        {icon="zhuoyaolu.png", ctl="YaoshouController",barrierId =2,clickNoRemoveN = true},


	-- 帮派
        -- {icon="gonghui.png", ctl="FamilyController",barrierId =9, isShowEff = true},
	-- 开服活动
        -- {icon="activity.png", ctl="AchievementController",barrierId =6, isOpenShowN = true},
	},



	-- 左边
	{  
	
	},

	-- 上面
	{
	    --争霸,内部图标配置文件： ActiveEnterConfig
	    {icon="activityEnter.png", ctl="ActiveEnterController", barrierId =14, clickNoRemoveN = true},
		-- 猎宝
		{icon="liebao.png", ctl="HuntForTreasController",barrierId =27},

        -- 领奖（每日必做，成就，登录奖励，成长基金）
        {icon="mubiao.png", ctl="SetupController",barrierId =15, isOpenShowN = true},
        --七日活动
        {icon="sevenDay.png", ctl="SevenDayActivityController", openType=1},
		-- 充值
		{icon="libao.png",tag="shop", ctl="VipController",barrierId =1},

		--夺宝
                --{icon="duobao.png", ctl="GrabController",barrierId =7},
		-- 战神殿（原竞技场）
                -- {icon="jingji.png", ctl="RnkmController",barrierId =19},
		-- 排行
                --{icon="paihang.png", ctl="RankController",level=20},
        -- 对比销售
        {icon="xianshishoumai.png", ctl="CompareSellController",openType = 1},
        -- 内嵌活动
        {icon="sche_weizhenshifang.png", ctl="ActivityScheduleController", openType = 1},
        -- 大圣归来
        {icon="dashengguilai.png", ctl="RegisterRewardController", openType = 1},
		-- 错误
		{icon="help.png", ctl="ErrorController", openType=1},
		{icon="extrayaoshoubtn.png",ctl="ExtractyaoshouController",tag="extrayaoshoubtn",openType=1},
	},


	-- 右面
	{
	    -- 熔炼
        {icon="yonglian.png", ctl="EquipBuildController",barrierId =4},
	    -- 装备
        {icon="zhuangbei.png", ctl="PetController", isShowEff = true},
	    -- 副本
        {icon="guanka.png", ctl="FbController", barrierId = 1, clickNoRemoveN = true},


	},

	-- 其它
	{
		-- 战斗中
		{icon="zhandou.png", ctl="FightController", posTab={x="x1", y="y1", ajx=-70, ajy=-90}},
		-- 地图
        {icon="moneyBlackBg.png", tag="map", text="主城村", posTab={x="x1", y="y1", ajx=-80, ajy=-14}},

		-- 头像
        -- {icon="touxiang.png", posTab={x="x0", y="y1", ajx=0, ajy=-125}},
		-- 邮件
		--{icon="youjian.png", ctl="EmailController", barrierId = 5,posTab={x="x0", y="y1", ajx=218, ajy=-136}, rect={w=100, h=76}},
		-- vip
        --{icon="vipBtn.png", ctl="VipController", barrierId = 4,posTab={x="x0", y="y1", ajx=132, ajy=-152}, rect={w=100, h=86}},
        {icon="vipBtn.png", ctl="VipPriController", barrierId = 4,posTab={x="x0", y="y1", ajx=117, ajy=-152}, rect={w=100, h=86}},
		-- 境界
        {icon="jingjie.png", ctl="JingjieController", barrierId = 4,posTab={x="x0", y="y1", ajx=207, ajy=-152}, rect={w=100, h=86}},
		-- 聊天
        {icon="liaotian2.png", ctl="ChatController", view="openViewCheck", posTab={x="x0", y="y0", ajx=350, ajy=51}},
        --{icon="liaotian.png", ctl="PayController", posTab={x="x0", y="y0", ajx=35, ajy=45}},
        --首充有礼
        {icon="shouchondali.png", ctl="FirstRewardController", barrierId = 1, posTab={x="x0", y="y0", ajx=300, ajy=498}, openType=0},
        --超神之路
    --{icon="chaoshenzhilu.png", ctl="RoleGoalController", barrierId = 1,posTab={x="x0", y="y0", ajx=337, ajy=530}, openType=0},
        --领奖中心
        {rect={w=100, h=110}, ctl="FetchRewardController", barrierId = 1, posTab={x="x0", y="y0", ajx=700, ajy=210}, openType=0, animName="boxDrop"},
        --合服活动
       {icon="comServiceAct.png", ctl="ComActController", openType=1,posTab={x="x1", y="y1", ajx=-189, ajy=-160}, rect={w=100, h=86}},
	},
}
