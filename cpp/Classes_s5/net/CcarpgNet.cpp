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
#include "CcarpgNet.h"
#include "MessageDispatcher.h"
#include "ReceiveThread.h"
#include "TerminalReceiveThread.h"


//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
//#include <iostream>
//#include <windows.h>
//#include <psapi.h>
//#pragma comment(lib,"psapi.lib")
//
//int countCalMemo = 0;
//void showMemoryInfo(void)
//{
//	HANDLE handle=GetCurrentProcess();
//	PROCESS_MEMORY_COUNTERS pmc;
//	GetProcessMemoryInfo(handle,&pmc,sizeof(pmc));
//	CCLOG("memory:%dK/%dK , %dK/%dK",pmc.WorkingSetSize/1000 ,pmc.PeakWorkingSetSize/1000,pmc.PagefileUsage/1000 ,pmc.PeakPagefileUsage/1000);
//	//cout<<"内存使用:"<<pmc.WorkingSetSize/1000 <<"K/"<<pmc.PeakWorkingSetSize/1000<<"K + "<<pmc.PagefileUsage/1000 <<"K/"<<pmc.PeakPagefileUsage/1000 <<"K"<<endl;
//}
//#endif

CcarpgNet::CcarpgNet()
{
	/*
	pthread_mutex_init(&this->proto_lock_s,NULL);
	this->InitQueueProtocols(&protos_s); 
	pthread_mutex_init(&this->proto_lock_c,NULL);
	this->InitQueueProtocols(&protos_c);

	//pthread_mutex_init(&this->netStateLock,NULL);
	*/
	scheduler = Director::getInstance()->getScheduler();
}

CcarpgNet::~CcarpgNet()
{
	clearQueue();

}

CcarpgNet* CcarpgNet::getInstance()
{
	static CcarpgNet* instance = NULL;
	if(instance == NULL) instance = new CcarpgNet();
	return instance;
}

void CcarpgNet::clearQueue() 
{
	return;
	ServerDataFormat* baseResponseMsg_s;
	ServerDataFormat* baseResponseMsg_c;
	bool result;
	do 
	{
		pthread_mutex_lock(&this->proto_lock_s);
		result = this->DeleteProtocols(&this->protos_s,(ServerDataFormat** )&baseResponseMsg_s);
		pthread_mutex_unlock(&this->proto_lock_s);
		if(result)
		{
			delete[] baseResponseMsg_s->content;
			delete baseResponseMsg_s;
			baseResponseMsg_s = NULL;
		}
	} while (result);

	do 
	{
		pthread_mutex_lock(&this->proto_lock_c);
		result = this->DeleteProtocols(&this->protos_c,(ServerDataFormat** )&baseResponseMsg_c);
		pthread_mutex_unlock(&this->proto_lock_c);
		if(result)
		{
			delete[] baseResponseMsg_c->content;
			delete baseResponseMsg_c;
			baseResponseMsg_c = NULL;
		}
	} while (result);
}

void CcarpgNet::start() 
{
	//Director::getInstance()->getScheduler()->schedule(schedule_selector(CcarpgNet::globalUpdate),this,0.001,false);

	ReceiveThread::GetInstance()->addmsgListenerEvent(callFunc_selectormsg(CcarpgNet::msgCallBack),this);

	ReceiveThread::GetInstance()->addnotconListenerEvent(callFunc_selectormsg(CcarpgNet::notContCallBack),this);



	TerminalReceiveThread::GetInstance()->addmsgListenerEvent(callFunc_selectormsg_terminal(CcarpgNet::terminalmsgCallBack),this);

	//TerminalReceiveThread::GetInstance()->addnotconListenerEvent(callFunc_selectormsg_terminal(CcarpgNet::terminalnotContCallBack),this);


}


void CcarpgNet::globalUpdate(float dt) 
{
	//MessageDispatcher::sharedDispather()->sentProtoToLua(55,55,"chenglinlinchang");
	MessageDispatcher * msg = MessageDispatcher::getInstance();
	ServerDataFormat* baseResponseMsg_s;
	bool result;
	int count = 0;
	while(count<6)
	{
		pthread_mutex_lock(&this->proto_lock_s);
		result = this->DeleteProtocols(&this->protos_s,(ServerDataFormat** )&baseResponseMsg_s);
		pthread_mutex_unlock(&this->proto_lock_s);
		if(result)
		{
			msg->sentProtoToLua(baseResponseMsg_s->len, baseResponseMsg_s->moduleid,baseResponseMsg_s->methodid,baseResponseMsg_s->content);
			delete[] baseResponseMsg_s->content;
			delete baseResponseMsg_s;
			baseResponseMsg_s = NULL;
			count++;
		}
		else
		{
			break;
		}
	}

	//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	//countCalMemo++;
	//if(countCalMemo>60)
	//{
	//	showMemoryInfo();
	//	countCalMemo=0;
	//}
	//   #endif

	//ServerDataFormat* baseResponseMsg_c;
	//pthread_mutex_lock(&this->proto_lock_c);
	//result = this->DeleteProtocols(&this->protos_c,(ServerDataFormat** )&baseResponseMsg_c);
	//pthread_mutex_unlock(&this->proto_lock_c);
	//if(result)
	//{
	//	BSDSocket cSocket=SocketThread::GetInstance()->getSocket();
	//	int cout=cSocket.Send(baseResponseMsg_c->content,baseResponseMsg_c->len,0);
	//	//delete baseResponseMsg_c->content;
	//	delete baseResponseMsg_c;
	//}

	//static float passDt = 0;
	//passDt+=dt;
	//if(passDt>0.5)
	//{
      //msg->checkNetState();
	  //passDt = 0;
	//}
	

}

