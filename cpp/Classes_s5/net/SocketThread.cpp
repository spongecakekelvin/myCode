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
#include "SocketThread.h"
#include "cocos2d.h"
#include "ReceiveThread.h"
#include "MessageDispatcher.h"

static std::vector<std::string> strsplit(std::string str,std::string pattern)  
{  
	std::string::size_type pos;  
	std::vector<std::string> result;  
	str+=pattern;//扩展字符串以方便操作  
	int size=str.size();  

	for(int i=0; i<size; i++)  
	{  
		pos=str.find(pattern,i);  
		if(pos<size)  
		{  
			std::string s=str.substr(i,pos-i);  
			result.push_back(s);  
			i=pos+pattern.size()-1;  
		}  
	}  
	return result;  
}  

static     bool isIPAddress(const char *s)  
{  
	const char *pChar;  
	bool rv = true;  
	int tmp1, tmp2, tmp3, tmp4, i;  

	while( 1 )  
	{  
		i = sscanf(s, "%d.%d.%d.%d", &tmp1, &tmp2, &tmp3, &tmp4);  

		if( i != 4 )  
		{  
			rv = false;  
			break;  
		}  

		if( (tmp1 > 255) || (tmp2 > 255) || (tmp3 > 255) || (tmp4 > 255) )  
		{  
			rv = false;  
			break;  
		}  

		for( pChar = s; *pChar != 0; pChar++ )  
		{  
			if( (*pChar != '.')  
				&& ((*pChar < '0') || (*pChar > '9')) )  
			{  
				rv = false;  
				break;  
			}  
		}  
		break;  
	}  

	return rv;  
}  

USING_NS_CC;
int SocketThread::start(){    	
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
		isRunning = true;
		started = true;
	}while (0);
	return errCode;
} 


void* SocketThread::start_thread(void *arg)   {  
	isRunning = true;
	//pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);        
	//pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,   NULL); 
	//for(int i=0;i<999999999;i++);
	SocketThread* thred=(SocketThread*)arg;


	thred->csocket.Close();

	thred->csocket.Init();
	//CCLOG("WSAStartup = %d",thred->csocket.Init());
	/*cdSocket.Init();	*/
	//bool isok=thred->csocket.Create(AF_INET,SOCK_STREAM,0);	
	//bool iscon=thred->csocket.Connect("127.0.0.1",4433);
	//bool iscon=thred->csocket.Connect("172.22.10.23",443);










	// struct hostent *hptr;
	// char   *ptr, **pptr;
	//if((hptr = gethostbyname("api1.tlzs.jooyuu.com")) == NULL)

	//{

	//	CCLOG(" gethostbyname error for host:%s\n", ptr);

	//	return 0; 

	//}


	//CCLOG("official hostname:%s\n",hptr->h_name);

	//for(pptr = hptr->h_aliases; *pptr != NULL; pptr++)

	//	CCLOG(" alias:%s\n",*pptr);

	//switch(hptr->h_addrtype)

	//{

	//case AF_INET:

	//case AF_INET6:

	//	pptr=hptr->h_addr_list;

	//	for(; *pptr!=NULL; pptr++)

	//		printf(" address:%s\n", 
	//		LPCSTR ip = inet_ntoa(*(struct in_addr *)*hostinfo->h_addr_list);  
	//		inet_ntop(hptr->h_addrtype, *pptr, str, sizeof(str)));

	//	printf(" first address: %s\n", 

	//		inet_ntop(hptr->h_addrtype, hptr->h_addr, str, sizeof(str)));

	//	break;

	//default:

	//	printf("unknown address type\n");

	//	break;

	//}


	/*struct hostent *host = NULL;
	std::vector<std::string> iplist = strsplit(thred->ip,"%%");
	if (iplist.size()>1)
	{
		CCLOG(" split ip1 = %s\n",iplist[0].c_str());
		CCLOG(" split ip2 = %s\n",iplist[1].c_str());
		CCLOG(" isIPAddress(iplist[0].c_str()) = %d\n",isIPAddress(iplist[0].c_str()));
		CCLOG(" isIPAddress(iplist[1].c_str()) = %d\n",isIPAddress(iplist[1].c_str()));
		
      host = gethostbyname(iplist[1].c_str());
	

	}
	else
	{
		CCLOG(" split ip1 = %s\n",iplist[0].c_str());
	  host = gethostbyname(iplist[0].c_str());
	}*/


	//struct hostent *host = gethostbyname(thred->ip.c_str());
	bool iscon = false;
	/*
	if(!host)

	{

		if(isIPAddress(iplist[0].c_str()))
		{
			//CCLOG(" gethostbyname failed use ip: %s == %s\n",thred->ip.c_str(),realip);
			CCLOG(" gethostbyname error for host:%s\n",thred->ip.c_str());
			MessageDispatcher::getInstance()->nowhostip = thred->ip+" == failed";
			iscon=thred->csocket.Connect(iplist[0].c_str(),thred->port);
		}
		else
		{
			iscon = false;
			CCLOG(" gethostbyname error for host:%s\n",thred->ip.c_str());
			MessageDispatcher::getInstance()->nowhostip = "notconnected";
		}
		

		

	}
	else

	{

	

	struct in_addr **list = (struct in_addr **)host->h_addr_list;

	char *realip = inet_ntoa(*list[0]);
	CCLOG(" gethostbyname: %s == %s\n",thred->ip.c_str(),realip);
	MessageDispatcher::getInstance()->nowhostip = thred->ip+" == "+realip;
	//iscon=thred->csocket.Connect(thred->ip.c_str(),thred->port);
	iscon=thred->csocket.Connect(realip,thred->port);
	}
	*/
	MessageDispatcher::getInstance()->nowhostip = thred->ip;

	std::vector<std::string> iplist = strsplit(thred->ip,"%%");
	iscon=thred->csocket.ConnectIPV6_IPV4(iplist[0].c_str(),thred->port);













	//bool iscon=thred->csocket.Connect(thred->ip.c_str(),thred->port);
	//bool iscon=thred->csocket.Connect("127.0.0.1",20145);
	//bool iscon=thred->csocket.Connect("127.0.0.1",60000);
	if(!ReceiveThread::GetInstance()->isRunning)
	{
      ReceiveThread::GetInstance()->start();
	}
	
	if(iscon){
		MessageDispatcher::getInstance()->setNetState(0);
		CCLOG("conection");
	}else{
		CCLOG("disconnect5");
		MessageDispatcher::getInstance()->setNetState(1);
		CCLOG("not conection");
	}	
	isRunning = false;
	return NULL;                                                                                    
}
BSDSocket* SocketThread::getSocket(){
	return &this->csocket;
}

 bool SocketThread::isRunning = false;

SocketThread* SocketThread::m_pInstance=new SocketThread; 
SocketThread* SocketThread::GetInstance(){	
	return m_pInstance;
}


void SocketThread::setAddr(const char *addr,int pt)
{
	this->ip = std::string(addr);
	this->port = pt;

}
void SocketThread::cleanSocket()
{
	//this->csocket.Close();
	this->csocket.Clean();
}


void SocketThread::closeSocket()
{
	this->csocket.Close();
}

void SocketThread::stop(){
	if(started)
	{
		//pthread_cancel(pid);
		//pthread_detach(pid); 
		started = false;
	}
	
}

SocketThread::SocketThread(void):started(false)
{
}


SocketThread::~SocketThread(void)
{
	if(m_pInstance!=NULL){
		delete m_pInstance;
	}
}
