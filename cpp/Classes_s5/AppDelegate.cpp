#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "Runtime.h"
#include "ConfigParser.h"
#include "lua_assetsmanager_test_sample.h"
#include "net/CcarpgNet.h"
//#include "auto/lua_ccarpg_auto.hpp"
#include "net/SocketThread.h"
#include "map/CcarpgMcm.h"
#include "lua_cocos2dx_custom_manual.h"
#include "MessageDispatcher.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#include "glfw3native.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <signal.h>
#include "platform/android/jni/JniHelper.h"
#include "platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <stdlib.h>
#endif

#ifdef USE_ANY_SDK_IN_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    #include "anysdkbindings.h"
    #include "anysdk_manual_bindings.h"
#endif
#endif
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
//#include <dirent.h>
//#include <sys/stat.h>
//#endif

//#include "luabinding/lua_ccarpg_auto.hpp"
//#include "luabinding/lua_ccarpg_manual.hpp"
using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

long getTimer()    
{     
	struct timeval tv;     
	gettimeofday(&tv,NULL);     
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;     
}  


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

static struct sigaction old_sa[NSIG];


void android_sigaction(int signal, siginfo_t *info, void *reserved)
{


	//if (!g_env)	{
	//	return;
	//}

	//jclass classID = g_env->FindClass(CLASS_NAME);
	//if (!classID) {
	//	return;
	//}

	//jmethodID methodID = g_env->GetStaticMethodID(classID, "onNativeCrashed", "()V");
	//if (!methodID) {
	//	return;
	//}

	//g_env->CallStaticVoidMethod(classID, methodID);

	//old_sa[signal].sa_handler(signal);


	CCLOG("android_sigaction");
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","onNativeCrashed", "()V");
	if (isHave)
	{
		minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);

	}


	old_sa[signal].sa_handler(signal);
}


void InitCrashReport()
{
	struct sigaction handler;
	memset(&handler, 0, sizeof(struct sigaction));

	handler.sa_sigaction = android_sigaction;
	handler.sa_flags = SA_RESETHAND;

#define CATCHSIG(X) sigaction(X, &handler, &old_sa[X])
	CATCHSIG(SIGILL);
	CATCHSIG(SIGABRT);
	CATCHSIG(SIGBUS);
	CATCHSIG(SIGFPE);
	CATCHSIG(SIGSEGV);
	CATCHSIG(SIGSTKFLT);
	CATCHSIG(SIGPIPE);

}




#endif

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
	ReceiveThread::GetInstance()->stop();
	SocketThread* th=  SocketThread::GetInstance();
	th->stop();
	th->cleanSocket();
    SimpleAudioEngine::end();
}
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
 void AppDelegate::keyEventCallback(cocos2d::EventKeyboard::KeyCode code, cocos2d::Event *event)  
{  
	typedef cocos2d::EventKeyboard::KeyCode KeyCode;  
	switch (code)  
	{  
	case KeyCode::KEY_BACKSPACE://ÏìÓ¦ÍË¸ñ¼ü  
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32          
		cocos2d::IMEDispatcher::sharedDispatcher()->dispatchDeleteBackward();  
#else        Director::getInstance()->end();   
#endif          
		break;  
	case KeyCode::KEY_DELETE:  
		cocos2d::IMEDispatcher::sharedDispatcher()->dispatchDeleteBackward();  
		break;  
	}  
}  
#endif
bool AppDelegate::applicationDidFinishLaunching()
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	InitCrashReport();
#endif

#if (COCOS2D_DEBUG>0)
    initRuntime();
#endif



    if (!ConfigParser::getInstance()->isInit()) {
            ConfigParser::getInstance()->readConfig();
        }
	
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();    
	
    if(!glview) {
        Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char* viewName, float width, float height,bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLanscape = ConfigParser::getInstance()->isLanscape();
        createSimulator(title.c_str(),viewSize.width,viewSize.height,isLanscape);
		//::SetWindowPos(glfwGetWin32Window(director->getOpenGLView()->getWindow()),HWND_TOPMOST,0,0,0,0,SWP_NOMOVE|SWP_NOSIZE);
#else
        glview = GLView::createWithRect(title.c_str(), Rect(0,0,viewSize.width,viewSize.height));
        director->setOpenGLView(glview);
		
#endif
    }

   
    // set FPS. the default value is 1.0/60 if you don't call this
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)


#if (COCOS2D_DEBUG<=0)
	director->setAnimationInterval(1.0 / 30);
   
#else
	director->setAnimationInterval(1.0 / 60);


#endif

#else
	director->setAnimationInterval(1.0 / 60);

#endif

    
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("s3ExtaS", strlen("s3ExtaS"), "IH8wdkD", strlen("IH8wdkD"));
	//cocos luacompile -s G:\\mobile_arpg\\arpg\\src  -d I:\\securecrt\\xxeat -e -k s3ExtaS -b IH8wdkD  
    
    //register custom function
	CustomLuaCocos2d(engine->getLuaStack()->getLuaState());

    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

	//register_all_ccarpg(stack->getLuaState());
	//register_all_ccarpg_manual(stack->getLuaState());

