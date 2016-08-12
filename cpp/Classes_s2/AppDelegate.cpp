#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "luabind/lua_cocos2dx_custom_manual.h"

extern "C"{
	#include "luazlib/lua_zlib.h"
};

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
	std::string writePath = FileUtils::getInstance()->getWritablePath();
	std::string updatePath = writePath + "tjwwUpdate";
	FileUtils::getInstance()->addSearchPath(updatePath, true);

    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);

	///register custom function
	auto state = engine->getLuaStack()->getLuaState();
	///lua zlib
	luaopen_zlib(state);
	lua_pop(state, 1);

	CustomLuaCocos2d(state);
	
    if (engine->executeScriptFile("src/main.lua")) {
        return false;
    }

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
	auto engine = LuaEngine::getInstance();
	auto stack = engine->getLuaStack();
	stack->executeGlobalFunction("applicationDidEnterBackground");
	
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
	auto engine = LuaEngine::getInstance();
	auto stack = engine->getLuaStack();
	stack->executeGlobalFunction("applicationWillEnterForeground");

    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
