#include <stdio.h>
#include "BSDSocket.h"
#include "cocos2d.h"
#ifdef WIN32
#pragma comment(lib, "wsock32")
#endif

#include <thread>
#include <algorithm>
#include <functional>
#include <cctype>
#include <locale>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>

#if defined(_MSC_VER) || defined(__MINGW32__)
#include <io.h>
#include <WS2tcpip.h>
#include <Winsock2.h>
#define bzero(a, b) memset(a, 0, b);
#else
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#endif


static bool isIPV6Net(const std::string domainStr = "www.baidu.com")
{
	bool isIPV6Net = false;

	struct addrinfo *result = nullptr,*curr;

	struct sockaddr_in6 dest;
	bzero(&dest, sizeof(dest));

	dest.sin6_family  = AF_INET6;

	int ret = getaddrinfo(domainStr.c_str(),nullptr,nullptr,&result);
	if (ret == 0)
	{
		for (curr = result; curr != nullptr; curr = curr->ai_next)
		{
			switch (curr->ai_family)
			{
			case AF_INET6:
				{
					isIPV6Net = true;
					break;
				}
			case AF_INET:

				break;

			default:
				break;
			}
		}
	}

	freeaddrinfo(result);

	return isIPV6Net;
}


static std::string domainToIP(const char* pDomain)
{
	if (isIPV6Net())
	{
		struct addrinfo hint;
		memset(&hint, 0x0, sizeof(hint));
		hint.ai_family = AF_INET6;
		hint.ai_flags = AI_V4MAPPED;

		addrinfo* answer = nullptr;
		getaddrinfo(pDomain, nullptr, &hint, &answer);

		if (answer != nullptr)
		{
			char hostname[1025] = "";

			getnameinfo(answer->ai_addr,answer->ai_addrlen,hostname,1025,nullptr,0,0);

			char ipv6[128] = "";
			memcpy(ipv6,hostname,128);

			CCLOG("domainToIP addrStr:%s", ipv6);

			return ipv6;
		}

		freeaddrinfo(answer);
	}
	else
	{
		struct hostent* h = gethostbyname(pDomain);
		if( h != NULL )
		{
			unsigned char* p = (unsigned char *)(h->h_addr_list)[0];
			if( p != NULL )
			{
				char ip[16] = {0};
				sprintf(ip, "%u.%u.%u.%u", p[0], p[1], p[2], p[3]);
				return ip;
			}
		}
	}
	return "";
}


//m_uSocket = socket((isIPV6Net()?AF_INET6:AF_INET), SOCK_STREAM, IPPROTO_TCP);

//struct sockaddr* BSDSocket::getSockaddr() const
//{
//	return m_isNetWorkIpv6 ? (struct sockaddr*)&addr_v6 : (struct sockaddr*)&addr_v4;
//}
//
//int BSDSocket::getLength()
//{
//	return m_isNetWorkIpv6 ? sizeof(sockaddr_in6) : sizeof(sockaddr_in);
//}

//int nRet = ::connect(m_uSocket, m_oInetAddress.getSockaddr(), m_oInetAddress.getLength());

BSDSocket::BSDSocket(SOCKET sock) {
	m_sock = sock;
	isValid = false;
}

BSDSocket::~BSDSocket() {
}

int BSDSocket::Init() {
#ifdef WIN32
	/*
	http://msdn.microsoft.com/zh-cn/vstudio/ms741563(en-us,VS.85).aspx

	typedef struct WSAData {
	WORD wVersion;								//winsock version
	WORD wHighVersion;							//The highest version of the Windows Sockets specification that the Ws2_32.dll can support
	char szDescription[WSADESCRIPTION_LEN+1];
	char szSystemStatus[WSASYSSTATUS_LEN+1];
	unsigned short iMaxSockets;
	unsigned short iMaxUdpDg;
	char FAR * lpVendorInfo;
	}WSADATA, *LPWSADATA;
	*/
	WSADATA wsaData;
	//#define MAKEWORD(a,b) ((WORD) (((BYTE) (a)) | ((WORD) ((BYTE) (b))) << 8))
	WORD version = MAKEWORD(2, 0);
	int ret = WSAStartup(version, &wsaData); //win sock start up
	if (ret) {
		//		cerr << "Initilize winsock error !" << endl;
		return -1;
	}
#endif

	return 0;
}

int BSDSocket::Clean() {
#ifdef WIN32
	return (WSACleanup());
#endif
	return 0;
}

BSDSocket& BSDSocket::operator =(SOCKET s) {
	m_sock = s;
	return (*this);
}

BSDSocket::operator SOCKET() {
	return m_sock;
}

