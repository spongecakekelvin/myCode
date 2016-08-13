#ifndef __PLSOCKET_H__
#define __PLSOCKET_H__

#ifdef WIN32
#pragma comment(lib,"ws2_32.lib")
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>
#include "errno.h"
#include <arpa/inet.h>
#include <unistd.h>
#define SOCKET int
#define SOCKET_ERROR -1
#define INVALID_SOCKET -1

#endif

#include <thread>
#include <functional>
#include <mutex>
#include <chrono>
#include <string>

#include "cocos2d.h"
USING_NS_CC;

#define IN_BUFFSIZE		(16*1024)
#define OUT_BUFFSIZE	(8*1024)
#define TIMEOUT			20

class Plsocket;
typedef std::function<bool (Plsocket*, int)> HANDLER;

class Plsocket : public Ref {

public:
	enum SOCKET_STATE
	{
		SOCKET_UNCONNECT,
		SOCKET_CONNECTING,
		SOCKET_CONNECTED,
		SOCKET_CLOSED
	};
	enum IO_STATE{
		///
		IO_SUCC,
		IO_FAILED,
		IO_CLOSED,
		IO_TIMEOUT
	};

public:	
	~Plsocket();
	static Plsocket* create(unsigned int in_buffzie=IN_BUFFSIZE, unsigned int out_buffsize=OUT_BUFFSIZE);
#ifdef WIN32
	static int loadlib();
#endif

	bool init(unsigned int in_buffsize, unsigned int out_buffzie);

	bool asyncConnect(const char* ip, unsigned short port, int onConnHandler, int onErrorHandler, int timeout=TIMEOUT);	
	bool asyncSend(const char* data, int len);
	void asyncRecv(char* data, int* plen);

	///用于给lua来直接获取缓冲区的所有数据
	void luaAsyncRecv(std::function <void (Plsocket*)> func);
	void asyncClose();
	bool asyncDelete();

	void clearInbufNum(int num);
	SOCKET_STATE socket_state();
	//thread worker
	void thread_worker();
	void performFunctionInSocketThread(const std::function<void()> &function);

	void socket_clear();
private:
	Plsocket();
	//socket op
	bool socket_error();
	void socket_close();
	
	IO_STATE socket_send();
	IO_STATE socket_recv();	

private:
	static bool _isload;
	SOCKET_STATE _state;
	SOCKET _socket;

	std::string _serveraddr;
	unsigned short _serverport;
	int _conntimeout;

	// Used for "perform Function"
	std::vector<std::function<void()>> _functionsToPerform;
	

	//callbacks
	//send buff
	char* _outbuf;
	int _outbufsize;
	int _outbuflen;

	std::mutex _performMutex;
	std::mutex _outbufMutex;
	std::mutex _inbufMutex;
	std::mutex _stateMutex;

public:
	//recv buff
	char* _inbuf;
	int _inbufsize;
	int _inbuflen;

	///for lua
	int _onluaConnHandler;
	int _onluaErrorHandler;
};


#endif