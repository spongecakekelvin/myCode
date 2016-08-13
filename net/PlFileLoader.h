#ifndef		__PLFILELOADER_H__
#define		__PLFILELOADER_H__

#include <mutex>
#include <condition_variable>
#include <functional>
#include <string>
#include <thread>
#include <queue>

#include <curl/curl.h>
#include <curl/easy.h>
#include "cocos2d.h"
USING_NS_CC;

class PlFileLoader : public Ref {
public:
	enum OP_CODE{
		/// OP 
		CODE_SUCCESS,

		/// file not exist
		CODE_NOFILE,

		/// Error caused by creating a file to store downloaded data
		CODE_CREATE_FILE,


		/// no valid memory for store downloaded data
		CODE_NO_MEMORY,
		/** Error caused by network
         -- network unavaivable
         -- timeout
         -- ...
         */
		 CODE_NETWORK,

		 /** Error caused in uncompressing stage
         -- can not open zip file
         -- can not read file global information
         -- can not read file information
         -- can not create a directory
         -- ...
         */
		 CODE_UNCOMPRESS
	};

	enum OP_TYPE{
		/// get file length
		TYPE_GETLENGTH,

		/// download file from server
		TYPE_DOWNlOAD,

		/// get content of file from server
		TYPE_GETCONTENT,

		/// uncompress 
		TYPE_UNCOMPRESS
	};

	///zip 支持断点下载，  普通文件不需要支持
	struct TaskInfo{
		OP_TYPE opType;
		std::string fileName;  //download filename or zipfile
		std::string storgePath; //for uncompress
		std::string url;
		bool needProgress;
		long startPos;
	};

public:
	///file utils
	static bool createDirectory(const char* path);
	static void deleteDirectory(const char* path);
	static bool isDirectoryExist(const char* path);
	static bool isFileExist(const char* path);
	static bool isZipFile(const char* path);
	static bool unCompress(const char* storgePath, const char* path);
	static long getFileLength(const char* path);

public:
	static PlFileLoader* getInstance();
	bool performTask(TaskInfo* task);
	bool pause();
	void resume();
	PlFileLoader();
	~PlFileLoader();
	bool init();

	void onProgress(double percent);
	void onTaskReturn(OP_TYPE opType, OP_CODE opCode, double length=0);
	void setLuaCallback(int onLuaProgress, int onLuaTaskReturn);
	void setTimeout(unsigned int timeout);
	void notifyQuit();
private:
	void loader();
	void wakeUp();
	void waitforCondition();
	void doTask(TaskInfo* task);
	void setCurlArgs(TaskInfo* task);
private:
	static PlFileLoader* _fileLoader;
	bool _isDoing;
	bool _isNeedQuit;
	
	std::thread* _loadingThread;

	std::mutex _sleepMutex;
	std::condition_variable _sleepCondition;
	std::queue<TaskInfo*> _taskInfoQueue;
	std::mutex _taskInfoQueueMutex;
	
	unsigned int _connectionTimeout; 

	///for TYPE_CONTENT
	//std::string _content;

public:
	TaskInfo* _curTask;
	bool _isPause;
	void* _curl;
	char* _contentBuf;
	size_t _maxLen;
	size_t _curLen;
	///for lua callback
	int _onLuaProgress;
	int _onLuaTaskReturn;
};

#endif