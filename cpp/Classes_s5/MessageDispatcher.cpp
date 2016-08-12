/**
*开发者：成畅
* 修改时间:
*/
/*
_ooOoo_
o8888888o
88" . "88
(| -_- |)
O\  =  /O
____/`---'\____
.'  \\|     |//  `.
/  \\|||  :  |||//  \
/  _||||| -:- |||||-  \
|   | \\\  -  /// |   |
| \_|  ''\---/''  |   |
\  .-\__  `-`  ___/-. /
___`. .'  /--.--\  `. . __
."" '<  `.___\_<|>_/___.'  >'"".
| | :  `- \`.;`\ _ /`;.`/ - ` : | |
\  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
`=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
佛祖保佑       永无BUG
*/
/* ****************************************************************************/
//#include  <Windows.h> 
//#include  <TlHelp32.h> 
//#include  <stdio.h> 
//#include  <tchar.h> 
//#include  <locale.h> 
//#include  <stdlib.h> 
#include "cocos2d.h"
#include "base/CCScriptSupport.h"
#include "audio/include/SimpleAudioEngine.h"
#include "CCLuaEngine.h"
#include "MessageDispatcher.h"
#include "map/CcarpgMcm.h"
#include "net/ReceiveThread.h"
#include "net/SocketThread.h"
#include "net/TerminalThread.h"
#include "ConfigParser.h"
#include "UpgradeApk.h"
#include <curl/curl.h>
#include <curl/easy.h>


#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include "platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <windows.h>
#include <stdio.h>
#include "glfw3native.h"
#endif
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#endif

USING_NS_CC;
static LuaStack* _stack = NULL;
#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

#define LOW_SPEED_LIMIT 1L
#define LOW_SPEED_TIME 5L


void TestProcessGetThreadNumber() 
{

	//int i = 0;
	//char Buff[9];
	//PROCESSENTRY32 pe32;
	//pe32.dwSize = sizeof(pe32);

	//HANDLE hProcessSnap = ::CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
	//if (hProcessSnap == INVALID_HANDLE_VALUE)
	//{
	//	printf("CreateToolhelp32Snapshot 调用失败.\n");
	//	return ;
	//}
	//BOOL bMore = ::Process32First(hProcessSnap,&pe32);

	//HANDLE hProcess;

	//printf("%-30s %-20s %-20s %-15s\n","szExeFile","th32ProcessID","th32ParentProcessID","cntThreads");
	//while(bMore)
	//{
	//	printf("%-30s ",pe32.szExeFile);
	//	printf("%-20d ",pe32.th32ProcessID);
	//	printf("%-20d",pe32.th32ParentProcessID);


	//	//显示进程的线程数
	//	printf("%-15d\n",pe32.cntThreads);

	//	bMore = Process32Next(hProcessSnap,&pe32);
	//	i++;

	//	//pe32.th32ModuleID
	//}

	//printf("进程数：%d\n",i);
}

MessageDispatcher* MessageDispatcher::getInstance()
{
	static MessageDispatcher* instance = NULL;

	if(instance == NULL) 
	{

		instance = new MessageDispatcher();
		memset((int *)(instance->typeList),0,MAX_CALLBACK_NUM);
		instance->net = CcarpgNet::getInstance();
		_stack = LuaEngine::getInstance()->getLuaStack();
		instance->_netState = 1;
			instance->sdl = NULL;
		//instance->_oldnetState = 1;
			instance->isInSchedule = false;



	}
	return instance;
}
//void MessageDispatcher::checkNetState()
//{
//	////if(_oldnetState!=_netState)
//	//{
//	//	if(_netState==0)
//	//		{
//
//	//	}
//	//	else
//	//		{if(!SocketThread::isRunning)
//	//	{
//	//		notifyNetStateToLua();
//	//	}
//	//	}
//	//	//_oldnetState = _netState;
//	//}
//	//performFunctionInCocosThread
//	if(_oldnetState!=_netState)
//	{
//	notifyNetStateToLua();
//	_oldnetState = _netState;
//	if(_netState==1)
//	{
//	net->clearQueue();
//	}
//	}
//	
//
//}

int MessageDispatcher::getNetState()
{
	return _netState;
}


