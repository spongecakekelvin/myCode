#include "CCGameMap.h"
#include "zlib.h"
#include "util/gameUtil.h"
#include "CCMapAstar.h"
#include <string>

static unsigned char data[100*1024] = {0};

static int readByte(unsigned char** pData)
{
	unsigned char*p = *pData;
	unsigned char v = 0;
	memcpy(&v, p, 1);
	*pData += 1;
	return (int)v;
}

static int readInt(unsigned char** pData)
{
	unsigned char* p = *pData;
	unsigned char tmp[4] = {0};
	memcpy(tmp, p+3, 1);
	memcpy(tmp+1, p+2,1);
	memcpy(tmp+2, p+1, 1);
	memcpy(tmp+3, p+0, 1);
	*pData += 4;
	return *(int*)tmp;
}

static std::string readString(unsigned char** pData, int size)
{
	unsigned char* p = *pData;
	unsigned char* tmp = (unsigned char*)new char[size+1];
	memcpy(tmp, p, size);
	tmp[size] = 0;
	std::string str((const char*)tmp);
	*pData += size;
	delete [] tmp;
	return str;
}

static int readBool(unsigned char** pData)
{
	unsigned char* p = *pData;
	unsigned char tmp[4] = {0};
	memcpy(tmp, p + 3, 1);
	memcpy(tmp + 1, p + 2, 1);
	memcpy(tmp + 2, p + 1, 1);
	memcpy(tmp + 3, p + 0, 1);
	*pData += 4;
	return *(bool*)tmp;
}

int GameMap::initWithFile(lua_State* ls, const char* filename, bool isSetPath)
{
	long time = getTimer();
	ssize_t size;
	unsigned char* buf = NULL;

	buf = FileUtils::getInstance()->getFileData(filename, "rb+", &size);
	if(!buf){
		CCLOG("read mcm file error:%s\n", filename);
		return 0;
	}

	//uncompress mcm
	unsigned long length = sizeof(data)/sizeof(char);
	memset(data, 0, length);	
	int err = uncompress(data, &length, buf, size);
	delete [] buf;
	if(err != Z_OK){
		CCLOG("uncompress the map data error:%s\n", filename);
		return 0;
	}
	CCLOG("#mcm length=%d\n", length);

	//parse mcm
	lua_newtable(ls);
	unsigned char* p = data;
	int mapId = readInt(&p);
	lua_pushstring(ls, "sceneId");
	lua_pushnumber(ls, mapId);
	lua_rawset(ls, -3);

	int mapType = readInt(&p);
	lua_pushstring(ls, "isCopy");
	lua_pushnumber(ls, mapType);
	lua_rawset(ls, -3);

	std::string mapName = readString(&p, 32);
	lua_pushstring(ls, "sceneName");
	lua_pushstring(ls, mapName.c_str());
	lua_rawset(ls, -3);

	std::string imgLink = readString(&p, 32);
	lua_pushstring(ls, "imageURL");
	lua_pushstring(ls, imgLink.c_str());
	lua_rawset(ls, -3);

	int mapRow = readInt(&p);
	lua_pushstring(ls, "tileRow");
	lua_pushnumber(ls, mapRow);
	lua_rawset(ls, -3);

	int mapCol = readInt(&p);
	lua_pushstring(ls, "tileColumn");
	lua_pushnumber(ls, mapCol);
	lua_rawset(ls, -3);

	int eleNum = readInt(&p);
	lua_pushstring(ls, "elementCount");
	lua_pushnumber(ls, eleNum);
	lua_rawset(ls, -3);

	int jmpNum = readInt(&p);
	lua_pushstring(ls, "jumpPointCount");
	lua_pushnumber(ls, jmpNum);
	lua_rawset(ls, -3);

	int offsetX = readInt(&p) - 10000000;
	lua_pushstring(ls, "offsetX");
	lua_pushnumber(ls, offsetX);
	lua_rawset(ls, -3);

	int offsetY = readInt(&p) - 10000000;
	lua_pushstring(ls, "offsetY");
	lua_pushnumber(ls, offsetY);
	lua_rawset(ls, -3);

	int width = readInt(&p);
	lua_pushstring(ls, "mapWidth");
	lua_pushnumber(ls, width);
	lua_rawset(ls, -3);

	int height = readInt(&p);
	lua_pushstring(ls, "mapHeight");
	lua_pushnumber(ls, height);
	lua_rawset(ls, -3);

	//读地图格子信息
	lua_pushstring(ls, "tileMatrix");
	lua_pushlstring(ls, (char*)p, mapRow*mapCol);
	lua_rawset(ls, -3);

	if(isSetPath){
		MapAstar::getInstance()->setMapdata((char*)p, mapRow, mapCol);
	}
	p += mapRow*mapCol;

	//读取地图元素信息
	lua_pushstring(ls, "mapElementArr");
	lua_newtable(ls);
	for(int k=0;k<eleNum;k++){
		lua_newtable(ls);
		lua_pushstring(ls, "id");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "tileX");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "tileY");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "type");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		int num = readInt(&p);
		lua_pushstring(ls, "idontKnow");
		lua_pushstring(ls, readString(&p, num).c_str());
		lua_rawset(ls, -3);

		lua_rawseti(ls, -2, k+1);
	}
	lua_rawset(ls, -3);

	//读取跳转点信息
	lua_pushstring(ls, "jumpPointArr");
	lua_newtable(ls);

	for(int j=0;j<jmpNum;j++){
		lua_newtable(ls);	
		lua_pushstring(ls, "id");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "tileX");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "tileY");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "toMapId");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "toMapTileX");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "toMapTileY");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "targetHW");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "targetYL");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "twl");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "minLevel");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		lua_pushstring(ls, "maxLevel");
		lua_pushnumber(ls, readInt(&p));
		lua_rawset(ls, -3);

		int link = readInt(&p);
		lua_pushstring(ls, "exId");
		lua_pushstring(ls, readString(&p, link).c_str());
		lua_rawset(ls, -3);

		lua_rawseti(ls, -2, j+1);
	}
	lua_rawset(ls, -3);
	CCLOG("parse mcm time:%d\n", getTimer()-time);
	return 1;
}