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
#ifndef __CC_NET_SOCKET_THREAD_H__
#define __CC_NET_SOCKET_THREAD_H__
#include <string> 
#include "BSDSocket.h"
#include "pthread.h"


class SocketThread
{
public:	
	~SocketThread(void);
	static SocketThread*   GetInstance();
	static bool isRunning;
	int start();  
	BSDSocket* getSocket();
	//int state;
	BSDSocket csocket;	
	void stop();
	void cleanSocket();
	void closeSocket();
	void setAddr(const char *addr,int pt);
	
	std::string ip;
	int port;
	
private:
	pthread_t pid;	
	bool started;
	static void* start_thread(void *);	
	SocketThread(void);
private:
	static SocketThread* m_pInstance;	
};

#endif

