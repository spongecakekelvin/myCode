#include "gameUtil.h"
#include "cocos2d.h"
USING_NS_CC;

double getTimer()
{
	struct timeval tv;     
	gettimeofday(&tv,NULL);     
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

