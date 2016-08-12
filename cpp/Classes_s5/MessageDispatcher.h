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
#ifndef __CC_MESSAGEDISPATHER_H__
#define __CC_MESSAGEDISPATHER_H__

#include "cocos2d.h"
#include "net/CcarpgNet.h"
#include "SegLoader.h"

#define MAX_CALLBACK_NUM  20
#define PROTO_CALLBACK  0
#define LUA_MEMORY_CALLBACK  1
#define NET_DELAY_CALLBACK  2
#define NET_STATE_CALLBACK  3

#define APK_DOWNLOAD_STATUS  4
#define APK_DOWNLOADIND  5
#define SEG_DOWNLOAD_STATUS  6
#define SEG_DOWNLOADIND  7

#define LUA_TERMINAL_CALL_BACK  8

#define GET_SERVER_LISTS  9


#define USE_LOCAL_TERMINAL
#define USE_ANY_SDK_IN_IOS

//class CC_DLL MessageDispatcher : public cocos2d::Ref
class  MessageDispatcher : public cocos2d::Ref
{
public:
	static MessageDispatcher* getInstance();
public:
	std::string nowhostip;
	void sentProtoToLua(int len,int module_id,int method_id, const char* text);
	void sentTerminalProtoToLua(int len,int module_id,int method_id, const char* text);
	
	void sendMessageToServer(int len,const char* text);
	bool printToTerminal(const char* text,int len,bool autoConnect = true);
	void registerScriptHandler(int type,int nHandler);
	void unregisterScriptHandler(int type);
	std::string getFileContentByUrl(std::string url,int timeout = 0);
	
	int getLuaMemory();
	int getNetDelay();
	void setNetState(int state);
	int notifyApkLoadStatus(int status);
	int notifyApkLoading(long totalToDownload, long nowDownloaded,int pecent);
	void startDownloadApk(std::string url,std::string storagePath);

	int notifySegLoadStatus(int status);
	int notifySegLoading(long totalToDownload, long nowDownloaded,int pecent);
	void startDownloadSegZip(std::string url,std::string storagePath,std::string uncompressPath);

	//SegLoader* getSegLoader();

	void setSegLoaderStatus(bool value);
	bool setSegLoaderSpeed(int value);
	int notifySeverList(const char* text,int len);
	
	int getNetState();
	void controlSomeThingJustForTest();
	void notifyNetStateToLua(int state);
	void openUrl(std::string url);
	std::string getDiskCacheDir();
	void changeFileMod(std::string url);
	void deleteUpgradeFile();
	long long jniReturnLongNoParam(std::string name);
	bool jniReturnBooleanNoParam(std::string name);
	int getConnectedType();
	int getMobileSubType();
	int jniReturnIntNoParam(std::string name);
	
	bool isNetConnected(std::string name);
	void arpgexit(std::string tip,std::string content,std::string leftstr,std::string rightstr);
	void openApkFile(std::string url);
	void startNetWork(const char* ip,int port);
	bool closeNetWork();
	long getFileLenthByUrl(const char *url);
	//void checkNetState();
	void startLocalTerminal(float dt);
	bool cpplog();

	std::string callBackForLua(int type,std::string param);
	std::string keyOfSomeThing(std::string key,std::string url);
		bool isDebug();
	

private:
	CcarpgNet *net;
	int _netState;
	//int _oldnetState;
	int typeList[MAX_CALLBACK_NUM];
	bool isInSchedule;

	SegLoader *sdl;

};

#endif 