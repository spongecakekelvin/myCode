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
#ifndef _C_CCARPG_NET_H_
#define _C_CCARPG_NET_H_

#include "cocos2d.h"
#include "pthread.h"
#include "ReceiveThread.h"
#include "TerminalReceiveThread.h"
USING_NS_CC;

#define  MAX_PROTO_NUM 1

typedef struct _QueueProtocols
{
	int front;
	int rear;               
	ServerDataFormat* Command[MAX_PROTO_NUM];
} QueueProtocols;


class CcarpgNet: public Ref {
public:
	static CcarpgNet* getInstance();
	CcarpgNet();
	~CcarpgNet();
    void globalUpdate(float dt);
	void start();
	void msgCallBack(ServerDataFormat* baseResponseMsg);
	void notContCallBack(ServerDataFormat* baseResponseMsg);
	void terminalmsgCallBack(ServerDataFormat_terminal* baseResponseMsg);
	void terminalnotContCallBack(ServerDataFormat_terminal* baseResponseMsg);

	
	int   QueueProtocolsLength(QueueProtocols *Q);
	bool   InsertProtocols(QueueProtocols *Q,ServerDataFormat *NewComand);
	bool  DeleteProtocols(QueueProtocols *Q,ServerDataFormat **ReceiveComand);
	void clearQueue();
	pthread_mutex_t proto_lock_s;
	pthread_mutex_t proto_lock_c;

	//pthread_mutex_t netStateLock;

	QueueProtocols protos_s;
	QueueProtocols protos_c;

private:
	void  InitQueueProtocols(QueueProtocols *Q);
	Scheduler* scheduler;


};

#endif /* GLOBALSCHEDULE_H_ */

