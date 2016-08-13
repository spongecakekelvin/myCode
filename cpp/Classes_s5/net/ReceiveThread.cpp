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
#include "ReceiveThread.h"
#include "MessageDispatcher.h"
#include "cocos2d.h"
#include "SocketThread.h"
#include "net/CcarpgNet.h"
#include "zlib.h"
ReceiveThread* ReceiveThread::m_pInstance=new ReceiveThread; 
ReceiveThread* ReceiveThread::GetInstance(){	
	return m_pInstance;
}
ReceiveThread::ReceiveThread(void)
{

	this->m_msglistener=NULL;

	started = detached = false;
	isRunning = false;
}


ReceiveThread::~ReceiveThread(void)
{
	stop();
}
int ReceiveThread::start(void * param){    	
	int errCode = 0;
	do{
		pthread_attr_t attributes;
		errCode = pthread_attr_init(&attributes);
		CC_BREAK_IF(errCode!=0);
		errCode = pthread_attr_setdetachstate(&attributes, PTHREAD_CREATE_DETACHED);
		if (errCode!=0) {
			pthread_attr_destroy(&attributes);
			break;
		}		
		errCode = pthread_create(&handle, &attributes,threadFunc,this);
		started = true; 
	}while (0);
	return errCode;
} 

void* ReceiveThread::threadFunc(void *arg){
	//pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);        
	//pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,   NULL);   
	ReceiveThread* thred=(ReceiveThread*)arg;	
	BSDSocket* csocket=SocketThread::GetInstance()->getSocket();
	CcarpgNet* net = CcarpgNet::getInstance();
	MessageDispatcher* msd = MessageDispatcher::getInstance();
	struct timeval timeout={18,0};
	struct timeval timeoutse={1,0};
	//for(int i=0;i<999999999;i++);
	bool result;
	int selectResult = 0;
	//int testcount = 0;
	//int testcountse = 0;
	thred->isRunning = true;
	//CCLOG("threadFunc");
	//if(msd->getNetState()==0)
	{
		while(true){
threadStartPos:
			//SuspendThread(thred->handle);
			if(msd->getNetState()==0)
			{

				//CCLOG("Select%d",testcount);
				//if(testcount%200 == 0)
				//{
				//	//CCLOG("Select%d",testcount);
				//	MessageDispatcher::getInstance()->printToTerminal("hijklmn",7);
				//}
				//testcount++;
				//CCLOG("%d",net->QueueProtocolsLength(&net->protos_c));
				
				/*
				ServerDataFormat* baseResponseMsg_c;
				pthread_mutex_lock(&net->proto_lock_c);
				result = net->DeleteProtocols(&net->protos_c,(ServerDataFormat** )&baseResponseMsg_c);
				pthread_mutex_unlock(&net->proto_lock_c);
				if(result)
				{
					//CCLOG("%d,%d,%d,%d,%d,%d,%d,%d",baseResponseMsg_c->content[0],baseResponseMsg_c->content[1],baseResponseMsg_c->content[2],baseResponseMsg_c->content[3],baseResponseMsg_c->content[4],baseResponseMsg_c->content[5],baseResponseMsg_c->content[6],baseResponseMsg_c->content[7]);
					int cout=csocket->Send(baseResponseMsg_c->content,baseResponseMsg_c->len,0);
					//CCLOG("%d,%d",baseResponseMsg_c->len,cout);
					delete[] baseResponseMsg_c->content;
					//CCLOG("%d,%d,%d,%d,%d,%d,%d,%d",baseResponseMsg_c->content[0],baseResponseMsg_c->content[1],baseResponseMsg_c->content[2],baseResponseMsg_c->content[3],baseResponseMsg_c->content[4],baseResponseMsg_c->content[5],baseResponseMsg_c->content[6],baseResponseMsg_c->content[7]);
					delete baseResponseMsg_c;
					baseResponseMsg_c = NULL;
					if(cout==-1)
					{
						msd->setNetState(1);
						goto threadStartPos;
					}
				}
				*/


				selectResult = csocket->Select(&timeout);
				//CCLOG("have data %d",selectResult);
				if(selectResult==-2){				
					//MessageDispatcher::getInstance()->printToTerminal("hijklmn",7);
					char recvBuf[9];
					//CCLOG("have data");
					int reallen = 0;
					int recvLen;
					while(reallen!=9)
					{
						recvLen= csocket->Recv(recvBuf+reallen,9-reallen,0);	
						if(recvLen<=0)
						{
							CCLOG("disconnect1");
							msd->setNetState(1);
							goto threadStartPos;
							//break;
							//(thred->m_notconlistener->*(thred->notconselector))(NULL);
						}
						reallen +=recvLen;
					}
					//int i=	csocket->Recv(recvBuf,9,0);				
					//if (i==9)
					{				

						char dc1[4]={recvBuf[3],recvBuf[2],recvBuf[1],recvBuf[0]};
						int len=*(int*)&dc1[0];

						char dc2[2]={recvBuf[5],recvBuf[4]};
						unsigned short unicode = *(unsigned short*)&dc2[0];

						unsigned char moduleid = *(unsigned char*)&recvBuf[6];

						char dc4[2]={recvBuf[8],recvBuf[7]};
						unsigned short methodid = *(unsigned short*)&dc4[0];

						//CCLOG("len = %d,unicode = %d,moduleid = %d,methodid = %d",len,unicode,moduleid,methodid);
						char* messbody=NULL;
						int myl=0;
						if(len>5 && len<40960)
							//if(len>5 && len<8192)
						{							
							myl=len-5;
							messbody=new char[myl];		
							if (messbody==NULL)
							{
								CCLOG("disconnect28");
								msd->setNetState(1);
								goto threadStartPos;
							}

							reallen = 0;
							while(reallen!=myl)
							{
								recvLen= csocket->Recv(messbody+reallen,myl-reallen,0);		
								if(recvLen<=0)
								{
									CCLOG("disconnect2");
									msd->setNetState(1);
									delete messbody;
									goto threadStartPos;
									//break;
									//(thred->m_notconlistener->*(thred->notconselector))(NULL);
								}
								reallen +=recvLen;
							}

							//int reallen = csocket->Recv(messbody,myl,0);		
							//CCLOG("%d = %d",myl,reallen);

							//	//1001 = com.lx.command.player.LoginCmd
							//1002 = com.lx.command.player.RegisterCmd
							//1003 = com.lx.command.player.HeartBeatCmd
							// 登陆

							ServerDataFormat* basmsg=new ServerDataFormat();
							basmsg->unicodeid=unicode;

							basmsg->methodid=methodid;
							basmsg->moduleid=moduleid;

							//CCLOG("myl = %d",myl);
							if((unicode&0x8000) == 0x8000)
							{
								//CCLOG("myl = %d",myl);
								uLongf uncomLen = 128 * 1024;
								unsigned char *uncomBuf = new unsigned char[uncomLen];
								if (uncomBuf==NULL)
								{
									delete messbody;
									delete basmsg;
									//continue;
									goto threadStartPos;
								}
								memset(uncomBuf, 0, uncomLen);
								uncompress(uncomBuf,&uncomLen,(unsigned char *)messbody,myl);
								delete messbody;
								basmsg->content= (char*)uncomBuf;
								basmsg->len=uncomLen;
								//CCLOG("%d = %d",myl,uncomLen);
							}
							else
							{
								//CCLOG("myl = %d",myl);
								basmsg->len=len;
								basmsg->content=messbody;
							}


							if(thred->m_msglistener){
								//basmsg->setStringToMsg(messbody,myl);
								(thred->m_msglistener->*(thred->msgselector))(basmsg);
							}
						}
						else if(len==5){							


							ServerDataFormat* basmsg=new ServerDataFormat();
							basmsg->unicodeid=unicode;

							basmsg->methodid=methodid;
							basmsg->moduleid=moduleid;

							//CCLOG("myl = %d",myl);
							basmsg->len=len;
							basmsg->content=NULL;
							delete messbody;


							if(thred->m_msglistener){
								//basmsg->setStringToMsg(messbody,myl);
								(thred->m_msglistener->*(thred->msgselector))(basmsg);
							}


						}
						else
						{
							//CCLOG("fuck");
							CCLOG("disconnect3");
							msd->setNetState(1);
							delete messbody;
							goto threadStartPos;
							//break;
						}

					}
					//  else 
					//
					//{
					//	CCLOG("i = %d",i);
					//	if(thred->m_notconlistener){
					//		ServerDataFormat* basmsg=new ServerDataFormat();
					//		SocketThread::GetInstance()->state = 1;
					//		(thred->m_notconlistener->*(thred->notconselector))(basmsg);
					//	}
					//	break;
					//}

				}
				//else if(selectResult==-1)
				else if(selectResult<=0)
				//else
				{	
					CCLOG("disconnect %d",selectResult);
					CCLOG("disconnect4");
					msd->setNetState(1);
					goto threadStartPos;
					//break;
				}
				//else
				//{
				//	CCLOG("disconnect %d",selectResult);
				//}
			}
			else
			{
				select(0, NULL, NULL, NULL, &timeoutse);
				//if(testcountse%200 == 0)
				//{
				//	//CCLOG("Select se%d",testcountse);
				//	MessageDispatcher::getInstance()->printToTerminal("abcdefg",7);
				//}
				//testcountse++;
				//break;
			}
		}
	}

	thred->isRunning = false;
	return NULL;
}


void ReceiveThread::stop(){
	if (started && !detached) { 
		CCLOG("stop");
		//pthread_cancel(handle);
		//pthread_detach(handle); 
		detached = true; 
		isRunning = false;
	}
}

/*
void * ReceiveThread::wait(){
void * status = NULL;
if (started && !detached) { 
pthread_join(handle, &status); 
}
return status;
}
void ReceiveThread::sleep(int secstr){
timeval timeout = { secstr/1000, secstr%1000}; 
select(0, NULL, NULL, NULL, &timeout);
}

void ReceiveThread::detach(){
if (started && !detached) {
pthread_detach(handle);
} 
detached = true;
}
*/