void MessageDispatcher::setNetState(int state)
{
	//if(state!=_netState)
	{
		//_oldnetState = _netState;
		_netState = state;
	}

	Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
		notifyNetStateToLua(state);
	});
	
	if(_netState==1)
	{
		net->clearQueue();
	}
}


std::string MessageDispatcher::keyOfSomeThing(std::string key,std::string url) 
{
	char buf[256];
	sprintf(buf,"%s%zd",key.c_str(),std::hash<std::string>()(url));
	return buf;
}

std::string MessageDispatcher::callBackForLua(int type,std::string param)
{
	std::string result = "";
	ssize_t size = 0;
	std::string pathToSave;
	std::vector<std::string> searchPaths;
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;
#endif
	switch (type)
	{
	case 1:
		result = ConfigParser::getInstance()->getUpdateURL();
		break;
	case 2:
		result = ConfigParser::getInstance()->getGameplatform();
		break;
	case 3:

		pathToSave = FileUtils::getInstance()->getWritablePath();
		pathToSave += "s3b6lhuxo";
		searchPaths = FileUtils::getInstance()->getSearchPaths();

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
		pDir = opendir (pathToSave.c_str());
		if (pDir)
		{
			searchPaths.insert(searchPaths.begin(), pathToSave);
		}
#else
		if ((GetFileAttributesA(pathToSave.c_str())) != INVALID_FILE_ATTRIBUTES)
		{
			searchPaths.insert(searchPaths.begin(), pathToSave);
		}
#endif

		
		
		FileUtils::getInstance()->setSearchPaths(searchPaths);

		break;
	case 4:

		pathToSave = FileUtils::getInstance()->getWritablePath();
		pathToSave += "s3b6lhuxo";
		result = "";
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)

		pDir = opendir (pathToSave.c_str());
		if (! pDir)
		{
			mkdir(pathToSave.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}
		result = pathToSave;
		/*pDir = opendir (pathToSave.c_str());
		if (pDir)
		{
		result = pathToSave;
		}*/
#else
		if ((GetFileAttributesA(pathToSave.c_str())) != INVALID_FILE_ATTRIBUTES)
		{
			result = pathToSave;
		}
#endif

		break;

case 5:
		result = ConfigParser::getInstance()->getTerminalIp();
		break;
case 6:
	
	result =  (char *)FileUtils::getInstance()->getFileData(param, "r+b", &size);
	break;
case 7:
	result = MessageDispatcher::getInstance()->nowhostip;
	break;
case 8:
	result = "0";
	break;

case 9:
	result  =   ConfigParser::getInstance()->getLibVersion();
	break;
default:
		break;

		
	}


	return result;


}


void MessageDispatcher::controlSomeThingJustForTest()
{
	//if(_netState==0)
	//{
	//	MessageDispatcher::getInstance()->setNetState(1);
	//}
	//else
	//{
	//	ReceiveThread::GetInstance()->stop();
	//	SocketThread::GetInstance()->closeSocket();
	//	SocketThread::GetInstance()->stop();
	//}

}


void MessageDispatcher::startNetWork(const char* ip,int port)
{
	SocketThread::GetInstance()->setAddr(ip,port);
	if(_netState==1 && !SocketThread::isRunning)
	{
		net->clearQueue();
		//printToTerminal("abc",3);
		SocketThread::GetInstance()->closeSocket();
		SocketThread::GetInstance()->stop();
		SocketThread::GetInstance()->setAddr(ip,port);
		SocketThread::GetInstance()->start();
	}
}



bool MessageDispatcher::closeNetWork()
{
	if(_netState==0 && !SocketThread::isRunning)
	{
		net->clearQueue();
		SocketThread::GetInstance()->closeSocket();
		SocketThread::GetInstance()->stop();
		return true;
	}
	return false;
}

static size_t getFileContentCode(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	string *content = (string*)userdata;
	content->append((char*)ptr, size * nmemb);

	return (size * nmemb);
}


inline unsigned char  toHex(const unsigned char  &x)
{
	return x > 9 ? x + 55: x + 48;
}

