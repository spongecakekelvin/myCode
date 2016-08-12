/*
 * define file about portable socket class.
 * description:this sock is suit both windows and linux
 * design:odison
 * e-mail:odison@126.com>
 *
 */

#ifndef _ODSOCKET_H_
#define _ODSOCKET_H_

#ifdef WIN32
	#include <winsock2.h>
#include<iostream>  
#include<Windows.h>  
	typedef int				socklen_t;
#else
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <netdb.h>
	#include <fcntl.h>
	#include <unistd.h>
	#include <sys/stat.h>
	#include <sys/types.h>
	#include <arpa/inet.h>
    #include <netdb.h>
    #include <stdio.h>

	typedef int				SOCKET;

	//#pragma region define win32 const variable in linux
	#define INVALID_SOCKET	-1
	#define SOCKET_ERROR	-1
	//#pragma endregion
#endif


class BSDSocket {

public:
	BSDSocket(SOCKET sock = INVALID_SOCKET);
	~BSDSocket();

	// Create socket object for snd/recv data
	bool Create(int af, int type, int protocol = 0);

	// Connect socket
	bool Connect(const char* hostname, unsigned short port);
	void updateNetType();
	//#region server
	// Bind socket
	bool Bind(unsigned short port);

	// Listen socket
	bool Listen(int backlog = 5);

	// Accept socket
	bool Accept(BSDSocket& s, char* fromip = NULL);
	//#endregion
	int Select(struct timeval *to);
	// Send socket
	int Send(const char* buf, int len, int flags = 0);

	// Recv socket
	int Recv(char* buf, int len, int flags = 0);

	// Close socket
	int Close();

	// Get errno
	int GetError();

	//#pragma region just for win32
	// Init winsock DLL
	static int Init();
	// Clean winsock DLL
	static int Clean();
	//#pragma endregion

	// Domain parse
	static bool DnsParse(const char* domain, char* ip);

	bool ConnectIPV6_IPV4(const char* domain, unsigned short port) ;

	BSDSocket& operator = (SOCKET s);

	operator SOCKET ();

	bool isValid;
	bool m_isNetWorkIpv6;

protected:
	SOCKET m_sock;
	fd_set  fdR;
};

#endif
