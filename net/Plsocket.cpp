#include "tolua++.h"
#include "tolua_fix.h"
#include "CCLuaEngine.h"

#include "Plsocket.h"

bool Plsocket::_isload = false;

Plsocket::Plsocket()
{
	_state = SOCKET_UNCONNECT;
	_socket = INVALID_SOCKET;
	_serveraddr = "";
	_serverport = 0;
	_conntimeout = 0;
	_outbuf = nullptr;
	_outbufsize = 0;
	_outbuflen = 0;
	_inbuf = nullptr;
	_inbufsize = 0;
	_inbuflen = 0;
	_onluaConnHandler = 0;
	_onluaErrorHandler = 0;
}

Plsocket::~Plsocket()
{
	CCLOG("Plsocket::~Plsocket\n");
	CC_SAFE_DELETE_ARRAY(_outbuf);
	CC_SAFE_DELETE_ARRAY(_inbuf);

	if(_onluaConnHandler)
		LuaEngine::getInstance()->removeScriptHandler(_onluaConnHandler);
	if(_onluaErrorHandler)
		LuaEngine::getInstance()->removeScriptHandler(_onluaErrorHandler);
}

bool Plsocket::init(unsigned int in_buffsize, unsigned int out_buffzie)
{
	_inbuf = new char[in_buffsize];
	_outbuf = new char[out_buffzie];
	if(_inbuf && _outbuf){
		_inbufsize = in_buffsize;
		_outbufsize = out_buffzie;
		return true;
	}
		
	CC_SAFE_DELETE_ARRAY(_outbuf);
	CC_SAFE_DELETE_ARRAY(_inbuf);
	return false;
}

#ifdef WIN32
int Plsocket::loadlib()
{
	WSADATA wsaData; 
	WORD version = MAKEWORD(2, 0);
	int ret = WSAStartup(version, &wsaData);//win sock start up
	if ( ret ) {
		return -1;
	}
	return 0;
}
#endif

Plsocket* Plsocket::create(unsigned int in_buffzie/* =IN_BUFFSIZE */, unsigned int out_buffsize/* =OUT_BUFFSIZE */)
{
#ifdef WIN32
	if(!_isload)
	{
		loadlib();
		_isload = true;
	}
#endif

	Plsocket* ret = new Plsocket();
	if(ret && ret->init(in_buffzie, out_buffsize)){
		ret->autorelease();
	}else{
		CC_SAFE_DELETE(ret);
	}
	return ret;
}

