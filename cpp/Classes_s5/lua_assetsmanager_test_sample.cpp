#include "lua_assetsmanager_test_sample.h"

#ifdef __cplusplus
extern "C" {
#endif
#include  "tolua_fix.h"
#ifdef __cplusplus
}
#endif

#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "tinyxml2.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#endif

USING_NS_CC;
USING_NS_CC_EXT;


static int lua_cocos2dx_createDownloadDir(lua_State* L)
{
    if (nullptr == L)
        return 0;
    
    int argc = lua_gettop(L);

    if (0 == argc)
    {
        std::string pathToSave = FileUtils::getInstance()->getWritablePath();
        pathToSave += "s3b6lhuxo";
        
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
        DIR *pDir = NULL;
        
        pDir = opendir (pathToSave.c_str());
        if (! pDir)
        {
            mkdir(pathToSave.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
        }
#else
        if ((GetFileAttributesA(pathToSave.c_str())) == INVALID_FILE_ATTRIBUTES)
        {
            CreateDirectoryA(pathToSave.c_str(), 0);
        }
#endif
        tolua_pushstring(L, pathToSave.c_str());
        return 1;
    }
    
    CCLOG("'createDownloadDir' function wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;
}

static int lua_cocos2dx_deleteDownloadDir(lua_State* L)
{
    if (nullptr == L)
        return 0;
    
    int argc = lua_gettop(L);
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 1, 0, &tolua_err)) goto tolua_lerror;
#endif
        std::string pathToSave = tolua_tostring(L, 1, "");
        
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
        std::string command = "rm -r ";
        // Path may include space.
        command += "\"" + pathToSave + "\"";
        system(command.c_str());
#else
        std::string command = "rd /s /q ";
        // Path may include space.
        command += "\"" + pathToSave + "\"";
        system(command.c_str());
#endif
        return 0;
    }
    
    CCLOG("'resetDownloadDir' function wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'resetDownloadDir'.",&tolua_err);
    return 0;
#endif
}

static std::string& replaceAll(std::string& str,const std::string& old_value,const std::string& new_value)
{
	while(true)
	{
		int pos=0;
		if((pos=str.find(old_value,0))!=std::string::npos)
			str.replace(pos,old_value.length(),new_value);
		else break;
	}
	return str;
}

static int lua_deleteUselessFiles(lua_State* L)
{

	if (nullptr == L)
		return 0;

	int argc = lua_gettop(L);

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	if (1 == argc)
	{
#if COCOS2D_DEBUG >= 1
		if (!tolua_isstring(L, 1, 0, &tolua_err)) goto tolua_lerror;
#endif
		std::string pathToSave = tolua_tostring(L, 1, "");

		tinyxml2::XMLElement* curNode = nullptr;
		tinyxml2::XMLDocument* xmlDoc;

		do 
		{
			 xmlDoc = new tinyxml2::XMLDocument();

			std::string xmlBuffer = FileUtils::getInstance()->getStringFromFile(pathToSave+"/del.xml");

			if (xmlBuffer.empty())
			{
				CCLOG("can not read xml file");
				break;
			}
			xmlDoc->Parse(xmlBuffer.c_str(), xmlBuffer.size());
			tinyxml2::XMLElement* rootNode;
			// get root node
			rootNode = xmlDoc->RootElement();
			if (nullptr ==rootNode)
			{
				CCLOG("read root node error");
				break;
			}
			char buffer[256];
			// find the node
			curNode = rootNode->FirstChildElement();
			while (nullptr != curNode)
			{
				//std::string afn =  curNode->Attribute("name");
				//std::string filename = pathToSave+"/"+afn;
				//CCLOG("%s",filename);
				//CCLOG("%s",afn);

				sprintf(buffer, "%s",  curNode->Attribute("name"));
				char *pt = buffer+strlen(buffer)-4;
				if (strcmp(pt,".lua")==0)
				{
					sprintf(buffer, "%s/%sc", pathToSave.c_str(), curNode->Attribute("name"));
				}
				else
				{
					sprintf(buffer, "%s/%s", pathToSave.c_str(), curNode->Attribute("name"));
				}

				std::string ftmep = buffer;

				ftmep=replaceAll(ftmep,"/","\\");

				if (remove(ftmep.c_str()) != 0)
				{
					CCLOG("can not remove del file %s", ftmep.c_str());
				}

				
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
//				sprintf(buffer, "%s",  curNode->Attribute("name"));
//				char *pt = buffer+strlen(buffer)-4;
//				if (strcmp(pt,".lua")==0)
//				{
//					sprintf(buffer, "rm  \"%s/%sc\"", pathToSave.c_str(), curNode->Attribute("name"));
//				}
//				else
//				{
//					sprintf(buffer, "rm  \"%s/%s\"", pathToSave.c_str(), curNode->Attribute("name"));
//				}
//				CCLOG("%s",buffer);
//				system(buffer);
//#else
//
//				
//				sprintf(buffer, "%s",  curNode->Attribute("name"));
//				char *pt = buffer+strlen(buffer)-4;
//				if (strcmp(pt,".lua")==0)
//				{
//                    sprintf(buffer, "%s/%sc", pathToSave.c_str(), curNode->Attribute("name"));
//				}
//				else
//				{
//					sprintf(buffer, "%s/%s", pathToSave.c_str(), curNode->Attribute("name"));
//				}
//				
//				std::string ftmep = buffer;
//				
//				ftmep=replaceAll(ftmep,"/","\\");
//				sprintf(buffer, "del /f/q \"%s\"", ftmep.c_str());
//				CCLOG("%s",buffer);
//				system(buffer);
//
//				if (remove(ftmep.c_str()) != 0)
//				{
//					CCLOG("can not remove del file %s", ftmep.c_str());
//				}
//#endif
				curNode = curNode->NextSiblingElement();

			}
		} while (0);

		delete xmlDoc;
		return 0;
	}

	CCLOG("'deleteUselessFiles' function wrong number of arguments: %d, was expecting %d\n", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(L,"#ferror in function 'deleteUselessFiles'.",&tolua_err);
	return 0;
#endif

	
}

static int lua_cocos2dx_addSearchPath(lua_State* L)
{
    if (nullptr == L)
        return 0;
    
    int argc = lua_gettop(L);
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
    
    if (2 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 1, 0, &tolua_err) ||
            !tolua_isboolean(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        std::string pathToSave = tolua_tostring(L, 1, "");
        bool before           = tolua_toboolean(L, 2, 0);
        std::vector<std::string> searchPaths = FileUtils::getInstance()->getSearchPaths();
        if (before)
        {
            searchPaths.insert(searchPaths.begin(), pathToSave);
        }
        else
        {
            searchPaths.push_back(pathToSave);
        }
        
        FileUtils::getInstance()->setSearchPaths(searchPaths);
        
        return 0;
    }
    CCLOG("'addSearchPath' function wrong number of arguments: %d, was expecting %d\n", argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'addSearchPath'.",&tolua_err);
    return 0;
#endif
}

int register_assetsmanager_test_sample(lua_State* L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
    tolua_function(L, "createDownloadDir", lua_cocos2dx_createDownloadDir);
    tolua_function(L, "deleteDownloadDir", lua_cocos2dx_deleteDownloadDir);
	tolua_function(L, "addSearchPath", lua_cocos2dx_addSearchPath);
	tolua_function(L, "deleteUselessFiles", lua_deleteUselessFiles);
    tolua_endmodule(L);
    return 0;
}
