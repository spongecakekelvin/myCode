/*
**
*/

//#ifndef __LUA_SQLITE3_H_
//#define __LUA_SQLITE3_H_
//
//int luaopen_lsqlite3(lua_State *L);
//
//#endif


#ifndef __LSQLITE3_H__
#define __LSQLITE3_H__
 
#ifdef __cplusplus
extern "C" {
#include "tolua++.h"
#ifdef __cplusplus
}
#endif
#endif
 
 
extern "C" int luaopen_lsqlite3(lua_State* L);
#endif