inline string URLEncode(const string &sIn)
{
	// cout << "size: " << sIn.size() << endl;
	string sOut;
	for( size_t ix = 0; ix < sIn.size(); ix++ )
	{      
		unsigned char  buf[4];
		memset( buf, 0, 4 );
		if( isalnum( (unsigned char )sIn[ix] ) )
		{      
			buf[0] = sIn[ix];
		}
		else if ( isspace( (unsigned char )sIn[ix] ) )
		{
			buf[0] = '+';
		}
		else
		{
			buf[0] = '%';
			buf[1] = toHex( (unsigned char )sIn[ix] >> 4 );
			buf[2] = toHex( (unsigned char )sIn[ix] % 16);
		}
		sOut += (char *)buf;
	}
	return sOut;
};



std::string MessageDispatcher::getFileContentByUrl(std::string url,int timeout)
{
	CURL *handle;
	handle = curl_easy_init();
	if (! handle)
	{
		//CCLOG("can not init curl");
		return "error:initcurl";
	}

	// Clear filecontent before assign new value.
	std::string filecontent = "";

	CURLcode res;
	curl_easy_setopt(handle, CURLOPT_URL, url.c_str());
	curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 0L);
	curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, getFileContentCode);
	curl_easy_setopt(handle, CURLOPT_WRITEDATA, &filecontent);
	if (timeout) curl_easy_setopt(handle, CURLOPT_CONNECTTIMEOUT, timeout);
	curl_easy_setopt(handle, CURLOPT_NOSIGNAL, 1L);
	curl_easy_setopt(handle, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
	curl_easy_setopt(handle, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);
	res = curl_easy_perform(handle);

	if (res != 0)
	{
		//CCLOG("get file content error,url is %s, error code is %d", url.c_str(),res);
		curl_easy_cleanup(handle);

		char result[32];
		sprintf(result,"error:curl code %d",res);
		return result;
	}

	curl_easy_cleanup(handle);

	return filecontent;
}


bool MessageDispatcher::cpplog()
{
	return ConfigParser::getInstance()->cpplog();
}