void CcarpgNet::msgCallBack(ServerDataFormat* baseResponseMsg){			

	
	scheduler->performFunctionInCocosThread([baseResponseMsg]{
		MessageDispatcher * msg = MessageDispatcher::getInstance();
		msg->sentProtoToLua(baseResponseMsg->len, baseResponseMsg->moduleid,baseResponseMsg->methodid,baseResponseMsg->content);
		delete[] baseResponseMsg->content;
		delete baseResponseMsg;
	});




	//this->baseResponseMsg=baseResponseMsg;	
	//this->scheduleOnce(schedule_selector(HelloWorld::createConte),0);

	//MessageDispatcher::sharedDispather()->sentProtoToLua(baseResponseMsg->len, baseResponseMsg->moduleid,baseResponseMsg->methodid,baseResponseMsg->content);
	//MessageDispatcher::sharedDispather()->sentProtoToLua(baseResponseMsg);

	//bool result;
	//pthread_mutex_lock(&this->proto_lock_s);
	//result = this->InsertProtocols(&this->protos_s,baseResponseMsg);
	//pthread_mutex_unlock(&this->proto_lock_s);
	//if(!result)
	//{
	//	if(baseResponseMsg->content)
	//	{
	//	 delete[] baseResponseMsg->content;
	//    }
	//	delete baseResponseMsg;
	//	baseResponseMsg = NULL;
	//}

}

void CcarpgNet::notContCallBack(ServerDataFormat* baseResponseMsg){
	//CCLOG("noconnetction");
}



void CcarpgNet::terminalmsgCallBack(ServerDataFormat_terminal* baseResponseMsg){			


	scheduler->performFunctionInCocosThread([baseResponseMsg]{
		MessageDispatcher * msg = MessageDispatcher::getInstance();
		msg->sentTerminalProtoToLua(baseResponseMsg->len, baseResponseMsg->moduleid,baseResponseMsg->methodid,baseResponseMsg->content);
		delete[] baseResponseMsg->content;
		delete baseResponseMsg;
	});

}

void CcarpgNet::terminalnotContCallBack(ServerDataFormat_terminal* baseResponseMsg){
	//CCLOG("noconnetction");
}

void  CcarpgNet::InitQueueProtocols(QueueProtocols *Q)
{

	Q->front = 0;
	Q->rear = 0;
}



int  CcarpgNet::QueueProtocolsLength(QueueProtocols *Q)
{
	//pthread_mutex_lock(&this->proto_lock_s);
	int result = (Q->rear - Q->front + MAX_PROTO_NUM)%MAX_PROTO_NUM;
	//pthread_mutex_unlock(&this->proto_lock_s);
	return  result;
}



bool   CcarpgNet::InsertProtocols(QueueProtocols *Q,ServerDataFormat *NewComand)
{
	//pthread_mutex_lock(&this->proto_lock_s);


	if((Q->rear+1)%MAX_PROTO_NUM == Q->front )
	{
		//pthread_mutex_unlock(&this->proto_lock_s);
		return false;
	}
	Q->Command[Q->rear] =  NewComand;
	Q->rear = (Q->rear+1)%MAX_PROTO_NUM;
	//pthread_mutex_unlock(&this->proto_lock_s);
	return true;
}


bool  CcarpgNet::DeleteProtocols(QueueProtocols *Q,ServerDataFormat **ReceiveComand)
{
	//pthread_mutex_lock(&this->proto_lock_s);
	if(Q->rear == Q->front )
	{
		//pthread_mutex_unlock(&this->proto_lock_s);
		return false;
	}

	*ReceiveComand = (Q->Command[Q->front]);
	Q->front = (Q->front+1)%MAX_PROTO_NUM;
	//pthread_mutex_unlock(&this->proto_lock_s);
	return true;
}