void BSDSocket::updateNetType()
{
	m_isNetWorkIpv6 = isIPV6Net();
}

bool BSDSocket::Create(int af, int type, int protocol) {
	updateNetType();
	m_sock = socket((m_isNetWorkIpv6 ?AF_INET6:AF_INET), SOCK_STREAM, IPPROTO_TCP);
	//m_sock = socket(af, type, protocol);
	if (m_sock == INVALID_SOCKET) {
		return false;
	}
	return true;
}

bool BSDSocket::Connect(const char* hostname, unsigned short port) {

	
		std::string ipaddrstr = domainToIP(hostname);
		if (ipaddrstr=="")
		{
			return false;
		}
int nRet =-1;
	if (m_isNetWorkIpv6)
	{

		struct sockaddr_in6 svraddr16;  
		memset(&svraddr16, 0, sizeof(svraddr16)); 
		svraddr16.sin6_family = AF_INET6;  
		svraddr16.sin6_port = htons(port);  
		if (inet_pton(AF_INET6,ipaddrstr.c_str(),&svraddr16.sin6_addr) < 0)  
		{
		}
		 nRet = connect(m_sock, (struct sockaddr*) &svraddr16, sizeof(svraddr16));
	}
	else
	{
			struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(ipaddrstr.c_str());
	svraddr.sin_port = htons(port);

	 nRet = connect(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));
	}
	if (nRet == SOCKET_ERROR) {
		return false;
	}
	return true;


	/*struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(ip);
	svraddr.sin_port = htons(port);
	int ret = connect(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));
	if (ret == SOCKET_ERROR) {
	return false;
	}
	return true;*/
}

bool BSDSocket::Bind(unsigned short port) {
	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = INADDR_ANY;
	svraddr.sin_port = htons(port);

	int opt = 1;
	if (setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, (char*) &opt, sizeof(opt))
		< 0)
		return false;

	int ret = bind(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));
	if (ret == SOCKET_ERROR) {
		return false;
	}
	return true;
}

bool BSDSocket::Listen(int backlog) {
	int ret = listen(m_sock, backlog);
	if (ret == SOCKET_ERROR) {
		return false;
	}
	return true;
}

bool BSDSocket::Accept(BSDSocket& s, char* fromip) {
	struct sockaddr_in cliaddr;
	socklen_t addrlen = sizeof(cliaddr);
	SOCKET sock = accept(m_sock, (struct sockaddr*) &cliaddr, &addrlen);
	if (sock == SOCKET_ERROR) {
		return false;
	}

	s = sock;
	if (fromip != NULL)
		sprintf(fromip, "%s", inet_ntoa(cliaddr.sin_addr));

	return true;
}

int BSDSocket::Select(struct timeval *to){
	FD_ZERO(&fdR);
	FD_SET(m_sock, &fdR);
	//struct timeval mytimeout;
	//mytimeout.tv_sec=3;
	//mytimeout.tv_usec=0;
	struct timeval timeout={12,0}; 
	//struct timeval timeout={3,0}; 
	//int result= select(m_sock,&fdR,NULL,NULL,NULL);
	int result= select(m_sock+1,&fdR,NULL,NULL,&timeout);
	//int result= select(m_sock+1,&fdR,NULL,NULL,to);

	//if(result==-1)
		if(result<=0)
	{
		return result;
	}
	//else if (result==0)
	//{
	//	return 0;
	//}
	/*else if(result==0){
	return -4;
	}*/
	else {
		if(FD_ISSET(m_sock,&fdR)){
			return -2;
		}else {
			//if (result==0)
			//{
			//	return -1;
			//}
			//else
			//{
			//	return -3;
			//}
			return result;
		}
	}
}



int BSDSocket::Send(const char* buf, int len, int flags) {
	int bytes;
	int count = 0;

	while (count < len) {
		bytes = send(m_sock, buf + count, len - count, flags);
		if (bytes == -1 || bytes == 0)
			return -1;
		count += bytes;
	}

	return count;
}

int BSDSocket::Recv(char* buf, int len, int flags) {
	return (recv(m_sock, buf, len, flags));
}

int BSDSocket::Close() {
#ifdef WIN32
	return (closesocket(m_sock));
#else
	return (close(m_sock));
#endif
}

int BSDSocket::GetError() {
#ifdef WIN32
	return (WSAGetLastError());
#else
	return -1;
#endif
}

bool BSDSocket::DnsParse(const char* domain, char* ip) {
	struct hostent* p;
	if ((p = gethostbyname(domain)) == NULL)
		return false;

	sprintf(ip, "%u.%u.%u.%u", (unsigned char) p->h_addr_list[0][0],
		(unsigned char) p->h_addr_list[0][1],
		(unsigned char) p->h_addr_list[0][2],
		(unsigned char) p->h_addr_list[0][3]);

	return true;
}