void MessageDispatcher::startLocalTerminal(float dt)
{
	//#if (COCOS2D_DEBUG>0)
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");

#if (COCOS2D_DEBUG<=0)

	if (tip=="127.0.0.1")
	{
		Director::getInstance()->getScheduler()->unschedule(schedule_selector(MessageDispatcher::startLocalTerminal),this);
		isInSchedule = false;
		return;
	}

#endif
#else
	//std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","172.22.10.23");
	#if (COCOS2D_DEBUG>0)
	std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp",ConfigParser::getInstance()->getTerminalIp().c_str());
#else
	std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");
	if (tip=="127.0.0.1")
	{
#ifdef USE_LOCAL_TERMINAL
		//	if(csocket==NULL)
		//	{
		//		csocket = new BSDSocket();
		//	}
		//csocket->Init();
		//csocket->Create(AF_INET,SOCK_STREAM,0);	
		//bool iscon=csocket->Connect("127.0.0.1",6789);
		//
		//if(!iscon){
		//	csocket->Close();
		//	delete csocket;
		//	csocket = NULL;
		//}
		Director::getInstance()->getScheduler()->unschedule(schedule_selector(MessageDispatcher::startLocalTerminal),this);
		isInSchedule = false;
#endif
		return;
	}
	//else
	//{

	//}
#endif
#endif
	//std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","172.22.10.23");
	//std::string tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");
	std::string tport = UserDefault::getInstance()->getStringForKey("ccterminalPort","6789");
	//if (tip!="" && tport!="" )
	//{
	//	TerminalThread::GetInstance()->setAddr(tip.c_str(),atoi(tport.c_str()));
	//}
	//else
	//{
	//	//return;
	//	TerminalThread::GetInstance()->setAddr("127.0.0.1",6789);
	//}

	//TerminalThread::GetInstance()->setAddr("172.22.10.23",6789);
	TerminalThread::GetInstance()->setAddr(tip.c_str(),atoi(tport.c_str()));
		

#ifdef USE_LOCAL_TERMINAL
	//	if(csocket==NULL)
	//	{
	//		csocket = new BSDSocket();
	//	}
	//csocket->Init();
	//csocket->Create(AF_INET,SOCK_STREAM,0);	
	//bool iscon=csocket->Connect("127.0.0.1",6789);
	//
	//if(!iscon){
	//	csocket->Close();
	//	delete csocket;
	//	csocket = NULL;
	//}
	Director::getInstance()->getScheduler()->unschedule(schedule_selector(MessageDispatcher::startLocalTerminal),this);
	isInSchedule = false;
	if ( !TerminalThread::isRunning)
	{
		TerminalThread::GetInstance()->start();
	}
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

		SYSTEMTIME sys; 
		GetLocalTime( &sys ); 
		char tmp[64]; 
		memset(tmp,0,64); 
		sprintf(tmp, "%4d-%02d-%02d %02d:%02d:%02d\n",sys.wYear,sys.wMonth,sys.wDay,sys.wHour,sys.wMinute, sys.wSecond); 
		WCHAR wszClassName[256];  
		memset(wszClassName,0,sizeof(wszClassName));  
		MultiByteToWideChar(CP_ACP,0,tmp,strlen(tmp)+1,wszClassName,  
			sizeof(wszClassName)/sizeof(wszClassName[0]));  
		SetWindowText(glfwGetWin32Window(Director::getInstance()->getOpenGLView()->getWindow()), wszClassName);
		// HDC hdc = GetWindowDC(glfwGetWin32Window(director->getOpenGLView()->getWindow()));
		//SetTextColor(hdc, 0xFFFF0000);
	
#endif
#endif
//#endif

}
bool MessageDispatcher::printToTerminal(const char* text,int len,bool autoConnect)
{
	//#if (COCOS2D_DEBUG>0)
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	std::string tip = "127.0.0.1";
#endif
#ifdef USE_LOCAL_TERMINAL
	if(isInSchedule)
	{
		return false;
	}
	BSDSocket * csocket = TerminalThread::GetInstance()->getSocket();
	if(csocket->isValid)
	{
		int count = csocket->Send(text,len,0);
		//CCLOG("%d",count);
		if(count==-1)
		{
			csocket->Close();
			csocket->isValid = false;
			if(autoConnect)
			{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
				

#if (COCOS2D_DEBUG<=0)
				 tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");
				if (tip=="127.0.0.1")
				{
					return false;
				}

#endif
#endif
			
			if(!isInSchedule)
			{
				Director::getInstance()->getScheduler()->schedule(schedule_selector(MessageDispatcher::startLocalTerminal),this,5.0,false);
				isInSchedule = true;
			}
			}
			return false;
		}
		count = csocket->Send("~&%*#@",6,0);
		if(count==-1)
		{
			csocket->Close();
			csocket->isValid = false;
			if(autoConnect)
			{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)


#if (COCOS2D_DEBUG<=0)
				tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");
				if (tip=="127.0.0.1")
				{
					return false;
				}

#endif
#endif
			
			if(!isInSchedule)
			{
				Director::getInstance()->getScheduler()->schedule(schedule_selector(MessageDispatcher::startLocalTerminal),this,5.0,false);
				isInSchedule = true;
			}
			}
			return false;
		}
	}
	else
	{
		if(autoConnect)
		{
			if ( TerminalThread::isRunning)
			{
				return false;
			}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)


#if (COCOS2D_DEBUG<=0)
			tip = UserDefault::getInstance()->getStringForKey("ccterminalIp","127.0.0.1");
			if (tip=="127.0.0.1")
			{
				return false;
			}

#endif
#endif
		if(!isInSchedule)
		{
			Director::getInstance()->getScheduler()->schedule(schedule_selector(MessageDispatcher::startLocalTerminal),this,5.0,false);
			isInSchedule = true;
		}
		return false;
		}
	}
#else
	CCLOG("%s",text);
#endif
//#endif
	return true;
}

long MessageDispatcher::getFileLenthByUrl(const char *url)
{
	double downloadFileLenth = 0;
	CURL *handle = curl_easy_init();
	curl_easy_setopt(handle, CURLOPT_URL, url);
	curl_easy_setopt(handle, CURLOPT_HEADER, 1);    //只需要header头
	curl_easy_setopt(handle, CURLOPT_NOBODY, 1);    //不需要body
	if (curl_easy_perform(handle) == CURLE_OK)
	{
		curl_easy_getinfo(handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &downloadFileLenth);
		downloadFileLenth /= 1024;
	}
	else
	{
		downloadFileLenth = -1;
	}
	curl_easy_cleanup(handle);
	return downloadFileLenth;
}

	bool MessageDispatcher::isDebug()
	{

#if (COCOS2D_DEBUG>0)
		return true;
#else
		return false;
#endif
	}

