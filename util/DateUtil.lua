------------------------------------------------------
--作者:   yzj
--日期:   2016年2月19日
--描述:   日期常用
------------------------------------------------------
module("DateUtil", package.seeall)

local days_leap = {
	31, 29,31,30,31,30,31,31,30,31,30,31	
}

local days = {
	31, 28,31,30,31,30,31,31,30,31,30,31	
}

--是否闰年
function isLeapYear(year)
	return ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0)
end


----------------------------------------------------------------
--获取服务器当天是星期几
----------------------------------------------------------------
-- temp = os.date("*t", 906000490)
-- {year = 1998, month = 9, day = 16, yday = 259, wday = 4, 
-- 	hour = 23, min = 48, sec = 10, isdst = false}
-- 说明：wday，星期天为1
function getDate(tTime)
	tTime = tTime or GameGlobal.serverTime
	return os.date("*t", tTime)
end

---根据年、月、日、时、分、秒获得描述
---如2012/5/12 20:00
function getSecondsByDate(param)
	local stime = 0
	stime = os.time({year = param.year or 1970, month = param.month or 1,day = param.day or 1,
                        hour = param.hour or 0, min = param.min or 0, sec = param.sec or 0})
	return stime
end

-- 获取月份多少天
function getDays(year, month)
	local isLeap = isLeapYear(year)
	if month then
		return isLeap and days_leap[month] or days[month]
	else
		return isLeap and 366 or 365
	end
end

-- 返回上一个月，month， year（可选）
function getPreMonth(month, year)
	month = month - 1

	if month < 1  then
		month = 12
	end

	if year then
		if month == 12 then
			year = year - 1
		end
		return month, year
	end

	return month
end


-- 返回下一个月，month， year（可选）
function getNextMonth(month)
	month = month + 1

	if month > 12  then
		month = 1
	end

	if year then
		if month == 1 then
			year = year + 1
		end
		return month, year
	end

	return month
end