//    
	std::string resdirname = "res/";
	std::string configdirname = "config/";
	vector<string> searchPath;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	searchPath.push_back("../../src/");
	searchPath.push_back("../../"+configdirname);
	searchPath.push_back("../../"+resdirname);

	//extern std::string getCurAppPath();
	//string resourcePath = getCurAppPath();
	//searchPath.push_back(resourcePath+"/");
	//searchPath.push_back("src/");

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    searchPath.push_back("src/");
    searchPath.push_back(configdirname);
    searchPath.push_back(resdirname);

#else
	searchPath.push_back("src/");
	//searchPath.push_back("config/");
	searchPath.push_back(resdirname);
#endif

//	std::string pathToSave = FileUtils::getInstance()->getWritablePath();
//	pathToSave += "s3b6lhuxo";
//
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
//	DIR *pDir = NULL;
//
//	pDir = opendir (pathToSave.c_str());
//	if (pDir)
//	{
//		searchPath.insert(searchPath.begin(), pathToSave);
//	}
//#else
//	if ((GetFileAttributesA(pathToSave.c_str())) != INVALID_FILE_ATTRIBUTES)
//	{
//		searchPath.insert(searchPath.begin(), pathToSave);
//	}
//#endif
	 
	
	
	FileUtils::getInstance()->setSearchPaths(searchPath);
	CcarpgNet::getInstance()->start();

	#if (COCOS2D_DEBUG>0)
	MessageDispatcher::getInstance()->startLocalTerminal(0);
#endif

	//if(!ReceiveThread::GetInstance()->isRunning)
	//{
	//	ReceiveThread::GetInstance()->start();
	//}


	//FileUtils::getInstance()->printSearchPath();

#if (COCOS2D_DEBUG>0)
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID ||CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	register_assetsmanager_test_sample(stack->getLuaState());
#endif
	 if (ConfigParser::getInstance()->useCocosIde()){
    if (startRuntime())
	{
		#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
		EventListenerKeyboard *listener = EventListenerKeyboard::create();  
		listener->onKeyReleased = AppDelegate::keyEventCallback;  
		director->getEventDispatcher()->addEventListenerWithFixedPriority(listener, 1);  
#endif
        return true;
	}
	 }
	 else
	 {
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID ||CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
//		 register_assetsmanager_test_sample(stack->getLuaState());
//#endif
#ifdef USE_ANY_SDK_IN_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
         LuaStack* stackios = engine->getLuaStack();
         lua_getglobal(stackios->getLuaState(), "_G");
         tolua_anysdk_open(stackios->getLuaState());
         tolua_anysdk_manual_open(stackios->getLuaState());
         lua_pop(stackios->getLuaState(), 1);
#endif
#endif
		engine->executeScriptFile(ConfigParser::getInstance()->getEntryFile().c_str());
        //  engine->executeScriptFile("src/main.lua");
         
		
	 }
#else
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID ||CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	register_assetsmanager_test_sample(stack->getLuaState());
    #endif


	
	//vector<string> searchPath;
	//searchPath.push_back("../../src");
	//searchPath.push_back("../../res");
	//FileUtils::getInstance()->setSearchPaths(searchPath);
	//CcarpgNet::getInstance()->start();

	//long lasttt = getTimer();
	//CcarpgMcm::getInstance()->setCurrentMapData(51001);
	//CCLOG("mcm need time = %d",(getTimer()-lasttt));
	//SocketThread* th=  SocketThread::GetInstance();
	//th->start();
#ifdef USE_ANY_SDK_IN_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    LuaStack* stackios = engine->getLuaStack();
    lua_getglobal(stackios->getLuaState(), "_G");
    tolua_anysdk_open(stackios->getLuaState());
    tolua_anysdk_manual_open(stackios->getLuaState());
    lua_pop(stackios->getLuaState(), 1);
#endif
#endif
	engine->executeScriptFile(ConfigParser::getInstance()->getEntryFile().c_str());
	
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	//::SetWindowPos(glfwGetWin32Window(director->getOpenGLView()->getWindow()),HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE|SWP_NOSIZE);
	//BringWindowToTop(glfwGetWin32Window(director->getOpenGLView()->getWindow()));
	//SetConsoleTitle(L"your title");
	//SetWindowText(glfwGetWin32Window(director->getOpenGLView()->getWindow()), L"cllc");
	// HDC hdc = GetWindowDC(glfwGetWin32Window(director->getOpenGLView()->getWindow()));
	//SetTextColor(hdc, 0xFFFF0000);
#endif
	#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	EventListenerKeyboard *listener = EventListenerKeyboard::create();  
	listener->onKeyReleased = AppDelegate::keyEventCallback;  
	director->getEventDispatcher()->addEventListenerWithFixedPriority(listener, 1); 
#endif
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{

	CCLOG("applicationDidEnterBackground");
    Director::getInstance()->stopAnimation();

	SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	SimpleAudioEngine::getInstance()->pauseAllEffects();
		//SimpleAudioEngine::getInstance()->stopAllEffects();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
	CCLOG("applicationWillEnterForeground");
    Director::getInstance()->startAnimation();
	
	SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
	SimpleAudioEngine::getInstance()->resumeAllEffects();
}

