#ifndef		__CCGAMEMAP_H__
#define		__CCGAMEMAP_H__
extern "C"{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
};

#include "cocos2d.h"
USING_NS_CC;

class GameMap : public Ref {
public:
	static int initWithFile(lua_State* ls, const char* filename, bool isSetPath = false);
};
#endif