void MessageDispatcher::sendMessageToServer(int len,const char* text)
{
	//CcarpgMcm::getInstance()->setCurrentMapData(51001);
	//return;
	//CCLOG("send:send  = %d",len);
	//CCLOG("send:send  = %02X %02X %02X %02X %02X %02X ",text[0],text[1],text[2],text[3],text[4],text[5]);
	//CCLOG("send:chenglinlinchang");
	//BSDSocket cSocket=SocketThread::GetInstance()->getSocket();
	//int cout=cSocket.Send("chenglinlinchang",16,0);
	//int cout=cSocket.Send(text,len,0);
	//CCLOG("send:real = %d",cout);


	/*
	ServerDataFormat* baseResponseMsg = new ServerDataFormat();
	baseResponseMsg->len=len;
	//baseResponseMsg->content= (char *)text;

	//compress 
	//if((len-5)>2048)
	//{
	//	int compress (Bytef *dest,   uLongf *destLen, const Bytef *source, uLong sourceLen);
	//}

	baseResponseMsg->content= new char [len];
	memcpy(baseResponseMsg->content,text,len);
	bool result;
	pthread_mutex_lock(&net->proto_lock_c);
	result = net->InsertProtocols(&net->protos_c,baseResponseMsg);
	pthread_mutex_unlock(&net->proto_lock_c);
	if(!result)
	{
		delete[] baseResponseMsg->content;
		delete baseResponseMsg;
		baseResponseMsg = NULL;
	}
	*/



	if(_netState==0)
	{

	
	BSDSocket* csocket=SocketThread::GetInstance()->getSocket();
	if(csocket)
	{
		//CCLOG("%d,%d,%d,%d,%d,%d,%d,%d",baseResponseMsg_c->content[0],baseResponseMsg_c->content[1],baseResponseMsg_c->content[2],baseResponseMsg_c->content[3],baseResponseMsg_c->content[4],baseResponseMsg_c->content[5],baseResponseMsg_c->content[6],baseResponseMsg_c->content[7]);
		int cout=csocket->Send(text,len,0);
		//CCLOG("%d,%d",baseResponseMsg_c->len,cout);
		//CCLOG("%d,%d,%d,%d,%d,%d,%d,%d",baseResponseMsg_c->content[0],baseResponseMsg_c->content[1],baseResponseMsg_c->content[2],baseResponseMsg_c->content[3],baseResponseMsg_c->content[4],baseResponseMsg_c->content[5],baseResponseMsg_c->content[6],baseResponseMsg_c->content[7]);
		if(cout==-1)
		{
			CCLOG("disconnect6");
			setNetState(1);
		}
	}
	}

}

void MessageDispatcher::sentProtoToLua(int len,int module_id,int method_id, const char* text)
{
	if(this->typeList[PROTO_CALLBACK] > 0)
	{
		//LuaEngine* pEngine = LuaEngine::getInstance();
		//LuaStack* stack = pEngine->getLuaStack();
		//stack->pushInt(msgId);
		//stack->pushString(text);
		//stack->executeFunctionByHandler(mLuaHandlerId, 2);
		//stack->clean();

		//CCDefineScriptData data((void*)this,baseResponseMsg->len,baseResponseMsg->moduleid,baseResponseMsg->methodid,baseResponseMsg->content);


		//CCDefineScriptData data((void*)this,this->typeList[PROTO_CALLBACK],len, module_id, method_id,  text);
		//		ScriptEvent event(kCCdefineEvent,(void*)&data);
		//		ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);



		_stack->pushInt(module_id);
		_stack->pushInt(method_id);
		_stack->pushInt(len);
		if (text) 
		{
			_stack->pushString(text,len);
			int ret = _stack->executeFunctionByHandler(this->typeList[PROTO_CALLBACK], 4);
		}
		else
		{
			int ret = _stack->executeFunctionByHandler(this->typeList[PROTO_CALLBACK], 3);
		}
		
		_stack->clean();

	}
}

