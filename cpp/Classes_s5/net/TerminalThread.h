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
#ifndef __CC_NET_TERMINAL_THREAD_H__
#define __CC_NET_TERMINAL_THREAD_H__
#include <string> 
#include "pthread.h"
#include "MessageDispatcher.h"
#include "net/BSDSocket.h"

class TerminalThread
{
public:	
	~TerminalThread(void);
	static TerminalThread*   GetInstance();
	static bool isRunning;

	//#ifdef USE_LOCAL_TERMINAL
	//	BSDSocket *csocket;	
	//#endif

#ifdef USE_LOCAL_TERMINAL
	BSDSocket tercsocket;	
	int start();  
	void stop();
	void cleanSocket();
	void closeSocket();
	void setAddr(const char *addr,int pt);
	BSDSocket* getSocket();
	std::string ip;
	int port;
#endif
private:
	#ifdef USE_LOCAL_TERMINAL
	pthread_t pid;	
	
	static void* start_thread(void *);	
#endif
	bool started;
	TerminalThread(void);
private:
	static TerminalThread* m_pInstance;	
};

#endif

