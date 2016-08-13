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
#include "TerminalThread.h"
#include "cocos2d.h"
#include "TerminalReceiveThread.h"
#include "ConfigParser.h"

USING_NS_CC;

TerminalThread* TerminalThread::m_pInstance=new TerminalThread; 
TerminalThread* TerminalThread::GetInstance(){	
	return m_pInstance;
}

TerminalThread::TerminalThread(void):started(false)
{
//#ifdef USE_LOCAL_TERMINAL
//	tercsocket = NULL;
//#endif
}


TerminalThread::~TerminalThread(void)
{
	if(m_pInstance!=NULL){
		delete m_pInstance;
	}
}


#ifdef USE_LOCAL_TERMINAL
int TerminalThread::start(){    	
	int errCode = 0;
	do{
		pthread_attr_t tAttr;
		errCode = pthread_attr_init(&tAttr);
		CC_BREAK_IF(errCode!=0);
		errCode = pthread_attr_setdetachstate(&tAttr, PTHREAD_CREATE_DETACHED);
		if (errCode!=0) {
			pthread_attr_destroy(&tAttr);
			break;
		}		
		errCode = pthread_create(&pid,&tAttr,start_thread,this);
		started = true;
		isRunning = true;
	}while (0);
	return errCode;
} 


void* TerminalThread::start_thread(void *arg)   {  
	//pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);        
	//pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,   NULL); 
	isRunning = true;
	TerminalThread* thred=(TerminalThread*)arg;
	BSDSocket* sock = thred->getSocket();
	

	sock->Close();
	
	sock->isValid = false;

	sock->Init();
	//sock->Create(AF_INET,SOCK_STREAM,0);	

	bool iscon=sock->ConnectIPV6_IPV4(thred->ip.c_str(),thred->port);
	//bool iscon=sock->Connect(thred->ip.c_str(),thred->port);
	
	//bool iscon=sock->Connect(ConfigParser::getInstance()->getTerminalIp().c_str(),6789);
	//bool iscon=sock->Connect("192.168.4.15",6789);
	//bool iscon=sock->Connect("172.22.10.23",6789);

	if(!iscon){
		sock->Close();
		CCLOG("terminal not connected");
	}
	else
	{
		CCLOG("terminal connected");
		sock->isValid = true;
	}
	isRunning = false;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

	if(!TerminalReceiveThread::GetInstance()->isRunning)
	{
		TerminalReceiveThread::GetInstance()->start();
	}
#endif
	return NULL;                                                                                    
}

 bool TerminalThread::isRunning = false;
BSDSocket* TerminalThread::getSocket(){
	return &this->tercsocket;
}


void TerminalThread::setAddr(const char *addr,int pt)
{
	this->ip = std::string(addr);
	this->port = pt;

}
void TerminalThread::cleanSocket()
{
	tercsocket.Clean();
}


void TerminalThread::closeSocket()
{
	tercsocket.Close();
}

void TerminalThread::stop(){
	if(started)
	{
		//pthread_cancel(pid);
		//pthread_detach(pid); 
		started = false;
	}
	
}

#endif