void MessageDispatcher::sentTerminalProtoToLua(int len,int module_id,int method_id, const char* text)
{
	if(this->typeList[LUA_TERMINAL_CALL_BACK] > 0)
	{

		_stack->pushInt(module_id);
		_stack->pushInt(method_id);
		_stack->pushInt(len);
		if (text) 
		{
			_stack->pushString(text,len);
			int ret = _stack->executeFunctionByHandler(this->typeList[LUA_TERMINAL_CALL_BACK], 4);
		}
		else
		{
			int ret = _stack->executeFunctionByHandler(this->typeList[LUA_TERMINAL_CALL_BACK], 3);
		}

		_stack->clean();

	}
}


void MessageDispatcher::openApkFile(std::string url)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	//CCLOG("openApkFile = %s",url.c_str());
	////JniMethodInfo minfo;
	//////bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","openApkFile", "(Ljava/lang/String;)V");
	////bool isHave = JniHelper::getMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","openApkFile", "(Ljava/lang/String;)V");
	////if (isHave)
	////{
	////	jstring jmsg = minfo.env->NewStringUTF(url.c_str());
	////	minfo.env->CallVoidMethod(minfo.classID, minfo.methodID,jmsg);
	////}





	//JniMethodInfo minfo;
	//bool isHave = JniHelper::getStaticMethodInfo(minfo,
	//	"org/cocos2dx/lib/Cocos2dxActivity",
	//	"getContext",
	//	"()Ljava/lang/Object;");

	//jobject activityObj;
	//if (isHave)
	//{
	//	//调用静态函数getJavaActivity，获取java类对象。
	//	activityObj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);

	//	//2. 查找displayWebView接口，获取其函数信息，并用jobj调用
	//	isHave = JniHelper::getMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","openApkFile", "(Ljava/lang/String;)V"); 

	//	if (isHave)
	//	{
	//		jstring jmsg = minfo.env->NewStringUTF(url.c_str());
	//		minfo.env->CallVoidMethod(activityObj, minfo.methodID,jmsg);
	//	}

	//}

	

	CCLOG("openApkFile = %s",url.c_str());
	JniMethodInfo minfo;
	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","openApkFile", "(Ljava/lang/String;)V");
	if (isHave)
	{
		jstring jmsg = minfo.env->NewStringUTF(url.c_str());
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID,jmsg);
		//minfo.env->DeleteLocalRef(jmsg);
	}



	
#endif
}

void MessageDispatcher::openUrl(std::string url)
{

	if (0 != strncmp(url.c_str(), "http", 4))
	{
      url = "http://"+url;
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("openUrl = %s",url.c_str());
JniMethodInfo minfo;
bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","openUrl", "(Ljava/lang/String;)V");
if (isHave)
{
	jstring jmsg = minfo.env->NewStringUTF(url.c_str());
	minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID,jmsg);
	//minfo.env->DeleteLocalRef(jmsg);
}
#endif
}

std::string MessageDispatcher::getDiskCacheDir()
{

	const char* ppath = NULL;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("getDiskCacheDir ");
	JniMethodInfo minfo;
	
	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","getDiskCacheDir", "()Ljava/lang/String;");
	if (isHave)
	{
		jstring path = (jstring) minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
		 const char* ppath = minfo.env->GetStringUTFChars(path, NULL);  
		 std::string cs(ppath);
		 minfo.env->ReleaseStringUTFChars(path, ppath);
		 return cs;
	}
	return NULL;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return callBackForLua(4,"");
#else
	//return FileUtils::getInstance()->getWritablePath();
	return callBackForLua(4,"");
#endif
}


bool MessageDispatcher::isNetConnected(std::string name)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("isNetConnected = %s ",name.c_str());
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity",name.c_str(), "()Z");
	if (isHave)
	{
		jboolean result  = (jboolean) minfo.env->CallStaticBooleanMethod(minfo.classID, minfo.methodID);
		
		return result;
	}
	return false;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return true;
#else
	return false;