bool BSDSocket::ConnectIPV6_IPV4(const char* domain, unsigned short port)
{
struct addrinfo *result;  
struct addrinfo *res;  

struct addrinfo addrCriteria;  
memset(&addrCriteria,0,sizeof(addrCriteria));  
addrCriteria.ai_family=AF_UNSPEC;  
addrCriteria.ai_socktype=SOCK_STREAM;  
addrCriteria.ai_protocol=IPPROTO_TCP;  
char servname[8] = {0};
sprintf(servname, "%d", port);
int ret = -1;
//int error = getaddrinfo("www.baidu.com", "1100", &addrCriteria, &result);  
int error = getaddrinfo(domain, servname, &addrCriteria, &result);  
if (error == 0)  
{  
	struct sockaddr_in *sa;  
	/*
	for (res = result; res != NULL; res = res->ai_next)  
	{  
		if (AF_INET6 == res->ai_addr->sa_family)  
		{  
			char buf[128] = {};  
			sa = (struct sockaddr_in*)res->ai_addr;  
			inet_ntop(AF_INET6, &((reinterpret_cast<struct sockaddr_in6*>(sa))->sin6_addr), buf, 128);  

			m_sock = socket(res->ai_family, res->ai_socktype, 0);  
			if (m_sock == -1) {  
				return false;  
			}  

			struct sockaddr_in6 svraddr16;  
			memset(&svraddr16, 0, sizeof(svraddr16)); //注意初始化  
			svraddr16.sin6_family = AF_INET6;  
			svraddr16.sin6_port = htons(port);  
			if (inet_pton(AF_INET6,buf,&svraddr16.sin6_addr) < 0)  
			{  
			}  
			ret = connect(m_sock, (struct sockaddr*) &svraddr16, sizeof(svraddr16));  
			break;  
		}  
		else if (AF_INET == res->ai_addr->sa_family)  
		{  
			char buf[32] = {};  
			sa = (struct sockaddr_in*)res->ai_addr;  
			inet_ntop(AF_INET, &sa->sin_addr, buf, 32);  

			m_sock = socket(res->ai_family, res->ai_socktype, 0);  
			if (m_sock == -1) {  
				return false;  
			}  

			struct sockaddr_in svraddr;  
			svraddr.sin_family = AF_INET;  
			svraddr.sin_addr.s_addr = inet_addr(buf);  
			svraddr.sin_port = htons(port);  
			ret = connect(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));  
		}  
	} 
	*/
	for (res = result; res != NULL; res = res->ai_next)  
	{  
		CCLOG("%d",res->ai_addr->sa_family);
		if (AF_INET6 == res->ai_addr->sa_family)  
		{  
			char buf[128] = {};  
			sa = (struct sockaddr_in*)res->ai_addr;  
			inet_ntop(AF_INET6, &((reinterpret_cast<struct sockaddr_in6*>(sa))->sin6_addr), buf, 128);  

			m_sock = socket(res->ai_family, res->ai_socktype, 0);  
			if (m_sock == -1) {  
				continue;  
			}  

			struct sockaddr_in6 svraddr16;  
			memset(&svraddr16, 0, sizeof(svraddr16)); //注意初始化  
			svraddr16.sin6_family = AF_INET6;  
			svraddr16.sin6_port = htons(port);  
			if (inet_pton(AF_INET6,buf,&svraddr16.sin6_addr) < 0)  
			{  
			}  
			 ret = connect(m_sock, (struct sockaddr*) &svraddr16, sizeof(svraddr16));  
			 if (ret != SOCKET_ERROR) {
				 break;
			 }
		}  
	} 
	if (ret == SOCKET_ERROR) {
	

	for (res = result; res != NULL; res = res->ai_next)  
	{  
		 if (AF_INET == res->ai_addr->sa_family)  
		{  
			char buf[32] = {};  
			sa = (struct sockaddr_in*)res->ai_addr;  
			inet_ntop(AF_INET, &sa->sin_addr, buf, 32);  

			m_sock = socket(res->ai_family, res->ai_socktype, 0);  
			if (m_sock == -1) {  
				continue;  
			}  

			struct sockaddr_in svraddr;  
			svraddr.sin_family = AF_INET;  
			svraddr.sin_addr.s_addr = inet_addr(buf);  
			svraddr.sin_port = htons(port);  
			ret = connect(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));  
			if (ret != SOCKET_ERROR) {
				break;
			}
		}  
	} 
	}

	if (ret == SOCKET_ERROR) {
		return false;
	}
	else

	{
		return true;
	}
	
}
return false;

}