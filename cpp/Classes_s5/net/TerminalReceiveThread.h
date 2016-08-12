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
#ifndef __CC_NET_TERMINAL_RESPONSE_THREAD_H__
#define __CC_NET_TERMINAL_RESPONSE_THREAD_H__
// 此类主要 处理服务器推送过来的消息
#include "pthread.h"
#include "cocos2d.h"


typedef struct _ServerDataFormat_terminal
{
	int len;
	short moduleid;               
	short methodid;
	unsigned char unicodeid;
	char* content;
} ServerDataFormat_terminal;


typedef void (cocos2d::Ref::*TerminalReceiveThreadEvent)(ServerDataFormat_terminal*);
#define callFunc_selectormsg_terminal(_SELECTOR) (TerminalReceiveThreadEvent)(&_SELECTOR)

#define M_ADDCALLBACKEVENT_terminal(varName)\
protected: cocos2d::Ref* m_##varName##listener;TerminalReceiveThreadEvent varName##selector;\
public: void add##varName##ListenerEvent(TerminalReceiveThreadEvent m_event,cocos2d::Ref* listener)  { m_##varName##listener=listener;varName##selector=m_event; }

class TerminalReceiveThread
{
public:	
	~TerminalReceiveThread(void);
	static TerminalReceiveThread*   GetInstance(); // 获取该类的单利
	int start (void * =NULL); //函数是线程启动函数，其输入参数是无类型指针。
	void stop();     //函数中止当前线程。
	//void sleep (int tesec); //函数让当前线程休眠给定时间，单位为毫秒秒。
	//void detach();   //
	//void * wait();
    bool isRunning;	
private:
	TerminalReceiveThread(void);
	pthread_t handle; 
	bool started;
	bool detached;
	
	static void * threadFunc(void *);
	static TerminalReceiveThread* m_pInstance;	
	M_ADDCALLBACKEVENT_terminal(msg);// 聊天回调函数
	M_ADDCALLBACKEVENT_terminal(notcon);//断网回调函数
	
};

#endif