#endif
}


int MessageDispatcher::getConnectedType()
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("getConnectedType");
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","getConnectedType", "()I");
	if (isHave)
	{
		jint result = (jint) minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);
		return result;
	}
	return -1;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return -1;
#else
	return -1;
#endif
}


long long MessageDispatcher::jniReturnLongNoParam(std::string name)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("jniReturnLongNoParam = %s",name.c_str());
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity",name.c_str(), "()J");
	if (isHave)
	{
		jlong result = (jlong) minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);
		return result;
	}
	return -1;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return -1;
#else
	return -1;
#endif
}



int MessageDispatcher::jniReturnIntNoParam(std::string name)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("jniReturnIntNoParam = %s",name.c_str());
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity",name.c_str(), "()I");
	if (isHave)
	{
		jint result = (jint) minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);
		return result;
	}
	return -1;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return -1;
#else
	return -1;
#endif
}

bool MessageDispatcher::jniReturnBooleanNoParam(std::string name)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("jniReturnBooleanNoParam = %s ",name.c_str());
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity",name.c_str(), "()Z");
	if (isHave)
	{
		jboolean result  = (jboolean) minfo.env->CallStaticBooleanMethod(minfo.classID, minfo.methodID);

		return result;
	}
	return false;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return true;
#else
	return false;
#endif
}


int MessageDispatcher::getMobileSubType()
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("getMobileSubType");
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","getMobileSubType", "()I");
	if (isHave)
	{
		jint result = (jint) minfo.env->CallStaticIntMethod(minfo.classID, minfo.methodID);
		return result;
	}
	return -1;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	return -1;
#else
	return -1;
#endif
}

void MessageDispatcher::changeFileMod(std::string url)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("changeFileMod = %s",url.c_str());
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","changeFileMod",  "(Ljava/lang/String;)V");
	if (isHave)
	{
		jstring jmsg = minfo.env->NewStringUTF(url.c_str());
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID,jmsg);
		//minfo.env->DeleteLocalRef(jmsg);
	}
#endif
}


void MessageDispatcher::deleteUpgradeFile()
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("clearApkFiles ");
	JniMethodInfo minfo;

	bool isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","clearApkFiles",  "()V");
	if (isHave)
	{
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID);
	}
#endif
}

void MessageDispatcher::arpgexit(std::string tip,std::string content,std::string leftstr,std::string rightstr)
{

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	CCLOG("arpgexit ");
	JniMethodInfo minfo;
	bool isHave = false;
	//string plat = ConfigParser::getInstance()->getGameplatform();
	//if (plat=="lewan" || plat=="360" || plat=="sina17g" || plat=="uc")
	{

		 isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lua/AppActivity","arpgexit",  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");

	}
	//else
	if (!isHave)
	{
		 isHave = JniHelper::getStaticMethodInfo(minfo,"org/cocos2dx/lib/Cocos2dxActivity","arpgexit",  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");

	}

	if (isHave)
	{
		jstring jmsg1 = minfo.env->NewStringUTF(tip.c_str());
		jstring jmsg2 = minfo.env->NewStringUTF(content.c_str());
		jstring jmsg3 = minfo.env->NewStringUTF(leftstr.c_str());
		jstring jmsg4 = minfo.env->NewStringUTF(rightstr.c_str());
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID,jmsg1,jmsg2,jmsg3,jmsg4);
		//minfo.env->DeleteLocalRef(jmsg1);
		//minfo.env->DeleteLocalRef(jmsg2);
		//minfo.env->DeleteLocalRef(jmsg3);
		//minfo.env->DeleteLocalRef(jmsg4);
	}
#endif
}


void MessageDispatcher::notifyNetStateToLua(int state)
{
	if(this->typeList[NET_STATE_CALLBACK] > 0)
	{
		_stack->pushInt(state);
		int ret = _stack->executeFunctionByHandler(this->typeList[NET_STATE_CALLBACK], 1);
		_stack->clean();

	}
}

int MessageDispatcher::getLuaMemory()
{
	if(this->typeList[LUA_MEMORY_CALLBACK] > 0)
	{
		int mem = _stack->executeFunctionByHandler(this->typeList[LUA_MEMORY_CALLBACK], 0);
		_stack->clean();
		return mem;
	}

	return 0;
}