///socket op
bool Plsocket::socket_error()
{
#ifdef WIN32
	int err = WSAGetLastError();  
	if (err != WSAEWOULDBLOCK){
#else
	int err = errno;
	if(err != EINPROGRESS && err != EAGAIN){
#endif
		return true;
	}

	return false;
}

void Plsocket::socket_close()
{
	if(_socket == INVALID_SOCKET)
		return;
#ifdef WIN32
	closesocket(_socket);
#else
	close(_socket);
#endif
	_socket = INVALID_SOCKET;
	_state = SOCKET_CLOSED;
}

//reset socket buf
void Plsocket::socket_clear()
{
	_inbuflen = 0;
	_outbuflen = 0;
	if(_inbuf)
		memset(_inbuf, 0, _inbufsize);
	if(_outbuf)
		memset(_outbuf,0, _outbufsize);
}

Plsocket::IO_STATE Plsocket::socket_send()
{
	std::lock_guard<std::mutex> lg(_outbufMutex);
	if(_socket == INVALID_SOCKET)
		return IO_FAILED;

	IO_STATE res = IO_SUCC;
	if(_outbuflen <= 0)
		return res;
	
	int nlen = 0;
	for(;;)
	{
		if(_outbuflen <= 0)
			break;
		int sendlen = send(_socket, _outbuf, _outbuflen, 0);
		if(sendlen > 0){
			nlen += sendlen;
			_outbuflen -= sendlen;
			break;
		}
		 /* send can't really return 0, but EPIPE means the connection was 
           closed */
		if(sendlen == 0 || errno == EPIPE){
			res = IO_CLOSED;
			break;
		}

		if(errno == EINTR) continue;
		if(socket_error()){
			res = IO_FAILED;
		}
		break;
	}

	if(_outbuflen != 0 && nlen >0)
		memmove(_outbuf, _outbuf+nlen, _outbuflen);
	return res;
}

Plsocket::IO_STATE Plsocket::socket_recv()
{
	std::lock_guard<std::mutex> lg(_inbufMutex);
	if(_socket == INVALID_SOCKET)
		return IO_FAILED;

	IO_STATE res = IO_SUCC;
	for(;;)
	{
		if(_inbuflen >= _inbufsize)
			break;

		int nlen = recv(_socket, _inbuf + _inbuflen, _inbufsize - _inbuflen, 0);
		if(nlen > 0){
			_inbuflen += nlen;
			break;
		}else if(nlen == 0){
			res = IO_CLOSED;
			break;
		}else{
			if(errno == EINTR) continue;
			if(socket_error()){
				res = IO_FAILED;
			}
			break;
		}
	}

	return res;
}

Plsocket::SOCKET_STATE Plsocket::socket_state()
{
	std::lock_guard<std::mutex> lg(_stateMutex);
	return _state;
}

void Plsocket::performFunctionInSocketThread(const std::function<void ()> &function)
{
	std::lock_guard<std::mutex> lg(_performMutex);
	_functionsToPerform.push_back(function);
}

bool Plsocket::asyncConnect(const char* ip, unsigned short port, int onConnHandler, int onErrorHandler, int timeout/* =TIMEOUT */)
{
	if(!(_state == SOCKET_UNCONNECT || _state == SOCKET_CLOSED)){
		CCLOG("socket connecting\n");
		return false;
	}

	_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(_socket == INVALID_SOCKET){
		socket_close();
		return false;
	}

	///keepalive
	int op = 1;
	if(setsockopt(_socket, SOL_SOCKET, SO_KEEPALIVE, (char*)&op, sizeof(int))){
		socket_close();
		return false;
	}

	///set nonblock
#ifdef WIN32
	DWORD bmode = 1;
	int res = ioctlsocket(_socket, FIONBIO, &bmode);
	if(res == SOCKET_ERROR){
		socket_close();
		return false;
	}
#else
	fcntl(_socket, F_SETFL, O_NONBLOCK);
#endif
	_serveraddr = ip;
	_serverport = port;
	_state = SOCKET_CONNECTING;
	_conntimeout = timeout;

	if(_onluaConnHandler){
		LuaEngine::getInstance()->removeScriptHandler(_onluaConnHandler);		
	}
	if(_onluaErrorHandler){
		LuaEngine::getInstance()->removeScriptHandler(_onluaErrorHandler);		
	}
	_onluaConnHandler = onConnHandler;
	_onluaErrorHandler = onErrorHandler;


	///start thread
	std::thread th = std::thread(&Plsocket::thread_worker, this);
	th.detach();
	this->retain();

	return true;
}

///thread worker
void Plsocket::thread_worker()
{
	CCLOG("thread worker start running");
	///really connect
	sockaddr_in addrin;
	memset(&addrin, 0, sizeof(addrin));
	addrin.sin_family = AF_INET;
	addrin.sin_port = htons(_serverport);
	addrin.sin_addr.s_addr = inet_addr(_serveraddr.c_str());

	bool connSucc = true;
	IO_STATE io_state = IO_SUCC;

	if(connect(_socket, (sockaddr*)&addrin, sizeof(addrin)) == SOCKET_ERROR){
		if(socket_error()){
			connSucc = false;
			io_state = IO_FAILED;
		}else{
			timeval tm;
			tm.tv_sec = _conntimeout;
			tm.tv_usec = 0;
			fd_set writeset, exceptset;
			FD_ZERO(&writeset);
			FD_ZERO(&exceptset);
			FD_SET(_socket, &writeset);  
			FD_SET(_socket, &exceptset);
			int ret = select(FD_SETSIZE, NULL, &writeset, &exceptset, &tm); 
			if(ret == 0 || ret <0){
				connSucc = false;
				io_state = IO_TIMEOUT;
			}else{
				ret = FD_ISSET(_socket, &exceptset);
				if(ret){
					connSucc = false;
					io_state = IO_FAILED;
				}
			}

		}
	}
	if(!connSucc){
		//CCLOG("11111111111111");
		std::lock_guard<std::mutex> lg(_stateMutex);
		socket_close();
		socket_clear();
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([connSucc, io_state, this](){
			///onconnect callbacks
			//CCLOG("connect result:%d\n", connSucc);
			if(this->_onluaConnHandler){
				SOCKET_STATE state = this->socket_state();
				//assert(state == SOCKET_CLOSED);
				auto defaultEngine = LuaEngine::getInstance();
				if(defaultEngine){
					LuaStack* stack = defaultEngine->getLuaStack();
					stack->pushObject(this, "cc.Plsocket");
					stack->pushInt(io_state);
					stack->executeFunctionByHandler(_onluaConnHandler, 2);
				}
			}
			this->release();
		});
		return;
	}else{
		_state = SOCKET_CONNECTED;
		Director::getInstance()->getScheduler()->performFunctionInCocosThread([connSucc,io_state, this](){
			///onconnect callbacks
			CCLOG("connect result:%d\n", connSucc);
			if(this->_onluaConnHandler){
				auto defaultEngine = LuaEngine::getInstance();
				if(defaultEngine){
					LuaStack* stack = defaultEngine->getLuaStack();
					stack->pushObject(this, "cc.Plsocket");
					stack->pushInt(io_state);
					stack->executeFunctionByHandler(_onluaConnHandler, 2);
				}
			}
		});
	}

	IO_STATE io_sendstate = IO_SUCC;
	IO_STATE io_recvstate = IO_SUCC;
	for(;;)
	{
		std::this_thread::sleep_for(std::chrono::microseconds(10));
		if(_socket == INVALID_SOCKET)
			break;
		io_recvstate = socket_recv();
		//CCLOG("io_recvstate:%d\n", io_recvstate);
		io_sendstate = socket_send();
		//CCLOG("io_sendstate:%d\n", io_sendstate);
		if(!_functionsToPerform.empty())
		{
			_performMutex.lock();
			auto temp = _functionsToPerform;
			_functionsToPerform.clear();
			_performMutex.unlock();
			for( const auto &function : temp ) {
				function();
			}
		}

		if(io_recvstate != IO_SUCC || io_sendstate != IO_SUCC){
			break;
		}

	}

	if(io_recvstate == IO_CLOSED || io_sendstate == IO_CLOSED){
		io_state = IO_CLOSED;
	}else{
		io_state = IO_FAILED;
	}

	//handle left recv data
	std::lock_guard<std::mutex> lg(_stateMutex);
	socket_close();

	Director::getInstance()->getScheduler()->performFunctionInCocosThread([io_state, this](){
		////调用lua的 onerror callbacks
		///等待线程退出
		bool ret = true;
		SOCKET_STATE state = this->socket_state();
		//assert(state == SOCKET_CLOSED);

		if(this->_onluaErrorHandler){
			auto defaultEngine = LuaEngine::getInstance();
			if(defaultEngine){
				LuaStack* stack = defaultEngine->getLuaStack();
				stack->pushObject(this, "cc.Plsocket");
				stack->pushInt(io_state);
				stack->executeFunctionByHandler(_onluaErrorHandler, 2);
			}
		}
		this->release();		
	});	
	CCLOG("thread exit\n");
}

///!!!!!!!!after thread exit and delete _socket
bool Plsocket::asyncDelete()
{
	if(_state == SOCKET_CLOSED){
		this->release();
		return true;
	}
	return false;
}

void Plsocket::asyncRecv(char* data, int* plen)
{
	///decode data later
	std::lock_guard<std::mutex> lg(_inbufMutex);
	int wantlen = *plen;
	wantlen = wantlen > _inbuflen ? _inbuflen : wantlen;
	*plen = wantlen;
	if(wantlen >0){
		memcpy(data, _inbuf, wantlen);
		_inbuflen -= wantlen;
		if(_inbuflen > 0)
			memmove(_inbuf, _inbuf+wantlen, _inbuflen);
	}	
}

void Plsocket::luaAsyncRecv(std::function <void (Plsocket*)> func)
{
	std::lock_guard<std::mutex> lg(_inbufMutex);
	func(this);
	_inbuflen = 0;
}

//缓冲区满则直接丢弃
bool Plsocket::asyncSend(const char* data, int len)
{
	if(_socket == INVALID_SOCKET || _state != SOCKET_CONNECTED)
		return false;
	std::lock_guard<std::mutex> lg(_outbufMutex);
	if(_outbuflen+len > _outbufsize)
		return false;
	memcpy(_outbuf+_outbuflen, data, len);
	_outbuflen += len;
	return true;
}

void Plsocket::asyncClose()
{
	performFunctionInSocketThread([this](){
		this->socket_close();
		return;
	});
}

void Plsocket::clearInbufNum(int num)
{
	std::lock_guard<std::mutex> lg(_inbufMutex);
	if(num < 0)
		num = 0;
	if(num > _inbuflen)
		num = _inbuflen;

	_inbuflen = _inbuflen - num;
	if(_inbuflen < 0)
		_inbuflen = 0;

	if(_inbuflen > 0){
		memmove(_inbuf, _inbuf+num, _inbuflen);
	}
}