int MessageDispatcher::getNetDelay()
{
	if(this->typeList[NET_DELAY_CALLBACK] > 0)
	{
		int mem = _stack->executeFunctionByHandler(this->typeList[NET_DELAY_CALLBACK], 0);
		_stack->clean();
		return mem;
	}

	return 0;
}

void MessageDispatcher::startDownloadApk(std::string url,std::string storagePath)
{
	UpgradeApk::getInstance()->startDownload( url, storagePath);

}

int MessageDispatcher::notifyApkLoadStatus(int status)

{
	if(this->typeList[APK_DOWNLOAD_STATUS] > 0)
	{
		_stack->pushInt(status);
		int mem = _stack->executeFunctionByHandler(this->typeList[APK_DOWNLOAD_STATUS], 1);
		_stack->clean();
		return mem;
	}

	return 0;
}


int MessageDispatcher::notifyApkLoading(long totalToDownload, long nowDownloaded,int pecent)
{
	if(this->typeList[APK_DOWNLOADIND] > 0)
	{
		_stack->pushInt(pecent);
		_stack->pushLong(nowDownloaded);
		_stack->pushLong(totalToDownload);
		int mem = _stack->executeFunctionByHandler(this->typeList[APK_DOWNLOADIND], 3);
		_stack->clean();
		return mem;
	}

	return 0;
}


//SegLoader* MessageDispatcher::getSegLoader()
//{
//	return sdl;
//}


void MessageDispatcher::setSegLoaderStatus(bool value)
{
	if (sdl!=NULL)
	{
		sdl->isStop = value;
	}
}


bool MessageDispatcher::setSegLoaderSpeed(int value)
{
	if (sdl!=NULL)
	{
		sdl->downloadingspeed = value;
		return true;
	}
	else
	{
		return false;
	}
}

void MessageDispatcher::startDownloadSegZip(std::string url,std::string storagePath,std::string uncompressPath)
{
	/*SegLoader::getInstance()->startDownload( url, storagePath,uncompressPath);*/
	if(sdl==NULL)
	{
      //sdl = new SegLoader();
	  sdl = SegLoader::getInstance();
	}

	sdl->startDownload( url, storagePath,uncompressPath);
	

}


int MessageDispatcher::notifySeverList(const char* text,int len)

{
	if(this->typeList[GET_SERVER_LISTS] > 0)
	{
		_stack->pushString(text,len);
		int mem = _stack->executeFunctionByHandler(this->typeList[GET_SERVER_LISTS], 1);
		_stack->clean();
		return mem;
	}

	return 0;
}


int MessageDispatcher::notifySegLoadStatus(int status)

{
	if(this->typeList[SEG_DOWNLOAD_STATUS] > 0)
	{
		_stack->pushInt(status);
		int mem = _stack->executeFunctionByHandler(this->typeList[SEG_DOWNLOAD_STATUS], 1);
		_stack->clean();
		return mem;
	}

	return 0;
}


int MessageDispatcher::notifySegLoading(long totalToDownload, long nowDownloaded,int pecent)
{
	if(this->typeList[SEG_DOWNLOADIND] > 0)
	{
		_stack->pushInt(pecent);
		_stack->pushLong(nowDownloaded);
		_stack->pushLong(totalToDownload);
		int mem = _stack->executeFunctionByHandler(this->typeList[SEG_DOWNLOADIND], 3);
		_stack->clean();
		return mem;
	}

	return 0;
}

void MessageDispatcher::registerScriptHandler(int type,int nHandler)
{
	if(type<0 || type>=MAX_CALLBACK_NUM)
	{
		CCLOG("registerScriptHandler error");
	}

	this->typeList[type] = nHandler;
}


void MessageDispatcher::unregisterScriptHandler(int type)
{
	if(type<0 || type>=MAX_CALLBACK_NUM)
	{
		CCLOG("runegisterScriptHandler error");
	}

	int nHandler = this->typeList[type];
	if(nHandler!=0)
	{
		LuaEngine::getInstance()->removeScriptHandler(nHandler);
		this->typeList[type] = 0;
	}
	
}

 
